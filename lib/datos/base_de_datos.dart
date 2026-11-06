import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'base_de_datos.g.dart';

const _uuid = Uuid();

enum Unidad { gramos, mililitros, unidades }

class Categorias extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get nombre => text().unique()();
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

@DriftDatabase(tables: [Categorias, Ingredientes])
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos() : super(driftDatabase(name: 'rinde'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await batch((b) {
        b.insertAll(categorias, [
          for (final n in [
            'Verduras', 'Carnes', 'Lácteos', 'Panes',
            'Bebidas', 'Salsas', 'Envases', 'Otros',
          ])
            CategoriasCompanion.insert(nombre: n),
        ]);
      });
    },
    beforeOpen: (detalles) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}