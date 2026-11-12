import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:rinde/comun/datos/powersync.dart';
import 'package:rinde/funciones/sesion/sesion.dart';
import 'package:rinde/funciones/sincronizacion/conector.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool get sincronizacionConfigurada =>
    nubeConfigurada && powerSyncUrl.isNotEmpty;

// Qué usuario es dueño de los datos que hay en el teléfono.
const _claveDueno = 'powersync.usuario';

/// Conecta PowerSync mientras haya sesión, y borra los datos del teléfono
/// cuando la sesión termina de verdad (signedOut).
///
/// Se recalcula solo cuando cambia el usuario (no al renovar el token).
/// Sin internet igual "termina" bien: connect() no espera a la red;
/// PowerSync reintenta solo y la app sigue funcionando con lo local.
final sincronizacionProvider = FutureProvider<void>((ref) async {
  final ps = ref.watch(powerSyncProvider);
  final usuarioId =
      await ref.watch(usuarioProvider.selectAsync((u) => u?.id));

  if (usuarioId == null) {
    await borrarDatosDelTelefono(ps);
    return;
  }
  await _asegurarDueno(ps, usuarioId);
  if (!sincronizacionConfigurada) return;

  ref.onDispose(ps.disconnect);
  await ps.connect(connector: ConectorSupabase());
});

/// Desconecta y borra TODO lo del teléfono, incluida la cola de subida y
/// las tablas solo locales (platos, movimientos hasta las etapas E y F).
Future<void> borrarDatosDelTelefono(PowerSyncDatabase ps) async {
  await ps.disconnectAndClear();
  await SharedPreferencesAsync().remove(_claveDueno);
}

/// Si en el teléfono quedaron datos de OTRA cuenta (p. ej. la app se cerró
/// justo al salir), se borran antes de mostrar nada.
Future<void> _asegurarDueno(PowerSyncDatabase ps, String usuarioId) async {
  final prefs = SharedPreferencesAsync();
  final dueno = await prefs.getString(_claveDueno);
  if (dueno == usuarioId) return;
  if (dueno != null) await ps.disconnectAndClear();
  await prefs.setString(_claveDueno, usuarioId);
}

/// Cuántos cambios locales faltan por subir (para avisar antes de salir).
Future<int> cambiosSinSubir(PowerSyncDatabase ps) async =>
    (await ps.getUploadQueueStats()).count;
