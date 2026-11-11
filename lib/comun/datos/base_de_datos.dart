import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:rinde/comun/logica/costos.dart';

part 'base_de_datos.g.dart';

const _uuid = Uuid();

enum Unidad { gramos, mililitros, unidades }

enum TipoMovimiento { inicial, compra, ajuste, venta }

class Categorias extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get nombre => text().unique()();
  // Posición en las listas. "Otros" siempre es la última (1000).
  IntColumn get orden => integer().withDefault(const Constant(0))();
  DateTimeColumn get creadoEn =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get actualizadoEn =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

class Ingredientes extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get nombre => text()();
  TextColumn get categoriaId =>
      text().nullable().references(Categorias, #id)();
  TextColumn get unidad => textEnum<Unidad>()();
  RealColumn get costoUnitario => real().withDefault(const Constant(0))();
  RealColumn get stock => real().withDefault(const Constant(0))();
  RealColumn get stockMinimo => real().withDefault(const Constant(0))();
  BoolColumn get archivado => boolean().withDefault(const Constant(false))();
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
  TextColumn get ingredienteId => text().references(Ingredientes, #id)();
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
  TextColumn get nombre => text()();
  RealColumn get precioVenta => real()();
  // Costo escrito a mano. Solo se usa si el plato no tiene ingredientes.
  RealColumn get costoManual => real().withDefault(const Constant(0))();
  // Nombre del archivo de la foto (vive en la carpeta de la app).
  TextColumn get foto => text().nullable()();
  // Para emparejar con apps de delivery más adelante.
  TextColumn get codigoExterno => text().nullable()();
  BoolColumn get archivado => boolean().withDefault(const Constant(false))();
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
  TextColumn get platoId => text().references(Platos, #id)();
  TextColumn get ingredienteId => text().references(Ingredientes, #id)();
  // Cuánto lleva UN plato, en g, ml o unidades.
  RealColumn get cantidad => real()();

  @override
  Set<Column> get primaryKey => {id};
}

const _categoriasBase = [
  'Verduras', 'Carnes', 'Lácteos', 'Panes', 'Bebidas', 'Salsas', 'Envases',
];

@DriftDatabase(
    tables: [Categorias, Ingredientes, Movimientos, Platos, RecetaItems])
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos() : super(driftDatabase(name: 'rinde'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await batch((b) {
        b.insertAll(categorias, [
          for (var i = 0; i < _categoriasBase.length; i++)
            CategoriasCompanion.insert(
              nombre: _categoriasBase[i],
              orden: Value(i + 1),
            ),
          CategoriasCompanion.insert(
              nombre: 'Otros', orden: const Value(1000)),
        ]);
      });
    },
    onUpgrade: (m, desde, hasta) async {
      if (desde < 2) await m.createTable(movimientos);
      if (desde < 3) {
        await m.addColumn(categorias, categorias.orden);
        // Las categorías que ya existen reciben su posición.
        final todas = await (select(categorias)
          ..orderBy([(c) => OrderingTerm.asc(c.creadoEn)]))
            .get();
        var extra = 100;
        for (final c in todas) {
          final i = _categoriasBase.indexOf(c.nombre);
          final orden =
          c.nombre == 'Otros' ? 1000 : (i >= 0 ? i + 1 : extra++);
          await (update(categorias)..where((x) => x.id.equals(c.id)))
              .write(CategoriasCompanion(orden: Value(orden)));
        }
      }
      if (desde < 4) {
        await m.createTable(platos);
        await m.createTable(recetaItems);
      }
      if (desde < 5) {
        await m.addColumn(platos, platos.foto);
      }
    },
    beforeOpen: (detalles) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // La categoría nueva va al final de las tuyas, antes de "Otros".
  Future<String> crearCategoria(String nombre) async {
    final maxOrden = categorias.orden.max();
    final fila = await (selectOnly(categorias)
      ..addColumns([maxOrden])
      ..where(categorias.orden.isSmallerThanValue(1000)))
        .getSingle();
    final siguiente = (fila.read(maxOrden) ?? 0) + 1;

    final id = _uuid.v4();
    await into(categorias).insert(CategoriasCompanion.insert(
      id: Value(id),
      nombre: nombre,
      orden: Value(siguiente),
    ));
    return id;
  }

  Future<Ingrediente> ingredientePorId(String id) =>
      (select(ingredientes)..where((i) => i.id.equals(id))).getSingle();

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
        nombre: nombre,
        unidad: unidad,
        categoriaId: Value(categoriaId),
        costoUnitario: Value(costoUnitario),
        stock: Value(stock),
      ));
      if (stock > 0) {
        await into(movimientos).insert(MovimientosCompanion.insert(
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
    return (update(ingredientes)..where((i) => i.id.equals(id))).write(
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
      final ing = await (select(ingredientes)
        ..where((i) => i.id.equals(ingredienteId)))
          .getSingle();
      final costoCompra = precioTotal / cantidad;
      final nuevoCosto = costoPromedio(
        stockActual: ing.stock,
        costoActual: ing.costoUnitario,
        cantidadNueva: cantidad,
        costoNuevo: costoCompra,
      );
      await (update(ingredientes)..where((i) => i.id.equals(ingredienteId)))
          .write(IngredientesCompanion(
        stock: Value(ing.stock + cantidad),
        costoUnitario: Value(nuevoCosto),
        actualizadoEn: Value(DateTime.now()),
      ));
      await into(movimientos).insert(MovimientosCompanion.insert(
        ingredienteId: ingredienteId,
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
      final ing = await (select(ingredientes)
        ..where((i) => i.id.equals(ingredienteId)))
          .getSingle();
      final diferencia = stockReal - ing.stock;
      if (diferencia == 0) return;
      await (update(ingredientes)..where((i) => i.id.equals(ingredienteId)))
          .write(IngredientesCompanion(
        stock: Value(stockReal),
        actualizadoEn: Value(DateTime.now()),
      ));
      await into(movimientos).insert(MovimientosCompanion.insert(
        ingredienteId: ingredienteId,
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
        nombre: nombre,
        precioVenta: precioVenta,
        costoManual: Value(costoManual),
        foto: Value(foto),
      ));
      for (final r in receta) {
        await into(recetaItems).insert(RecetaItemsCompanion.insert(
          platoId: id,
          ingredienteId: r.ingredienteId,
          cantidad: r.cantidad,
        ));
      }
    });
  }

  Future<void> cambiarFotoPlato(String platoId, String? foto) {
    return (update(platos)..where((p) => p.id.equals(platoId))).write(
      PlatosCompanion(
        foto: Value(foto),
        actualizadoEn: Value(DateTime.now()),
      ),
    );
  }

  Future<void> archivarPlato(String id) {
    return (update(platos)..where((p) => p.id.equals(id))).write(
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
  }) async {
    final existente = await (select(recetaItems)
      ..where((r) =>
      r.platoId.equals(platoId) &
      r.ingredienteId.equals(ingredienteId)))
        .getSingleOrNull();
    if (existente == null) {
      await into(recetaItems).insert(RecetaItemsCompanion.insert(
        platoId: platoId,
        ingredienteId: ingredienteId,
        cantidad: cantidad,
      ));
    } else {
      await (update(recetaItems)..where((r) => r.id.equals(existente.id)))
          .write(RecetaItemsCompanion(
          cantidad: Value(existente.cantidad + cantidad)));
    }
  }

  Future<void> quitarDeReceta(String id) {
    return (delete(recetaItems)..where((r) => r.id.equals(id))).go();
  }
}