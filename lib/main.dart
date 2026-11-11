import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'datos/sesion.dart';
import 'tema/tema.dart';
import 'pantallas/estructura.dart';
import 'pantallas/login.dart';

Future<void> main() async {
  // Necesario para usar plugins (Supabase guarda la sesión) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await iniciarNube();
  runApp(const ProviderScope(child: RindeApp()));
}

class RindeApp extends StatelessWidget {
  const RindeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rinde',
      debugShowCheckedModeBanner: false,
      theme: crearTema(),
      home: const PuertaSesion(),
    );
  }
}

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
