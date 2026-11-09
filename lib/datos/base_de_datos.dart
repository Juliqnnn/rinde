import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';
import '../logica/costos.dart';

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

const _categoriasBase = [
  'Verduras', 'Carnes', 'Lácteos', 'Panes', 'Bebidas', 'Salsas', 'Envases',
];

@DriftDatabase(tables: [Categorias, Ingredientes, Movimientos])
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos() : super(driftDatabase(name: 'rinde'));

  @override
  int get schemaVersion => 3;

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
          CategoriasCompanion.insert(nombre: 'Otros', orden: const Value(1000)),
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

  // Crea el ingrediente y, si hay stock, anota el primer movimiento.
  Future<void> crearIngrediente({
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
}