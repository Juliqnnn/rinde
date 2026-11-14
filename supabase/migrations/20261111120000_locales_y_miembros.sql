-- =============================================================
-- Rinde · Locales y miembros (paso 2 de la prueba de concepto)
-- Ejecutar UNA vez en Supabase → SQL Editor.
-- =============================================================

-- ---------- Tablas ----------

create table public.locales (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null
              check (char_length(btrim(nombre)) between 1 and 60),
  creado_por  uuid not null default auth.uid()
              references auth.users (id),
  creado_en   timestamptz not null default now()
);

-- Quién pertenece a qué local. Hoy solo 'dueno'; 'empleado' es para Rinde Teams.
create table public.miembros (
  local_id    uuid not null references public.locales (id) on delete cascade,
  usuario_id  uuid not null references auth.users (id) on delete cascade,
  rol         text not null default 'dueno'
              check (rol in ('dueno', 'empleado')),
  creado_en   timestamptz not null default now(),
  primary key (local_id, usuario_id)
);

-- La PK sirve para buscar por local; este índice, para buscar por usuario
-- (es lo que consulta es_miembro y la app al abrir).
create index miembros_usuario_idx on public.miembros (usuario_id);

alter table public.locales  enable row level security;
alter table public.miembros enable row level security;

-- Supabase da permisos amplios por defecto en "public". Los recortamos:
-- anon (sin sesión) no toca nada; authenticated solo lee (y RLS filtra).
-- Crear locales/miembros se hace únicamente con crear_local().
revoke all on public.locales, public.miembros from anon;
revoke insert, update, delete, truncate
  on public.locales, public.miembros from authenticated;


-- ---------- es_miembro(local_id) ----------
-- SECURITY DEFINER: corre con permisos del dueño de la función, así lee
-- "miembros" SIN pasar por su RLS. Eso evita la recursión infinita que
-- ocurriría si la política de "miembros" consultara "miembros" con RLS.
-- search_path = '' obliga a escribir esquema.tabla y evita que alguien
-- "suplante" una tabla o función creando otra con el mismo nombre.
create or replace function public.es_miembro(p_local_id uuid)
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
  );
$$;

revoke all on function public.es_miembro(uuid) from public, anon;
grant execute on function public.es_miembro(uuid) to authenticated;


-- ---------- Políticas RLS (solo lectura) ----------

-- Ves un local solo si eres miembro.
create policy "locales: leer si soy miembro"
  on public.locales for select
  to authenticated
  using (public.es_miembro(id));

-- Ves los miembros de tus locales (hoy: solo a ti; con Teams: a tu equipo).
create policy "miembros: leer los de mis locales"
  on public.miembros for select
  to authenticated
  using (public.es_miembro(local_id));

-- Sin políticas de insert/update/delete: RLS las niega por defecto.


-- ---------- crear_local(nombre) ----------
-- Crea el local y agrega al usuario como dueño en UNA transacción
-- (todo o nada). El dueño sale de auth.uid(), nunca de un parámetro.
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

  -- Un local por usuario (por ahora). El candado evita que dos toques
  -- seguidos al botón creen dos locales. Para permitir varios locales
  -- basta con reemplazar esta función; las tablas no cambian.
  perform pg_advisory_xact_lock(hashtext(v_usuario::text));
  if exists (select 1 from public.miembros where usuario_id = v_usuario) then
    raise exception 'Ya tienes un local' using errcode = '23505';
  end if;

  -- creado_por toma su default: auth.uid()
  insert into public.locales (nombre)
  values (v_nombre)
  returning * into v_local;

  insert into public.miembros (local_id, usuario_id, rol)
  values (v_local.id, v_usuario, 'dueno');

  return v_local;
end;
$$;

revoke all on function public.crear_local(text) from public, anon;
grant execute on function public.crear_local(text) to authenticated;


-- =============================================================
-- PRUEBAS (comentadas). Ejecútalas por bloques, DESPUÉS de la migración.
-- El SQL Editor corre como "postgres" (se salta RLS), por eso cada bloque
-- se hace pasar por un usuario con: set local role + request.jwt.claims.
--
-- Necesitas dos usuarios reales en Authentication → Users
-- (tu cuenta de Google y otro creado con "Add user"). Sus ids:
--   select id, email from auth.users;
-- Reemplaza UUID_A y UUID_B abajo.
-- =============================================================

-- 1) Usuario A crea su local
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_A","role":"authenticated"}', true);
--   select * from public.crear_local('Local de A');
-- commit;

-- 2) Usuario B crea su local
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_B","role":"authenticated"}', true);
--   select * from public.crear_local('Local de B');
-- commit;

-- 3) B solo ve lo suyo
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_B","role":"authenticated"}', true);
--   select nombre from public.locales;             -- esperado: solo 'Local de B'
--   select local_id, rol from public.miembros;     -- esperado: 1 fila (su local)
--   select public.es_miembro(
--     (select id from public.locales limit 1));    -- esperado: true
-- rollback;

-- 4) B intenta "espiar" el local de A conociendo su id
--    (primero, como postgres: select id from public.locales where nombre = 'Local de A';)
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_B","role":"authenticated"}', true);
--   select * from public.locales where id = 'ID_LOCAL_A';  -- esperado: 0 filas
--   select public.es_miembro('ID_LOCAL_A');               -- esperado: false
-- rollback;

-- 5) B intenta saltarse crear_local e insertar directo
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_B","role":"authenticated"}', true);
--   insert into public.locales (nombre) values ('Pirata');  -- esperado: ERROR permission denied
-- rollback;

-- 6) A intenta crear un segundo local
-- begin;
--   set local role authenticated;
--   select set_config('request.jwt.claims',
--     '{"sub":"UUID_A","role":"authenticated"}', true);
--   select public.crear_local('Otro de A');   -- esperado: ERROR Ya tienes un local
-- rollback;

-- 7) Sin sesión (anon) no puede nada. Dos bloques: tras un error,
--    Postgres aborta la transacción y no probaría la segunda consulta.
-- begin;
--   set local role anon;
--   select public.crear_local('Anónimo');     -- esperado: ERROR permission denied for function
-- rollback;
-- begin;
--   set local role anon;
--   select * from public.locales;             -- esperado: ERROR permission denied for table
-- rollback;

-- 8) Limpieza (como postgres): borra los locales de prueba para que tu
--    cuenta pueda crear su local real desde la app.
-- delete from public.locales where nombre in ('Local de A', 'Local de B');
