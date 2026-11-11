# Rinde

**Cuánto vendes, cuánto gastas y cuánto te queda.**

Rinde es una app móvil para dueños de locales pequeños de comida en Chile
(completos, sándwiches, cafeterías). Reúne stock, recetas, costos y ventas
en un solo lugar y responde una pregunta: cuánto les queda.

> Estado: desarrollo temprano. Todavía no hay una versión usable.

## Qué busca ser
 - Un sistema de gestión fácil e intuitivo para locales que están partiendo, y no el sistema más completo.
 - Control interno: no cobra ni emite boletas.
 - Que se pueda registrar la primera venta en 2 minutos, sin manual.

## Qué incluirá
 - Ventas en el momento o varias a la vez, con nota y ajuste de precio.
 - Platos con ingredientes opcionales, y costo calculado cuando los hay.
 - Ingredientes con categoría, stock e historial de movimientos.
 - Resumen del día y estadísticas.

## Tecnología

- **App:** Flutter y Dart.
- **Datos locales:** Drift (SQLite). La app guarda todo en el teléfono y funciona sin internet.
- **Nube:** Supabase (autenticación y base de datos), sincronizada con la base local mediante PowerSync.

Por ahora, crear cuenta e iniciar sesión requiere conexión. Una vez dentro,
la app trabaja offline y sincroniza cuando vuelve la conexión.

## Avances

- **11/11/2026:** base de datos conectada a Supabase, con sincronización entre el teléfono y la nube.

## Sobre este proyecto

Rinde es mi primer proyecto personal. Lo uso para aprender en la práctica
desarrollo móvil, bases de datos locales, sincronización con la nube y otras tecnologías.

## Licencia

Todos los derechos reservados por ahora.
