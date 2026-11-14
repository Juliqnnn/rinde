import 'package:drift/drift.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;
import 'package:uuid/uuid.dart';
import 'package:rinde/comun/logica/costos.dart';

part 'base_de_datos.g.dart';

const _uuid = Uuid();

enum Unidad { gramos, mililitros, unidades }

enum TipoMovimiento { inicial, compra, ajuste, venta }

// IMPORTANTE: estas clases NO crean tablas. Describen las vistas que crea
// PowerSync (ver esquema_powersync.dart) y deben coincidir columna por
// columna. Por lo mismo:
// - Sin .withDefault(): las vistas no tienen valores por defecto de SQL.
//   Se usa .clientDefault(), que lo pone Dart al insertar.
// - Sin .unique() ni .references(): las vistas no los soportan. Los
//   duplicados se validan en la app y la integridad la cuidan los métodos
//   de abajo (en transacción) y Postgres al subir.

// Lee NULL como 0. Sirve para stock y costo_unitario, que existen solo en
// el teléfono: un ingrediente que baja de la nube los trae vacíos.
class _CeroSiNulo extends TypeConverter<double, double?> {
  const _CeroSiNulo();
  @override
  double fromSql(double? valor) => valor ?? 0;
  @override
  double? toSql(double valor) => valor;
}

class Categorias extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get localId => text()();
  TextColumn get nombre => text()();
  // Posición en las listas. "Otros" siempre es la última (1000).
  IntColumn get orden => integer().clientDefault(() => 0)();
  DateTimeColumn get creadoEn =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get actualizadoEn =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

class Ingredientes extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get localId => text()();
  TextColumn get nombre => text()();
  TextColumn get categoriaId => text().nullable()();
  TextColumn get unidad => textEnum<Unidad>()();
  // TEMPORAL (hasta la etapa E): solo en el teléfono, no se suben.
  RealColumn get costoUnitario => real()
      .nullable()
      .map(const _CeroSiNulo())
      .clientDefault(() => 0)();
  RealColumn get stock => real()
      .nullable()
      .map(const _CeroSiNulo())
      .clientDefault(() => 0)();
  RealColumn get stockMinimo => real().clientDefault(() => 0)();
  BoolColumn get archivado => boolean().clientDefault(() => false)();
  DateTimeColumn get creadoEn =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get actualizadoEn =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

// Historial: cada vez que el stock cambia, queda una fila aquí.
class Movimientos extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get localId => text()();
  TextColumn get ingredienteId => text()();
  TextColumn get tipo => textEnum<TipoMovimiento>()();
  // Positivo = entra stock, negativo = sale (en g, ml o unidades).
  RealColumn get cantidad => real()();
  RealColumn get costoUnitario => real().nullable()();
  TextColumn get motivo => text().nullable()();
  DateTimeColumn get fecha =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

class Platos extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get localId => text()();
  TextColumn get nombre => text()();
  RealColumn get precioVenta => real()();
  // Costo escrito a mano. Solo se usa si el plato no tiene ingredientes.
  RealColumn get costoManual => real().clientDefault(() => 0)();
  // Nombre del archivo de la foto (vive en la carpeta de la app).
  TextColumn get foto => text().nullable()();
  // Para emparejar con apps de delivery más adelante.
  TextColumn get codigoExterno => text().nullable()();
  BoolColumn get archivado => boolean().clientDefault(() => false)();
  DateTimeColumn get creadoEn =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get actualizadoEn =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

// Une platos con ingredientes: una fila por ingrediente de cada receta.
class RecetaItems extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get localId => text()();
  TextColumn get platoId => text()();
  TextColumn get ingredienteId => text()();
  // Cuánto lleva UN plato, en g, ml o unidades.
  RealColumn get cantidad => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// La base de datos del teléfono, vista desde UN local (el activo).
///
/// Drift corre sobre la base de PowerSync ([SqliteAsyncDriftConnection]):
/// se mantienen las consultas tipadas, watch() y transaction(), y los
/// watch() también se enteran de lo que baja sincronizado.
///
/// Todo lo que se crea aquí lleva [localId], y las consultas filtran por él.
@DriftDatabase(
    tables: [Categorias, Ingredientes, Movimientos, Platos, RecetaItems])
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos(PowerSyncDatabase conexion, {required this.localId})
      : super(SqliteAsyncDriftConnection(conexion));

  final String localId;

  // Las tablas las crea y "migra" PowerSync desde esquemaPowerSync.
  // Drift no crea ni altera nada, así que no hay migraciones aquí.
  // (Las categorías base las crea crear_local() en el servidor.)
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {},
        onUpgrade: (m, desde, hasta) async {},
      );

  // La categoría nueva va al final de las tuyas, antes de "Otros".
  Future<String> crearCategoria(String nombre) async {
    final maxOrden = categorias.orden.max();
    final fila = await (selectOnly(categorias)
      ..addColumns([maxOrden])
      ..where(categorias.localId.equals(localId) &
          categorias.orden.isSmallerThanValue(1000)))
        .getSingle();
    final siguiente = (fila.read(maxOrden) ?? 0) + 1;

    final id = _uuid.v4();
    await into(categorias).insert(CategoriasCompanion.insert(
      id: Value(id),
      localId: localId,
      nombre: nombre,
      orden: Value(siguiente),
    ));
    return id;
  }

  Future<Ingrediente> ingredientePorId(String id) => (select(ingredientes)
        ..where((i) => i.id.equals(id) & i.localId.equals(localId)))
      .getSingle();

  // Crea el ingrediente y, si hay stock, anota el primer movimiento.
  // Devuelve el id del ingrediente creado.
  Future<String> crearIngrediente({
    required String nombre,
    required Unidad unidad,
    String? categoriaId,
    double costoUnitario = 0,
    double stock = 0,
    TipoMovimiento tipo = TipoMovimiento.inicial,
  }) {
    return transaction(() async {
      final id = _uuid.v4();
      await into(ingredientes).insert(IngredientesCompanion.insert(
        id: Value(id),
        localId: localId,
        nombre: nombre,
        unidad: unidad,
        categoriaId: Value(categoriaId),
        costoUnitario: Value(costoUnitario),
        stock: Value(stock),
      ));
      if (stock > 0) {
        await into(movimientos).insert(MovimientosCompanion.insert(
          localId: localId,
          ingredienteId: id,
          tipo: tipo,
          cantidad: stock,
          costoUnitario: Value(costoUnitario),
        ));
      }
      return id;
    });
  }

  Future<void> archivarIngrediente(String id) {
    return (update(ingredientes)
          ..where((i) => i.id.equals(id) & i.localId.equals(localId)))
        .write(
      IngredientesCompanion(
        archivado: const Value(true),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  Future<void> registrarCompra({
    required String ingredienteId,
    required double cantidad, // en g, ml o u
    required double precioTotal,
  }) {
    return transaction(() async {
      final ing = await ingredientePorId(ingredienteId);
      final costoCompra = precioTotal / cantidad;
      final nuevoCosto = costoPromedio(
        stockActual: ing.stock,
        costoActual: ing.costoUnitario,
        cantidadNueva: cantidad,
        costoNuevo: costoCompra,
      );
      await (update(ingredientes)..where((i) => i.id.equals(ing.id)))
          .write(IngredientesCompanion(
        stock: Value(ing.stock + cantidad),
        costoUnitario: Value(nuevoCosto),
        actualizadoEn: Value(DateTime.now()),
      ));
      await into(movimientos).insert(MovimientosCompanion.insert(
        localId: localId,
        ingredienteId: ing.id,
        tipo: TipoMovimiento.compra,
        cantidad: cantidad,
        costoUnitario: Value(costoCompra),
      ));
    });
  }

  Future<void> ajustarStock({
    required String ingredienteId,
    required double stockReal,
    required String motivo,
  }) {
    return transaction(() async {
      final ing = await ingredientePorId(ingredienteId);
      final diferencia = stockReal - ing.stock;
      if (diferencia == 0) return;
      await (update(ingredientes)..where((i) => i.id.equals(ing.id)))
          .write(IngredientesCompanion(
        stock: Value(stockReal),
        actualizadoEn: Value(DateTime.now()),
      ));
      await into(movimientos).insert(MovimientosCompanion.insert(
        localId: localId,
        ingredienteId: ing.id,
        tipo: TipoMovimiento.ajuste,
        cantidad: diferencia,
        costoUnitario: Value(ing.costoUnitario),
        motivo: Value(motivo),
      ));
    });
  }

  // Crea el plato y su receta (si la tiene) en una sola transacción.
  Future<void> crearPlato({
    required String nombre,
    required double precioVenta,
    double costoManual = 0,
    String? foto,
    List<({String ingredienteId, double cantidad})> receta = const [],
  }) {
    return transaction(() async {
      final id = _uuid.v4();
      await into(platos).insert(PlatosCompanion.insert(
        id: Value(id),
        localId: localId,
        nombre: nombre,
        precioVenta: precioVenta,
        costoManual: Value(costoManual),
        foto: Value(foto),
      ));
      for (final r in receta) {
        await into(recetaItems).insert(RecetaItemsCompanion.insert(
          localId: localId,
          platoId: id,
          ingredienteId: r.ingredienteId,
          cantidad: r.cantidad,
        ));
      }
    });
  }

  Future<void> cambiarFotoPlato(String platoId, String? foto) {
    return (update(platos)
          ..where((p) => p.id.equals(platoId) & p.localId.equals(localId)))
        .write(
      PlatosCompanion(
        foto: Value(foto),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  Future<void> archivarPlato(String id) {
    return (update(platos)
          ..where((p) => p.id.equals(id) & p.localId.equals(localId)))
        .write(
      PlatosCompanion(
        archivado: const Value(true),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  // Si el ingrediente ya estaba en la receta, suma la cantidad.
  Future<void> agregarAReceta({
    required String platoId,
    required String ingredienteId,
    required double cantidad,
  }) {
    return transaction(() async {
      final existente = await (select(recetaItems)
            ..where((r) =>
                r.localId.equals(localId) &
                r.platoId.equals(platoId) &
                r.ingredienteId.equals(ingredienteId)))
          .getSingleOrNull();
      if (existente == null) {
        await into(recetaItems).insert(RecetaItemsCompanion.insert(
          localId: localId,
          platoId: platoId,
          ingredienteId: ingredienteId,
          cantidad: cantidad,
        ));
      } else {
        await (update(recetaItems)..where((r) => r.id.equals(existente.id)))
            .write(RecetaItemsCompanion(
                cantidad: Value(existente.cantidad + cantidad)));
      }
    });
  }

  Future<void> quitarDeReceta(String id) {
    return (delete(recetaItems)
          ..where((r) => r.id.equals(id) & r.localId.equals(localId)))
        .go();
  }
}
