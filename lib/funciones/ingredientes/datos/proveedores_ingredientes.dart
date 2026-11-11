import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/proveedores.dart';

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
