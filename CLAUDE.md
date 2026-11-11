# Rinde

App para pequeños negocios de comida en Chile (completos, sándwiches, cafeterías, food trucks): stock, recetas, costos y ventas. Por ahora NO cobra ni emite boletas. Posicionamiento: opción simple, barata y fácil para locales emergentes, que crece por módulos (base → Rinde Teams → Rinde Menú). Diferencial: funciona sin internet (offline) y sincroniza a la nube.

## Cómo trabajar conmigo
- Responde siempre en español.
- Explica brevemente la lógica de lo que haces: estoy aprendiendo las tecnologías mientras construyo.
- Pasos pequeños. Pregunta antes de cambiar arquitectura, tablas o paquetes.
- Después de cada cambio corre `flutter analyze` y `flutter test`.
- Commits solo en una rama de trabajo, nunca directo a `main`.
- Si hay errores, lee el primero: suele causar los demás.

## Seguridad
- Nunca escribas la clave `service_role` de Supabase ni contraseñas de base de datos en el código ni en el repo.
- La `anon key` y la URL de Supabase van solo en un archivo de configuración ignorado por git.
- Toda tabla de negocio lleva el id del local y tiene Row Level Security (RLS) para que un local nunca vea datos de otro.

## Tecnologías
- Flutter/Dart, Riverpod (providers, StreamProvider, `.family`), Drift (SQLite local, `watch()`, migraciones `onUpgrade`, schemaVersion 5), build_runner, uuid, image_picker, path_provider.
- Nube (en prueba de concepto): Supabase (Postgres + Auth + RLS) y PowerSync (SQLite local sincronizado con Postgres, cola de subida con `uploadData()`).
- Capas: pantallas → estado (providers) → reglas (`logica/`) → datos (`datos/`).

## Estructura (por función)
- `lib/main.dart` arranque (inicia Supabase).
- `lib/app/` estructura (pestañas), puerta_sesion (login o app).
- `lib/comun/` lo compartido: `datos/` (base_de_datos.dart con tablas/migraciones/métodos, proveedores.dart con `baseDeDatosProvider`), `logica/` (costos, formato, medidas), `tema/` (colores, tema, cenefa; fuente Nunito en assets), `widgets/` (pantalla_vacia).
- `lib/funciones/<función>/`: ingredientes, platos, sesion, inicio, ventas. Cada función tiene sus pantallas, providers y lógica.
- Regla: subcarpetas (`datos/`, `logica/`, `pantallas/`) solo cuando la función tiene ~6 archivos o más; si no, queda plana.
- Imports siempre como `package:rinde/...` (no rutas relativas).
- `test/` platos_test.dart (los tests de costos están ahí).

## Reglas de negocio decididas
- Stock y costo se guardan en g / ml / u. El usuario elige kg, g, L, ml o unidades al ingresar.
- Costo promedio ponderado al comprar.
- Una venta congela costo y precio del momento.
- Se permite stock negativo.
- "Eliminar" = archivar, no borrar.
- No hay nombres duplicados (ingredientes ni categorías); se compara sin mayúsculas ni tildes.
- Categoría "Otros" siempre al final.
- Un solo tipo de plato; los ingredientes son opcionales (etiqueta "Sin ingredientes").
- Historial de movimientos por ingrediente.
- Operaciones compuestas van en transacción (todo o nada).
- Ids UUID.
- Ventas: "ahora" y "varias a la vez" (tramo del día), con nota y ajuste de precio (descuentos).

## Estado
- Hecho: ingredientes (categorías, filtros, orden, movimientos, compra, ajuste), platos con receta y foto opcional.
- Pendiente: ventas, inicio con resumen, respaldo (con fotos), pulido de diseño.
- Después: Rinde Teams (dueño/empleados), Rinde Menú (menú digital + pedidos por WhatsApp), landing con lista de espera, boleta electrónica (SII, sin investigar aún).

## Objetivo actual: prueba de concepto en rama `nube`
1. Login con Google (Supabase Auth).
2. Crear un local.
3. Crear un ingrediente sin internet.
4. Al volver internet, que se sincronice.
5. Verificar que otro usuario/local no lo ve (RLS).

## Comandos
- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter analyze`
- `flutter test`
- `flutter run -d emulator-5554`

## Plan
Prueba cerrada en Google Play a fines de diciembre (12 testers × 14 días), producción probable en enero. Teams/jerarquía como versión 2.
