import 'package:powersync/powersync.dart';

// Tablas del teléfono que maneja PowerSync.
//
// PowerSync guarda cada fila como JSON y crea una *vista* SQL con estas
// columnas. Por eso no hay migraciones en el teléfono: agregar una columna
// aquí basta. Los cambios "de verdad" viven en supabase/migrations.
//
// La columna "id" (texto) la agrega PowerSync sola en todas las tablas.
//
// Las clases de Drift en base_de_datos.dart describen estas MISMAS vistas:
// si cambias una columna aquí, cámbiala allá también.
//
// Tipos: PowerSync solo tiene text, integer y real.
// - Booleanos → integer (0/1).  - Fechas → text (ISO 8601).
const esquemaPowerSync = Schema([
  // ---------- Sincronizadas con Supabase ----------
  Table('locales', [
    Column.text('nombre'),
    Column.text('creado_por'),
    Column.text('creado_en'),
  ]),
  Table('miembros', [
    Column.text('local_id'),
    Column.text('usuario_id'),
    Column.text('rol'),
    Column.text('creado_en'),
  ]),
  Table('categorias', [
    Column.text('local_id'),
    Column.text('nombre'),
    Column.integer('orden'),
    Column.text('creado_en'),
    Column.text('actualizado_en'),
  ]),
  Table('ingredientes', [
    Column.text('local_id'),
    Column.text('nombre'),
    Column.text('categoria_id'),
    Column.text('unidad'),
    Column.real('stock_minimo'),
    Column.integer('archivado'),
    Column.text('creado_en'),
    Column.text('actualizado_en'),
    // TEMPORAL (hasta la etapa E): existen solo en el teléfono. Postgres no
    // las tiene; uploadData sube únicamente las columnas permitidas, así
    // que nunca viajan. En la etapa E se calculan desde movimientos.
    Column.real('stock'),
    Column.real('costo_unitario'),
  ]),

  // ---------- Solo en el teléfono, por ahora ----------
  // Ya llevan local_id: para sincronizarlas basta cambiar
  // Table.localOnly(...) por Table(...) (etapas E y F).
  Table.localOnly('movimientos', [
    Column.text('local_id'),
    Column.text('ingrediente_id'),
    Column.text('tipo'),
    Column.real('cantidad'),
    Column.real('costo_unitario'),
    Column.text('motivo'),
    Column.text('fecha'),
  ]),
  Table.localOnly('platos', [
    Column.text('local_id'),
    Column.text('nombre'),
    Column.real('precio_venta'),
    Column.real('costo_manual'),
    Column.text('foto'),
    Column.text('codigo_externo'),
    Column.integer('archivado'),
    Column.text('creado_en'),
    Column.text('actualizado_en'),
  ]),
  Table.localOnly('receta_items', [
    Column.text('local_id'),
    Column.text('plato_id'),
    Column.text('ingrediente_id'),
    Column.real('cantidad'),
  ]),
]);
