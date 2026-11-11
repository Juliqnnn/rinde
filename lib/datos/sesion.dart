import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Valores que llegan desde config.json al correr la app con:
//   flutter run --dart-define-from-file=config.json
// Si no se pasa el archivo, quedan vacíos.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

bool get nubeConfigurada =>
    _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;

/// Se llama una vez al abrir la app. Supabase recupera la sesión guardada
/// en el teléfono, así que funciona aunque no haya internet.
Future<void> iniciarNube() async {
  if (!nubeConfigurada) return;
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );
}

class Sesion {
  bool _googleIniciado = false;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// 1) Google muestra el selector de cuentas y entrega un "idToken".
  /// 2) Se lo pasamos a Supabase, que lo verifica y crea/abre el usuario.
  Future<void> entrarConGoogle() async {
    if (_googleWebClientId.isEmpty) {
      throw const SesionError('Falta GOOGLE_WEB_CLIENT_ID en config.json.');
    }
    final google = GoogleSignIn.instance;
    if (!_googleIniciado) {
      await google.initialize(serverClientId: _googleWebClientId);
      _googleIniciado = true;
    }

    final cuenta = await google.authenticate();
    final idToken = cuenta.authentication.idToken;
    if (idToken == null) {
      throw const SesionError('Google no entregó el token de acceso.');
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> salir() async {
    await _supabase.auth.signOut();
    if (_googleIniciado) await GoogleSignIn.instance.signOut();
  }
}

class SesionError implements Exception {
  final String mensaje;
  const SesionError(this.mensaje);
  @override
  String toString() => mensaje;
}

final sesionProvider = Provider<Sesion>((ref) => Sesion());

/// Emite el usuario actual (o null) cada vez que se entra o se sale.
final usuarioProvider = StreamProvider<User?>((ref) async* {
  if (!nubeConfigurada) {
    yield null;
    return;
  }
  final auth = Supabase.instance.client.auth;
  yield auth.currentUser;
  await for (final cambio in auth.onAuthStateChange) {
    yield cambio.session?.user;
  }
});
