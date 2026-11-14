-- =============================================================
-- Rinde · Tablas de negocio (etapa B del plan PowerSync)
-- Ejecutar UNA vez en Supabase → SQL Editor, completo.
-- Requiere: 20261111120000_locales_y_miembros.sql y la etapa A
-- (rol powersync_role y publicación powersync ya creados).
--
-- Va en una transacción: si algo falla, no queda nada a medias.
-- Pega el archivo completo (de "begin" a "commit") y aprieta Run.
-- =============================================================

begin;


-- ---------- 1. Tablas futuras nacen cerradas para "anon" ----------
-- Supabase da por defecto todos los permisos a anon en cada tabla,
-- secuencia y función nueva de "public". Esto lo apaga para lo que se
-- cree de aquí en adelante. Ojo: RLS igual hay que activarlo en cada
-- tabla nueva; esto no lo hace solo.
alter default privileges for role postgres in schema public
  revoke all on tables from anon;
alter default privileges for role postgres in schema public
  revoke all on sequences from anon;
alter default privileges for role postgres in schema public
  revoke execute on functions from public, anon;


-- ---------- 2. Poder borrar una cuenta (exigido por Google Play) ----------
-- Antes, borrar un usuario fallaba porque locales.creado_por lo apuntaba.
-- Ahora queda en null y el local sigue existiendo.
-- PENDIENTE antes de publicar: si el ÚNICO miembro borra su cuenta, sus
-- filas en "miembros" se borran (cascade) y el local con todos sus datos
-- queda huérfano: nadie lo ve, pero sigue guardado. Ver docs/plan-powersync.md.
alter table public.locales alter column creado_por drop not null;
alter table public.locales drop constraint if exists locales_creado_por_fkey;
alter table public.locales
  add constraint locales_creado_por_fkey
  foreign key (creado_por) references auth.users (id) on delete set null;


-- ---------- 3. miembros: "id" como llave primaria ----------
-- PowerSync no soporta llaves primarias compuestas: necesita una sola
-- columna "id". Además, con REPLICA IDENTITY DEFAULT, Postgres informa
-- los borrados solo con la llave primaria; si siguiera siendo
-- (local_id, usuario_id), el borrado no traería el "id". Por eso "id"
-- pasa a ser la primaria y la pareja queda como unique (sigue sin poder
-- repetirse un mismo usuario en un mismo local).
alter table public.miembros
  add column id uuid not null default gen_random_uuid();
alter table public.miembros drop constraint miembros_pkey;
alter table public.miembros add primary key (id);
alter table public.miembros
  add constraint miembros_local_usuario_key unique (local_id, usuario_id);


-- ---------- 4. puede_editar(local_id) ----------
-- Hoy: cualquier miembro edita. Con Rinde Teams se cambia SOLO esta
-- función (p. ej., un empleado vende pero no edita recetas) y las
-- políticas de abajo quedan igual.
create or replace function public.puede_editar(p_local_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.miembros m
    where m.local_id = p_local_id
      and m.usuario_id = (select auth.uid())
      and m.rol in ('dueno', 'empleado')
  );
$$;

revoke all on function public.puede_editar(uuid) from public, anon;
grant execute on function public.puede_editar(uuid) to authenticated;


-- ---------- 5. Ninguna fila cambia de id ni de local ----------
-- RLS no basta: un dueño de dos locales podría "mover" un ingrediente
-- de uno a otro. Este trigger lo impide en todas las tablas de negocio.
create or replace function public.impedir_mover_fila()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.id is distinct from old.id
     or new.local_id is distinct from old.local_id then
    raise exception 'No se puede cambiar el id ni el local de una fila'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke all on function public.impedir_mover_fila() from public, anon;


-- ---------- 6. Tablas de negocio ----------
-- Todas llevan local_id (RLS y Sync Streams filtran sin joins).
-- unique (local_id, id) permite llaves foráneas DOBLES: así una receta
-- solo puede usar ingredientes de SU MISMO local.
-- Sin "unique" de nombres: se valida en la app (decisión del plan).
-- Sin stock ni costo en ingredientes: se calculan desde movimientos.

create table public.categorias (
  id              uuid primary key default gen_random_uuid(),
  local_id        uuid not null references public.locales (id) on delete cascade,
  nombre          text not null check (char_length(btrim(nombre)) between 1 and 60),
  orden           integer not null default 0,  -- "Otros" = 1000, siempre al final
  creado_en       timestamptz not null default now(),
  actualizado_en  timestamptz not null default now(),
  unique (local_id, id)
);

create table public.ingredientes (
  id              uuid primary key default gen_random_uuid(),
  local_id        uuid not null references public.locales (id) on delete cascade,
  nombre          text not null check (char_length(btrim(nombre)) between 1 and 80),
  categoria_id    uuid,
  unidad          text not null check (unidad in ('gramos', 'mililitros', 'unidades')),
  stock_minimo    double precision not null default 0 check (stock_minimo >= 0),
  archivado       boolean not null default false,
  creado_en       timestamptz not null default now(),
  actualizado_en  timestamptz not null default now(),
  unique (local_id, id),
  foreign key (local_id, categoria_id) references public.categorias (local_id, id)
);

-- Historial de stock. Solo se insertan filas: nunca se editan ni borran.
create table public.movimientos (
  id              uuid primary key default gen_random_uuid(),
  local_id        uuid not null references public.locales (id) on delete cascade,
  ingrediente_id  uuid not null,
  tipo            text not null check (tipo in ('inicial', 'compra', 'ajuste', 'venta')),
  cantidad        double precision not null,      -- + entra / − sale (g, ml o u)
  costo_unitario  double precision check (costo_unitario >= 0),
  conteo          double precision,               -- solo en ajustes: stock contado
  motivo          text check (char_length(motivo) <= 200),
  fecha           timestamptz not null default now(),
  -- Quién lo anotó (útil con Teams). Debe ser quien sube la fila.
  creado_por      uuid default auth.uid() references auth.users (id) on delete set null,
  unique (local_id, id),
  foreign key (local_id, ingrediente_id) references public.ingredientes (local_id, id)
);

create table public.platos (
  id              uuid primary key default gen_random_uuid(),
  local_id        uuid not null references public.locales (id) on delete cascade,
  nombre          text not null check (char_length(btrim(nombre)) between 1 and 80),
  precio_venta    double precision not null check (precio_venta >= 0),
  costo_manual    double precision not null default 0 check (costo_manual >= 0),
  foto            text,   -- nombre del archivo en el teléfono (la foto no se sube aún)
  codigo_externo  text,
  archivado       boolean not null default false,
  creado_en       timestamptz not null default now(),
  actualizado_en  timestamptz not null default now(),
  unique (local_id, id)
);

create table public.receta_items (
  id              uuid primary key default gen_random_uuid(),
  local_id        uuid not null references public.locales (id) on delete cascade,
  plato_id        uuid not null,
  ingrediente_id  uuid not null,
  cantidad        double precision not null check (cantidad > 0),
  unique (local_id, id),
  foreign key (local_id, plato_id) references public.platos (local_id, id) on delete cascade,
  foreign key (local_id, ingrediente_id) references public.ingredientes (local_id, id)
);

-- Índices para las consultas más comunes (los "unique" ya indexan local_id).
create index movimientos_ingrediente_idx
  on public.movimientos (local_id, ingrediente_id, fecha);
create index receta_items_plato_idx
  on public.receta_items (local_id, plato_id);


-- ---------- 7. Permisos de tabla ----------
-- anon: nada. authenticated: lo justo para cada tabla (RLS filtra filas).
revoke all on public.categorias, public.ingredientes, public.movimientos,
              public.platos, public.receta_items
  from anon, authenticated;

grant select, insert, update on public.categorias, public.ingredientes,
                               public.platos
  to authenticated;
grant select, insert on public.movimientos to authenticated;          -- historial
grant select, insert, update, delete on public.receta_items to authenticated;


-- ---------- 8. RLS ----------
alter table public.categorias   enable row level security;
alter table public.ingredientes enable row level security;
alter table public.movimientos  enable row level security;
alter table public.platos       enable row level security;
alter table public.receta_items enable row level security;

-- categorias
create policy "categorias: leer"     on public.categorias for select to authenticated
  using (public.es_miembro(local_id));
create policy "categorias: crear"    on public.categorias for insert to authenticated
  with check (public.puede_editar(local_id));
create policy "categorias: editar"   on public.categorias for update to authenticated
  using (public.puede_editar(local_id)) with check (public.puede_editar(local_id));

-- ingredientes
create policy "ingredientes: leer"   on public.ingredientes for select to authenticated
  using (public.es_miembro(local_id));
create policy "ingredientes: crear"  on public.ingredientes for insert to authenticated
  with check (public.puede_editar(local_id));
create policy "ingredientes: editar" on public.ingredientes for update to authenticated
  using (public.puede_editar(local_id)) with check (public.puede_editar(local_id));

-- movimientos: leer y anotar; quien anota debe ser uno mismo
create policy "movimientos: leer"    on public.movimientos for select to authenticated
  using (public.es_miembro(local_id));
create policy "movimientos: anotar"  on public.movimientos for insert to authenticated
  with check (public.puede_editar(local_id)
              and creado_por = (select auth.uid()));

-- platos
create policy "platos: leer"         on public.platos for select to authenticated
  using (public.es_miembro(local_id));
create policy "platos: crear"        on public.platos for insert to authenticated
  with check (public.puede_editar(local_id));
create policy "platos: editar"       on public.platos for update to authenticated
  using (public.puede_editar(local_id)) with check (public.puede_editar(local_id));

-- receta_items (única tabla donde se borra de verdad: quitar de la receta)
create policy "receta: leer"         on public.receta_items for select to authenticated
  using (public.es_miembro(local_id));
create policy "receta: agregar"      on public.receta_items for insert to authenticated
  with check (public.puede_editar(local_id));
create policy "receta: editar"       on public.receta_items for update to authenticated
  using (public.puede_editar(local_id)) with check (public.puede_editar(local_id));
create policy "receta: quitar"       on public.receta_items for delete to authenticated
  using (public.puede_editar(local_id));


-- ---------- 9. Triggers: no mover filas ----------
create trigger no_mover before update on public.categorias
  for each row execute function public.impedir_mover_fila();
create trigger no_mover before update on public.ingredientes
  for each row execute function public.impedir_mover_fila();
create trigger no_mover before update on public.platos
  for each row execute function public.impedir_mover_fila();
create trigger no_mover before update on public.receta_items
  for each row execute function public.impedir_mover_fila();
-- movimientos no necesita: no se puede editar.


-- ---------- 10. PowerSync: puede leer y replicar las tablas nuevas ----------
grant select on public.categorias, public.ingredientes, public.movimientos,
                public.platos, public.receta_items
  to powersync_role;
alter publication powersync
  add table public.categorias, public.ingredientes, public.movimientos,
            public.platos, public.receta_items;


-- ---------- 11. crear_local() ahora también crea las categorías base ----------
-- En el servidor, para que dos teléfonos sin internet no creen "Otros" dos veces.
-- La regla "un local por usuario" sigue viviendo SOLO aquí.
create or replace function public.crear_local(p_nombre text)
returns public.locales
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_usuario uuid := auth.uid();
  v_nombre  text := btrim(p_nombre);
  v_local   public.locales;
begin
  if v_usuario is null then
    raise exception 'Debes iniciar sesión' using errcode = '42501';
  end if;

  if v_nombre is null or char_length(v_nombre) not between 1 and 60 then
    raise exception 'El nombre debe tener entre 1 y 60 caracteres'
      using errcode = '22023';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_usuario::text));
  if exists (select 1 from public.miembros where usuario_id = v_usuario) then
    raise exception 'Ya tienes un local' using errcode = '23505';
  end if;

  insert into public.locales (nombre)
  values (v_nombre)
  returning * into v_local;

  insert into public.miembros (local_id, usuario_id, rol)
  values (v_local.id, v_usuario, 'dueno');

  perform public._crear_categorias_base(v_local.id);

  return v_local;
end;
$$;

revoke all on function public.crear_local(text) from public, anon;
grant execute on function public.crear_local(text) to authenticated;


-- ---------- 12. Categorías base (helper interno) ----------
-- Solo la llaman crear_local y el relleno de abajo; nadie desde la app.
create or replace function public._crear_categorias_base(p_local_id uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.categorias (local_id, nombre, orden)
  select p_local_id, c.nombre, c.orden
  from unnest(array['Verduras', 'Carnes', 'Lácteos', 'Panes',
                    'Bebidas', 'Salsas', 'Envases'])
       with ordinality as c(nombre, orden)
  union all
  select p_local_id, 'Otros', 1000;
$$;

revoke all on function public._crear_categorias_base(uuid)
  from public, anon, authenticated;

-- Relleno: los locales ya creados (el tuyo) reciben sus categorías.
select public._crear_categorias_base(l.id)
from public.locales l
where not exists (select 1 from public.categorias c where c.local_id = l.id);

commit;


-- =============================================================
-- PRUEBAS (comentadas). Después de la migración, por bloques.
-- Igual que antes: UUID_A / UUID_B de auth.users, y el id del local
-- de cada uno: select l.id, l.nombre, m.usuario_id
--              from public.locales l join public.miembros m on m.local_id = l.id;
-- Si B no tiene local, créalo primero (bloque 2 de la migración anterior).
-- =============================================================

-- 1) Quedó todo publicado para PowerSync (esperado: 7 tablas)
-- select tablename from pg_publication_tables where pubname = 'powersync';

-- 1b) miembros tiene "id" como llave primaria (esperado: id)
-- select a.attname from pg_index i
-- join pg_attribute a on a.attrelid = i.indrelid and a.attnum = any(i.indkey)
-- where i.indrelid = 'public.miembros'::regclass and i.indisprimary;

-- 2) Tu local tiene sus 8 categorías
-- select c.nombre, c.orden from public.categorias c order by c.orden;

-- 3) A crea un ingrediente en SU local y anota un movimiento → OK
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_A","role":"authenticated"}', true);
--   insert into public.ingredientes (id, local_id, nombre, unidad)
--   values ('00000000-0000-0000-0000-0000000000a1', 'LOCAL_A', 'Pan', 'unidades');
--   insert into public.movimientos (local_id, ingrediente_id, tipo, cantidad, creado_por)
--   values ('LOCAL_A', '00000000-0000-0000-0000-0000000000a1', 'compra', 10, 'UUID_A');
--   select nombre from public.ingredientes;   -- esperado: Pan
-- rollback;

-- 4) B intenta crear un ingrediente en el local de A → ERROR (RLS)
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_B","role":"authenticated"}', true);
--   insert into public.ingredientes (local_id, nombre, unidad)
--   values ('LOCAL_A', 'Pirata', 'unidades');  -- esperado: new row violates row-level security
-- rollback;

-- 5) A no puede editar ni borrar movimientos → ERROR permission denied
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_A","role":"authenticated"}', true);
--   update public.movimientos set cantidad = 999;  -- esperado: permission denied
-- rollback;

-- 6) A anota un movimiento a nombre de B → ERROR (RLS)
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_A","role":"authenticated"}', true);
--   insert into public.ingredientes (id, local_id, nombre, unidad)
--   values ('00000000-0000-0000-0000-0000000000a2', 'LOCAL_A', 'Tomate', 'gramos');
--   insert into public.movimientos (local_id, ingrediente_id, tipo, cantidad, creado_por)
--   values ('LOCAL_A', '00000000-0000-0000-0000-0000000000a2', 'compra', 5, 'UUID_B');
--   -- esperado: new row violates row-level security
-- rollback;

-- 7) A intenta mover su categoría a otro local → ERROR (trigger)
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_A","role":"authenticated"}', true);
--   update public.categorias set local_id = 'LOCAL_B'
--   where nombre = 'Otros';  -- esperado: ERROR (trigger o RLS)
-- rollback;

-- 8) Una receta de A no puede usar un ingrediente de B → ERROR (llave doble)
--    (como postgres, crea antes un ingrediente en LOCAL_B y anota su id)
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_A","role":"authenticated"}', true);
--   insert into public.platos (id, local_id, nombre, precio_venta)
--   values ('00000000-0000-0000-0000-0000000000b1', 'LOCAL_A', 'Completo', 2500);
--   insert into public.receta_items (local_id, plato_id, ingrediente_id, cantidad)
--   values ('LOCAL_A', '00000000-0000-0000-0000-0000000000b1', 'ING_DE_B', 1);
--   -- esperado: violates foreign key constraint
-- rollback;

-- 9) Nadie puede llamar al helper de categorías → ERROR permission denied
-- begin;
--   set local role authenticated;
--   select public._crear_categorias_base('LOCAL_A');
-- rollback;
