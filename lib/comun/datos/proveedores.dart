import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';

// Una sola base de datos para toda la app. Los providers de cada función
// (ingredientes, platos...) viven en su propia carpeta y usan este.
final baseDeDatosProvider = Provider<BaseDeDatos>((ref) {
  final db = BaseDeDatos();
  ref.onDispose(db.close);
  return db;
});
