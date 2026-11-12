import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/app/estructura.dart';
import 'package:rinde/funciones/local/crear_local.dart';
import 'package:rinde/funciones/local/local.dart';
import 'package:rinde/funciones/sesion/login.dart';
import 'package:rinde/funciones/sesion/sesion.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

/// Decide qué mostrar:
/// sin sesión → login · sin local → crear local · con local → la app.
class PuertaSesion extends ConsumerWidget {
  const PuertaSesion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioProvider);
    return usuario.when(
      loading: () => const _Cargando(),
      // Un error NO es "sin sesión": decide la sesión guardada en el teléfono.
      error: (_, _) => _segunUsuario(ref, usuarioActual()),
      data: (u) => _segunUsuario(ref, u),
    );
  }

  Widget _segunUsuario(WidgetRef ref, User? u) {
    if (u == null) return const LoginPantalla();
    final local = ref.watch(localProvider);
    return local.when(
      loading: () => const _Cargando(),
      error: (_, _) => const _SinConexion(),
      data: (l) => l == null ? const CrearLocalPantalla() : const Estructura(),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

/// Primera vez en este teléfono y sin internet: no sabemos cuál es tu local.
class _SinConexion extends ConsumerWidget {
  const _SinConexion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.wifi_off, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Necesitas internet la primera vez para cargar tu local.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref.invalidate(localProvider),
                child: const Text('Reintentar'),
              ),
              TextButton(
                onPressed: () => ref.read(sesionProvider).salir(),
                child: const Text('Usar otra cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
