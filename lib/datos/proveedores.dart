import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_de_datos.dart';

final baseDeDatosProvider = Provider<BaseDeDatos>((ref) {
  final db = BaseDeDatos();
  ref.onDispose(db.close);
  return db;
});

final categoriasProvider = StreamProvider<List<Categoria>>((ref) {
  final db = ref.watch(baseDeDatosProvider);
  return (db.select(db.categorias)
    ..orderBy([
          (c) => OrderingTerm.asc(c.orden),
          (c) => OrderingTerm.asc(c.nombre),
    ]))
      .watch();
});

final ingredientesProvider = StreamProvider<List<Ingrediente>>((ref) {
  final db = ref.watch(baseDeDatosProvider);
  return (db.select(db.ingredientes)
    ..where((i) => i.archivado.equals(false))
    ..orderBy([(i) => OrderingTerm.asc(i.nombre)]))
      .watch();
});

// Incluye los archivados: sirve para calcular costos de platos.
final todosLosIngredientesProvider = StreamProvider<List<Ingrediente>>((ref) {
  final db = ref.watch(baseDeDatosProvider);
  return db.select(db.ingredientes).watch();
});

final movimientosProvider =
StreamProvider.family<List<Movimiento>, String>((ref, ingredienteId) {
  final db = ref.watch(baseDeDatosProvider);
  return (db.select(db.movimientos)
    ..where((m) => m.ingredienteId.equals(ingredienteId))
    ..orderBy([(m) => OrderingTerm.desc(m.fecha)])
    ..limit(10))
      .watch();
});

final platosProvider = StreamProvider<List<Plato>>((ref) {
  final db = ref.watch(baseDeDatosProvider);
  return (db.select(db.platos)
    ..where((p) => p.archivado.equals(false))
    ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
      .watch();
});

final recetasProvider = StreamProvider<List<RecetaItem>>((ref) {
  final db = ref.watch(baseDeDatosProvider);
  return db.select(db.recetaItems).watch();
});