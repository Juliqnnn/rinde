import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/funciones/sesion/sesion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Local {
  final String id;
  final String nombre;
  const Local({required this.id, required this.nombre});

  factory Local.desdeMapa(Map<String, dynamic> m) =>
      Local(id: m['id'] as String, nombre: m['nombre'] as String);

  Map<String, dynamic> aMapa() => {'id': id, 'nombre': nombre};
}

class LocalError implements Exception {
  final String mensaje;
  const LocalError(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Busca y crea el local del usuario. Guarda una copia en el teléfono
/// (shared_preferences) para poder abrir la app sin internet.
class LocalRepositorio {
  final _prefs = SharedPreferencesAsync();
  SupabaseClient get _supabase => Supabase.instance.client;

  // La clave incluye el id del usuario: si en el mismo teléfono entra
  // otra cuenta, nunca ve el local guardado de la anterior.
  String _clave(String usuarioId) => 'local.$usuarioId';

  Future<Local?> _leerGuardado(String usuarioId) async {
    final texto = await _prefs.getString(_clave(usuarioId));
    if (texto == null) return null;
    return Local.desdeMapa(jsonDecode(texto) as Map<String, dynamic>);
  }

  Future<void> _guardar(String usuarioId, Local local) =>
      _prefs.setString(_clave(usuarioId), jsonEncode(local.aMapa()));

  Future<void> olvidar(String usuarioId) => _prefs.remove(_clave(usuarioId));

  /// 1) Si está guardado en el teléfono, lo usa (funciona sin internet).
  /// 2) Si no, lo pide a Supabase; RLS solo devuelve locales donde soy miembro.
  /// Devuelve null si el usuario todavía no tiene local.
  Future<Local?> cargar(String usuarioId) async {
    final guardado = await _leerGuardado(usuarioId);
    if (guardado != null) return guardado;

    final fila = await _supabase
        .from('locales')
        .select('id, nombre')
        .order('creado_en')
        .limit(1)
        .maybeSingle();
    if (fila == null) return null;

    final local = Local.desdeMapa(fila);
    await _guardar(usuarioId, local);
    return local;
  }

  /// Llama a la función crear_local de Supabase: crea el local y nos agrega
  /// como dueño en una sola transacción. El dueño lo pone el servidor.
  Future<Local> crear(String usuarioId, String nombre) async {
    try {
      final fila = await _supabase.rpc(
        'crear_local',
        params: {'p_nombre': nombre.trim()},
      );
      final local = Local.desdeMapa(fila as Map<String, dynamic>);
      await _guardar(usuarioId, local);
      return local;
    } on PostgrestException catch (e) {
      // Códigos que lanza crear_local en el SQL.
      switch (e.code) {
        case '23505': // Ya tiene un local (p. ej., creado desde otro teléfono)
          final existente = await cargar(usuarioId);
          if (existente != null) return existente;
          throw const LocalError('Ya tienes un local.');
        case '22023':
          throw const LocalError('El nombre debe tener entre 1 y 60 caracteres.');
        default:
          throw LocalError('No se pudo crear el local (${e.code ?? e.message}).');
      }
    }
  }
}

final localRepositorioProvider = Provider((ref) => LocalRepositorio());

/// El local del usuario con sesión (null = aún no tiene).
/// Se recalcula solo cuando cambia el usuario (entrar/salir): selectAsync
/// mira únicamente el id, así renovar el token no lo recarga.
final localProvider = FutureProvider<Local?>(
  (ref) async {
    final usuarioId =
        await ref.watch(usuarioProvider.selectAsync((u) => u?.id));
    if (usuarioId == null) return null;
    return ref.read(localRepositorioProvider).cargar(usuarioId);
  },
  // Sin reintentos automáticos: si no hay internet, la pantalla muestra
  // un botón "Reintentar" en vez de insistir sola.
  retry: (_, _) => null,
);
