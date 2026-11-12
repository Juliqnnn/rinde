# Rinde · Plan paso 3: PowerSync (propuesta, sin ejecutar)

> Documento para revisar el plan. Nada de esto está implementado todavía.
> Fecha: 2026-11-12 · Rama de trabajo: `nube`

## Contexto del proyecto

**Rinde** es una app Flutter para pequeños negocios de comida en Chile (completos, sándwiches, cafeterías, food trucks): stock, recetas, costos y ventas. Su diferencial es que **funciona sin internet** y sincroniza a la nube.

- **Stack actual:** Flutter/Dart, Riverpod, Drift (SQLite local, `schemaVersion 5`), supabase_flutter, google_sign_in, shared_preferences.
- **Nube (prueba de concepto):** Supabase (Postgres + Auth + RLS) y PowerSync.
- **Futuro:** Rinde Teams (dueño y empleados con permisos) y dueños con **varios locales de una cadena**. El diseño no debe asumir "un local por usuario" salvo en un solo lugar.

### Ya hecho y probado
- Login con Google (Supabase Auth) en el emulador.
- Tablas `locales` y `miembros` con RLS, más las funciones `es_miembro(local_id)` (security definer) y `crear_local(nombre)`, que crea el local y agrega al dueño en una transacción. La app no puede insertar directo en esas tablas.
- La app crea el local y lo recuerda en el teléfono. La sesión persiste sin internet.
- Pruebas RLS con dos usuarios en el SQL Editor, todas OK: un usuario no ve datos de otro, no puede espiar un local por su id, no puede insertar directo, no puede crear un segundo local, y `anon` no puede nada.
- Android con `allowBackup="false"`, para que el token de sesión no viaje en respaldos.

### Esquema actual de Drift (solo local, sin `local_id`)
- `categorias`: id, nombre (unique), orden ("Otros" = 1000), creado_en, actualizado_en.
- `ingredientes`: id, nombre, categoria_id, unidad (gramos/mililitros/unidades), costo_unitario, stock, stock_minimo, archivado, fechas.
- `movimientos`: id, ingrediente_id, tipo (inicial/compra/ajuste/venta), cantidad (+ entra / − sale), costo_unitario, motivo, fecha.
- `platos`: id, nombre, precio_venta, costo_manual, foto, codigo_externo, archivado, fechas.
- `receta_items`: id, plato_id, ingrediente_id, cantidad.

Hoy `registrarCompra` y `ajustarStock` **sobrescriben** `stock` y `costo_unitario` en `ingredientes` y además anotan un movimiento.

### Reglas de negocio relevantes
Stock en g / ml / u · costo promedio ponderado al comprar · una venta congela costo y precio · se permite stock negativo · "eliminar" = archivar · no hay nombres duplicados (se compara sin mayúsculas ni tildes) · las operaciones compuestas van en transacción · ids UUID.

### Pasos de la prueba de concepto
1. ✅ Login con Google.
2. ✅ Crear un local.
3. Crear un ingrediente sin internet.
4. Al volver internet, que se sincronice.
5. Verificar que otro usuario o local no lo ve (RLS).

---

## Idea central: dos caminos, dos seguridades

| Camino | Lo hace | Quién lo protege |
|---|---|---|
| **Bajada** (nube → teléfono) | PowerSync lee Postgres con su propio rol, que **se salta RLS** | Las **Sync Streams**: deciden qué filas recibe cada usuario |
| **Subida** (teléfono → nube) | `uploadData()` escribe con la sesión del usuario | **RLS** con `es_miembro(local_id)` |

Las Streams y las políticas RLS deben decir lo mismo. Si una Stream está mal escrita, RLS no protege la bajada. Esto es lo más importante a revisar en cada etapa.

---

## 1. Lo que hace el usuario en Supabase y en el panel de PowerSync

**Etapa A. Sin código. Solo se sincroniza `locales` para probar la conexión.**

1. Supabase → **SQL Editor**. **La contraseña la inventa el usuario y nunca va al repo**: se guarda en un gestor de contraseñas. Solo letras y números, porque `@ : / # %` rompen la cadena de conexión.
   ```sql
   -- Rol de SOLO LECTURA para PowerSync. bypassrls: lee todo para poder
   -- repartir; quien filtra son las Sync Streams.
   create role powersync_role with replication bypassrls login
     password 'INVENTA_UNA_CONTRASEÑA_LARGA';
   grant usage on schema public to powersync_role;
   grant select on public.locales, public.miembros to powersync_role;

   -- Publicación: lista SOLO las tablas que se sincronizan (no "for all
   -- tables", así una tabla nueva no se replica por accidente).
   create publication powersync for table public.locales, public.miembros;
   ```
   Cada tabla nueva se agrega después a la publicación, en su migración (`alter publication powersync add table ...`).
2. Crear la cuenta en PowerSync (plan gratis) y una instancia de desarrollo.
3. **Conexión a la base:** el panel pide la cadena de conexión de Supabase con el usuario `powersync_role` y la contraseña del paso 1. La contraseña va solo en el panel.
4. **Autenticación de clientes:** activar **"Use Supabase Auth"**. Así PowerSync acepta el mismo token de sesión que ya usa la app.
5. **Sync Streams** de prueba:
   ```yaml
   config:
     edition: 3
   streams:
     mis_locales:
       auto_subscribe: true
       query: |
         SELECT * FROM locales
         WHERE id IN (SELECT local_id FROM miembros WHERE usuario_id = auth.user_id())
   ```
6. Copiar la **URL de la instancia** a `config.json` (ignorado por git) como `POWERSYNC_URL`.

Todavía no se sincroniza `miembros`. PowerSync exige una columna `id` en cada fila sincronizada, y `miembros` tiene una llave doble (`local_id` + `usuario_id`). Se le agrega en la etapa B.

---

## 2. Agregar `local_id` y crear las tablas en Supabase

**Recomendación: no hacer una migración de Drift a schemaVersion 6.** Con PowerSync, las tablas del teléfono son *vistas* que crea PowerSync a partir de un esquema en código. Las migraciones de Drift ya no aplican a esas tablas: cambiar ese esquema no requiere migración local, porque los cambios de verdad viven en las migraciones de Postgres. Una versión 6 con `local_id` en Drift sería trabajo que se tira a la semana.

**Etapa B. Una migración SQL nueva:**
- **Arreglos de seguridad pendientes:**
  - `alter default privileges` para que las tablas nuevas nazcan sin permisos para `anon`.
  - `locales.creado_por ... on delete set null`, para que se pueda borrar una cuenta (lo exige Google Play).
- **`miembros`:** `id uuid` pasa a ser la **llave primaria** y `(local_id, usuario_id)` queda como `unique`. PowerSync no soporta llaves compuestas, y con `REPLICA IDENTITY DEFAULT` los borrados se informan solo con la llave primaria.
- **Tablas `categorias`, `ingredientes`, `movimientos`, `platos`, `receta_items`:**
  - `id uuid` y `local_id not null references locales`.
  - **Todas** llevan su propio `local_id`, también `movimientos` y `receta_items`. Así la RLS y las Streams son un simple `local_id = ...`, sin joins.
  - Tipos compatibles con SQLite: `text`, `double precision`, `integer`, `boolean`, `timestamptz`. Nada de `numeric`, porque PowerSync lo baja como texto.
  - `unidad` y `tipo` como `text` con `check`.
  - Cada tabla se agrega a la publicación y con `grant select` a `powersync_role`.
- **Políticas RLS por acción, no una sola "all":**
  - `select`: `es_miembro(local_id)`.
  - `insert`, `update`: llaman a una función **`puede_editar(local_id)`**. Hoy es igual a `es_miembro`. Con Teams solo cambia esa función (por ejemplo, empleado puede vender pero no editar recetas) y no hay que tocar ninguna política.
  - En `update`, `using` y `with check` impiden mover una fila a otro local.
  - `movimientos`: **solo insert**, sin update ni delete. Un historial no se edita.
  - Sin políticas de `delete`, salvo `receta_items`. "Eliminar" es archivar.
- **`crear_local()`** también crea las categorías base y "Otros" en el servidor. Si las creara el teléfono, dos teléfonos sin internet crearían "Otros" dos veces.
- **Nombres duplicados:** SQLite dentro de PowerSync no admite `unique`. Además, un `unique` en Postgres trabaría la cola de subida cuando dos teléfonos sin internet crean el mismo nombre. Propuesta: validar en la app, como hoy (sin mayúsculas ni tildes), y **no** poner `unique` en Postgres. En el caso raro de duplicado, más adelante se ofrece "unir".

**Dónde queda "un local por usuario":** solo en el `if exists` de `crear_local()`. Las tablas, las Streams y la RLS soportan varios locales y varios miembros desde ya.

**Pregunta abierta:** ¿los datos actuales de Drift se traspasan o se empieza de cero? Si son datos de prueba, empezar de cero es más simple y no tiene riesgo. Si se quieren conservar, se agrega un traspaso de una sola vez desde `rinde.sqlite` hacia el local.

---

## 3. Conectar Drift con PowerSync

**Paquetes, a aprobar en su momento:**
- **Agregar** `powersync` y `drift_sqlite_async`. Este último es el puente oficial: Drift corre *sobre* la base de PowerSync, así que siguen funcionando `watch()`, `transaction()` y las consultas tipadas.
- **Quitar** `drift_flutter` (y `sqlite3_flutter_libs` si aparece), porque PowerSync trae su propio SQLite y no deben convivir dos.

**Cambios:**
- **Esquema doble:** un `Schema` de PowerSync en Dart define las tablas reales. Las clases de Drift (`Ingredientes`, etc.) **describen** esas mismas vistas y deben coincidir columna por columna. `onCreate` de Drift ya no crea tablas, porque eso lo hace PowerSync.
- **Fechas:** `build.yaml` con `store_date_time_values_as_text: true`, porque Postgres las baja como texto ISO. Hay que probar que se lean bien.
- **Llaves foráneas:** se pierden `.references()` y `PRAGMA foreign_keys`, porque las vistas no las soportan. La integridad la cuidan los métodos de `BaseDeDatos`, dentro de transacciones, y Postgres arriba.
- **Local activo:** cada método recibe o usa el `local_id` del **local activo**. Ese local se elige entre los que bajan sincronizados y se recuerda en `shared_preferences` (solo su id). El `LocalRepositorio` actual se simplifica: la tabla `locales` sincronizada reemplaza la copia guardada en JSON.
- **Cerrar sesión:** llama a `disconnectAndClear()`, que borra los datos del teléfono. Hoy otra cuenta en el mismo teléfono ve los ingredientes de Drift de la anterior; con esto ya no.

**Para la prueba de concepto:** primero solo `categorias` e `ingredientes` (nombre y unidad) pasan a PowerSync, y se prueban los pasos 3 a 5. Platos, recetas y movimientos se mueven después, en una etapa aparte.

---

## 4. `uploadData()` y Sync Streams

**`fetchCredentials()`** entrega la URL de PowerSync y el `accessToken` de la sesión de Supabase. Si no hay sesión, devuelve `null`.

**`uploadData()`**: toma una transacción completa de la cola y la aplica en orden:
```dart
final tx = await db.getNextCrudTransaction();
if (tx == null) return;
for (final op in tx.crud) {
  final tabla = supabase.from(op.table);
  switch (op.op) {
    case UpdateType.put:    await tabla.upsert({...op.opData!, 'id': op.id});
    case UpdateType.patch:  await tabla.update(op.opData!).eq('id', op.id); // solo columnas cambiadas
    case UpdateType.delete: await tabla.delete().eq('id', op.id);
  }
}
await tx.complete();
```
- **Error de red:** se relanza y PowerSync reintenta solo.
- **Error permanente** (RLS negó, dato inválido: códigos `42501`, `22xxx`, `23xxx`): se **guarda** en una tabla solo local, `subidas_rechazadas`, y se completa la transacción. Si no, la cola queda trabada para siempre. Luego se muestra un aviso.
- **`patch` sube solo las columnas que cambiaron.** Si un teléfono cambia el nombre y otro la categoría, se conservan los dos cambios. Si los dos cambian lo mismo, gana el último en subir.

**Sync Streams completas**, pensadas para cadenas de locales:
```yaml
config:
  edition: 3
streams:
  # Siempre: mis locales y sus miembros (poca data). Sirve para elegir local.
  mis_locales:
    auto_subscribe: true
    with:
      mios: SELECT local_id FROM miembros WHERE usuario_id = auth.user_id()
    queries:
      - SELECT * FROM locales  WHERE id IN mios
      - SELECT * FROM miembros WHERE local_id IN mios

  # Solo el local abierto: la app se suscribe con su id.
  datos_local:
    with:
      mios: SELECT local_id FROM miembros WHERE usuario_id = auth.user_id()
    queries:
      - SELECT * FROM categorias   WHERE local_id = subscription.parameter('local_id') AND local_id IN mios
      - SELECT * FROM ingredientes WHERE local_id = subscription.parameter('local_id') AND local_id IN mios
      # ... movimientos, platos, receta_items igual
```
- El `AND local_id IN mios` es la cerradura. Sin él, cualquiera podría pedir el id de un local ajeno. Se prueba en el paso 5 con dos usuarios.
- Un dueño con 10 locales baja solo el que tiene abierto, no los 10.
- Las Sync Streams son nuevas en PowerSync, así que hay que confirmar la sintaxis contra la documentación al llegar a esta etapa.

---

## 5. Conflictos de stock: basarse en movimientos

- **`ingredientes` deja de guardar `stock` y `costo_unitario`.** Se **calculan** desde `movimientos`, que es una tabla de solo inserción. Insertar filas con UUID nunca choca: dos teléfonos sin internet que venden completos generan filas distintas, y al sincronizar se suman las dos. No se pierde nada.
- **Stock** = `SUM(cantidad)` de los movimientos del ingrediente. Es una consulta local con `watch()`, así que sigue en tiempo real.
- **Costo promedio ponderado** = una función pura en `logica/costos.dart` que recorre los movimientos por fecha. Lleva tests, y da el mismo resultado en todos los teléfonos una vez sincronizados.
- **Ajuste:** el movimiento guarda **la diferencia** (como hoy) y además el **conteo real** en una columna nueva. El caso raro: dos personas cuentan el mismo ingrediente sin internet y las dos anotan −2, entonces queda −4. Con el conteo guardado se puede detectar y avisar. Si en el futuro molesta, el stock se puede calcular como "último conteo + movimientos posteriores" sin cambiar las tablas.
- **Venta:** cada plato vendido genera movimientos `venta` con el costo congelado.
- **Riesgo futuro:** recalcular el promedio con mucho historial (ver "Riesgos futuros").

---

## Orden de etapas (cada una se aprueba antes de ejecutarla)

| Etapa | Qué | Quién |
|---|---|---|
| **A** | Rol, publicación, cuenta de PowerSync, Stream de `locales` | Usuario (con el SQL de arriba) |
| **B** | Migración SQL: tablas de negocio, RLS, `puede_editar`, arreglos de seguridad | Claude la escribe, el usuario la revisa y la pega |
| **C** | Paquetes + Drift sobre PowerSync + local activo + `categorias`/`ingredientes` | Claude |
| **D** | `uploadData`, `fetchCredentials`, Streams completas, cerrar sesión con borrado → **pasos 3 y 4 de la prueba de concepto** | Claude + el usuario prueba sin internet |
| **E** | Stock y costo desde movimientos (con tests) | Claude |
| **F** | Platos y recetas a PowerSync + **paso 5 de la prueba de concepto** (RLS con dos usuarios) | Claude + usuario |

## Otros pendientes de seguridad (de una revisión previa)
- **Firma de la app:** hoy la versión release se firma con la clave de debug. Antes de Google Play hay que crear una *upload key*. Git ya ignora `*.jks` y `key.properties`.
- **Sesión sin cifrar:** se guarda en el teléfono en shared_preferences. Con el respaldo apagado el riesgo es bajo. Opcional: `flutter_secure_storage`.
- **En el panel de Supabase:**
  - Desactivar el proveedor **Email** si solo se usa Google.
  - Revisar los **Client IDs** de Google.
  - Revisar el **Security Advisor**.

## Decisiones (aprobadas 2026-11-12)
1. Plan aprobado. Cada etapa espera confirmación antes de pasar a la siguiente.
2. **Datos de Drift:** se empieza de cero, sin traspaso.
3. **Nombres:** sin `unique` en Postgres; se valida solo en la app.
4. **Stock y costo:** se calculan desde movimientos.
5. **Contraseña de `powersync_role`:** solo letras y números (nada de `@ : / # %`, que rompen la cadena de conexión).
6. **Etapas C y D:** no se construyen funciones nuevas sobre el stock o costo sobrescritos en `ingredientes`, porque eso se reemplaza en la etapa E. Lo existente se migra tal cual o se deja fuera hasta E.

## Pendientes antes de publicar
- **Cuenta borrada del único miembro:** al borrar un usuario, sus filas en `miembros` se borran en cascada y `locales.creado_por` queda en null. Si era el **único** miembro, el local y todos sus datos quedan **huérfanos**: nadie los ve, pero siguen guardados. Eso choca con la política de Google Play de borrar los datos del usuario y ocupa espacio. Opciones a decidir:
  - Función `borrar_mi_cuenta()` (security definer) que borre primero los locales donde el usuario es el único dueño (los datos caen en cascada) y después el usuario.
  - Si hay otros miembros, traspasar el rol de dueño o impedir el borrado hasta designar otro dueño (relevante con Teams).
  - Además, un proceso periódico que detecte locales sin miembros.
- **Firma de la app:** crear la *upload key* (ver "Otros pendientes de seguridad").

## Riesgos futuros
- **Costo promedio con mucho historial:** recalcularlo recorriendo todos los movimientos se vuelve lento con miles de filas por ingrediente. Opciones cuando duela:
  - **"Cierres":** un movimiento de tipo cierre con stock y costo acumulados; se recalcula solo desde el último.
  - **Caché local** del resultado, que se invalida al llegar movimientos nuevos.
  - Medirlo antes de optimizar.

## Fuentes
- [PowerSync + Supabase (guía de integración)](https://docs.powersync.com/integration-guides/supabase-+-powersync)
- [Sync Streams: consultas](https://docs.powersync.com/sync/streams/queries)
- [Sync Streams: introducción](https://docs.powersync.com/sync/streams)
- [PowerSync con Drift (ORM en Flutter)](https://docs.powersync.com/client-sdks/orms/flutter-orm-support)
- [drift_sqlite_async en pub.dev](https://pub.dev/packages/drift_sqlite_async)
