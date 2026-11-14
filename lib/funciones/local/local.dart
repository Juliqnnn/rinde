import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:powersync/powersync.dart';
import 'package:rinde/comun/datos/powersync.dart';
import 'package:rinde/funciones/sesion/sesion.dart';
import 'package:rinde/funciones/sincronizacion/sincronizacion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Local {
  final String id;
  final String nombre;
  const Local({required this.id, required this.nombre});
}

/// En qué punto está la app respecto al local del usuario.
sealed class EstadoLocal {
  const EstadoLocal();
}

/// Primera vez en este teléfono: esperando la primera sincronización.
class LocalSincronizando extends EstadoLocal {
  const LocalSincronizando();
}

/// Primera vez en este teléfono y sin internet: no sabemos cuál es tu local.
/// (PowerSync sigue reintentando solo.)
class LocalSinConexion extends EstadoLocal {
  const LocalSinConexion();
}

/// Sincronizado, y el usuario no es miembro de ningún local.
class SinLocal extends EstadoLocal {
  const SinLocal();
}

class ConLocal extends EstadoLocal {
  final Local local;
  const ConLocal(this.local);
}

class LocalError implements Exception {
  final String mensaje;
  const LocalError(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Elige el local activo: el guardado si sigue entre los míos; si no, el
/// primero (el más antiguo). null si no tengo locales.
Local? elegirLocal(List<Local> mios, String? guardadoId) {
  if (mios.isEmpty) return null;
  for (final l in mios) {
    if (l.id == guardadoId) return l;
  }
  return mios.first;
}

class LocalRepositorio {
  final _prefs = SharedPreferencesAsync();
  SupabaseClient get _supabase => Supabase.instance.client;

  // Solo se guarda el id del local activo (los datos vienen sincronizados).
  // La clave incluye el usuario: otra cuenta nunca hereda la elección.
  String _clave(String usuarioId) => 'local_activo.$usuarioId';

  Future<String?> leerActivo(String usuarioId) =>
      _prefs.getString(_clave(usuarioId));

  Future<void> guardarActivo(String usuarioId, String localId) =>
      _prefs.setString(_clave(usuarioId), localId);

  /// Llama a crear_local en Supabase (necesita internet): crea el local, nos
  /// agrega como dueño y crea las categorías base, todo en el servidor.
  /// La fila llega al teléfono por sincronización; aquí solo se marca
  /// como activo.
  Future<void> crear(String usuarioId, String nombre) async {
    try {
      final fila = await _supabase.rpc(
        'crear_local',
        params: {'p_nombre': nombre.trim()},
      );
      final id = (fila as Map<String, dynamic>)['id'] as String;
      await guardarActivo(usuarioId, id);
    } on PostgrestException catch (e) {
      // Códigos que lanza crear_local en el SQL.
      switch (e.code) {
        case '23505': // Ya tiene un local (p. ej., creado desde otro teléfono)
          throw const LocalError(
              'Ya tienes un local. Espera a que se sincronice.');
        case '22023':
          throw const LocalError('El nombre debe tener entre 1 y 60 caracteres.');
        default:
          throw LocalError('No se pudo crear el local (${e.code ?? e.message}).');
      }
    }
  }
}

final localRepositorioProvider = Provider((ref) => LocalRepositorio());

/// El estado del local del usuario con sesión, en vivo: cambia solo cuando
/// llega la primera sincronización o cambia la tabla locales.
final localProvider = StreamProvider<EstadoLocal>((ref) async* {
  final usuarioId =
      await ref.watch(usuarioProvider.selectAsync((u) => u?.id));
  if (usuarioId == null) return;

  // Espera a que se borren datos de otra cuenta y se inicie la conexión.
  await ref.watch(sincronizacionProvider.future);
  final ps = ref.watch(powerSyncProvider);
  final repo = ref.read(localRepositorioProvider);

  // 1) Primera sincronización (hasSynced queda guardado en la base: desde
  //    la segunda vez la app abre aunque no haya internet).
  if (ps.currentStatus.hasSynced != true) {
    yield const LocalSincronizando();
    await for (final estado in ps.statusStream) {
      if (estado.hasSynced == true || ps.currentStatus.hasSynced == true) {
        break;
      }
      yield estado.downloadError != null
          ? const LocalSinConexion()
          : const LocalSincronizando();
    }
  }

  // 2) Mis locales: PowerSync solo baja aquellos donde soy miembro.
  final consulta = ps.watch(
    'SELECT id, nombre FROM locales ORDER BY creado_en, id',
  );
  await for (final filas in consulta) {
    final mios = [
      for (final f in filas)
        Local(id: f['id'] as String, nombre: f['nombre'] as String),
    ];
    final guardado = await repo.leerActivo(usuarioId);
    final activo = elegirLocal(mios, guardado);
    if (activo == null) {
      yield const SinLocal();
      continue;
    }
    if (activo.id != guardado) await repo.guardarActivo(usuarioId, activo.id);
    yield ConLocal(activo);
  }
});

/// El local activo (null si todavía no hay).
final localActivoProvider = Provider<Local?>((ref) {
  return switch (ref.watch(localProvider).asData?.value) {
    ConLocal(:final local) => local,
    _ => null,
  };
});

/// Solo el id del local activo. Usar este (y no localProvider) para lo que
/// depende del local: así no se recalcula cuando cambia otra cosa.
final localIdActivoProvider =
    Provider<String?>((ref) => ref.watch(localActivoProvider)?.id);

/// Mientras el local esté abierto, pide a PowerSync sus datos (Stream
/// "datos_local" con el id como parámetro). La Stream verifica en el
/// servidor que yo sea miembro; si no, no baja nada.
/// Devuelve la función para cancelar la suscripción.
void Function() suscribirDatosDelLocal(PowerSyncDatabase ps, String localId) {
  SyncStreamSubscription? suscripcion;
  var cancelada = false;
  ps.syncStream('datos_local', {'local_id': localId}).subscribe().then(
    (s) => cancelada ? s.unsubscribe() : suscripcion = s,
    onError: (Object e) => debugPrint('[SYNC] no se pudo suscribir: $e'),
  );
  return () {
    cancelada = true;
    suscripcion?.unsubscribe();
  };
}
