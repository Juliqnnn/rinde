import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/esquema_powersync.dart';
import 'package:rinde/funciones/local/local.dart';

/// Abre (o crea) la base de PowerSync del teléfono. Se llama una vez en
/// main(), antes de runApp, porque abrirla es asíncrono.
///
/// Archivo nuevo "rinde_nube.db": la base vieja de Drift (rinde.sqlite)
/// no se traspasa (decisión: empezar de cero).
Future<PowerSyncDatabase> abrirPowerSync() async {
  final carpeta = await getApplicationSupportDirectory();
  final db = PowerSyncDatabase(
    schema: esquemaPowerSync,
    path: '${carpeta.path}/rinde_nube.db',
  );
  await db.initialize();
  return db;
}

/// La base de PowerSync (una por teléfono). main() la entrega con
/// overrideWithValue; si no, falla a propósito.
final powerSyncProvider = Provider<PowerSyncDatabase>(
  (ref) => throw UnimplementedError('Falta abrirPowerSync() en main()'),
);

/// Drift sobre PowerSync, para el local activo. Si cambia el local (o el
/// usuario), se crea de nuevo; la base de PowerSync sigue abierta.
///
/// Solo se usa dentro de la app (Estructura), que aparece cuando el local
/// ya está cargado; por eso requireValue no debería fallar.
final baseDeDatosProvider = Provider<BaseDeDatos>((ref) {
  final local = ref.watch(localProvider).requireValue;
  if (local == null) throw StateError('No hay local activo');
  final db = BaseDeDatos(ref.watch(powerSyncProvider), localId: local.id);
  ref.onDispose(db.close);
  return db;
});
