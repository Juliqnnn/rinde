import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/proveedores.dart';

final platosProvider = StreamProvider<List<Plato>>((ref) {
  final db = ref.watch(baseDeDatosProvider);
  return (db.select(db.platos)
    ..where((p) => p.localId.equals(db.localId) & p.archivado.equals(false))
    ..orderBy([(p) => OrderingTerm.asc(p.nombre)]))
      .watch();
});

final recetasProvider = StreamProvider<List<RecetaItem>>((ref) {
  final db = ref.watch(baseDeDatosProvider);
  return (db.select(db.recetaItems)
    ..where((r) => r.localId.equals(db.localId)))
      .watch();
});
