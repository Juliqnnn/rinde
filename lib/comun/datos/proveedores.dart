import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/powersync.dart';
import 'package:rinde/funciones/local/local.dart';

/// Drift sobre PowerSync, para el local activo. Mira solo el id del local:
/// se crea de nuevo únicamente si cambia el local (o el usuario).
///
/// Mientras existe, la app está suscrita a los datos de ese local.
///
/// Solo se usa dentro de la app (Estructura), que aparece cuando ya hay
/// local activo.
final baseDeDatosProvider = Provider<BaseDeDatos>((ref) {
  final localId = ref.watch(localIdActivoProvider);
  if (localId == null) throw StateError('No hay local activo');
  final ps = ref.watch(powerSyncProvider);

  ref.onDispose(suscribirDatosDelLocal(ps, localId));
  final db = BaseDeDatos(ps, localId: localId);
  ref.onDispose(db.close);
  return db;
});
