import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:rinde/comun/datos/esquema_powersync.dart';

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
