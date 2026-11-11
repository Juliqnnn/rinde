import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/app/estructura.dart';
import 'package:rinde/funciones/sesion/login.dart';
import 'package:rinde/funciones/sesion/sesion.dart';

/// Decide qué mostrar: con sesión → la app; sin sesión → login.
class PuertaSesion extends ConsumerWidget {
  const PuertaSesion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioProvider);
    return usuario.when(
      data: (u) => u == null ? const LoginPantalla() : const Estructura(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const LoginPantalla(),
    );
  }
}
