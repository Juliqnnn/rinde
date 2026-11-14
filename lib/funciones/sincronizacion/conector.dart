import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:rinde/funciones/sincronizacion/subida.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Llega desde config.json (flutter run --dart-define-from-file=config.json).
const powerSyncUrl = String.fromEnvironment('POWERSYNC_URL');

/// Puente entre PowerSync y Supabase. PowerSync lo llama solo:
/// - [fetchCredentials] al conectarse (y cuando el token vence).
/// - [uploadData] cada vez que hay cambios locales en la cola.
class ConectorSupabase extends PowerSyncBackendConnector {
  SupabaseClient get _supabase => Supabase.instance.client;

  /// PowerSync acepta el mismo token de sesión de Supabase
  /// ("Use Supabase Auth" en el panel). Sin sesión → null (no conecta).
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    var sesion = _supabase.auth.currentSession;
    if (sesion == null) return null;
    if (sesion.isExpired) {
      // Sin internet esto lanza un error: PowerSync reintenta más tarde.
      sesion = (await _supabase.auth.refreshSession()).session;
      if (sesion == null) return null;
    }
    return PowerSyncCredentials(
      endpoint: powerSyncUrl,
      token: sesion.accessToken,
      userId: sesion.user.id,
    );
  }

  /// PowerSync avisa que el token ya no sirve: pedimos uno nuevo.
  @override
  void invalidateCredentials() {
    super.invalidateCredentials();
    _supabase.auth.refreshSession().ignore();
  }

  /// Sube UNA transacción local (p. ej. ingrediente + su movimiento), en
  /// orden. Sube con la sesión del usuario, así que RLS decide qué se acepta.
  ///
  /// - Error temporal (sin internet): se relanza y PowerSync reintenta
  ///   la transacción entera más tarde. Reintentar es seguro: put = upsert.
  /// - Error permanente (RLS, dato inválido): se guarda ese cambio en
  ///   subidas_rechazadas y se sigue, para no trabar la cola para siempre.
  ///   Ojo: así una transacción puede quedar subida a medias (lo demás sí
  ///   sube). Es un caso raro; por eso queda registrado para avisar.
  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final tx = await database.getNextCrudTransaction();
    if (tx == null) return;

    for (final op in tx.crud) {
      try {
        await _aplicar(op);
      } catch (e) {
        if (!esErrorPermanente(e) && e is! TablaNoPermitida) rethrow;
        debugPrint('[SYNC] rechazado ${op.table}/${op.id}: $e');
        await _guardarRechazo(database, op, e);
      }
    }
    await tx.complete();
  }

  Future<void> _aplicar(CrudEntry op) async {
    final fila = prepararFila(op.table, op.opData ?? const {});
    if (fila == null) throw TablaNoPermitida(op.table);
    final tabla = _supabase.from(op.table);

    switch (op.op) {
      case UpdateType.put:
        await tabla.upsert({...fila, 'id': op.id});
      case UpdateType.patch:
        // Solo las columnas que cambiaron. Si solo cambió algo local
        // (p. ej. stock), no queda nada que subir.
        if (fila.isEmpty) return;
        await tabla.update(fila).eq('id', op.id);
      case UpdateType.delete:
        await tabla.delete().eq('id', op.id);
    }
  }

  Future<void> _guardarRechazo(
      PowerSyncDatabase database, CrudEntry op, Object error) {
    final mensaje = error is PostgrestException
        ? '${error.code}: ${error.message}'
        : error.toString();
    return database.execute(
      'INSERT INTO subidas_rechazadas '
      '(id, tabla, fila_id, operacion, datos, error, fecha) '
      'VALUES (uuid(), ?, ?, ?, ?, ?, ?)',
      [
        op.table,
        op.id,
        op.op.name,
        jsonEncode(op.opData),
        mensaje,
        DateTime.now().toUtc().toIso8601String(),
      ],
    );
  }
}
