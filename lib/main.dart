import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/app/puerta_sesion.dart';
import 'package:rinde/comun/datos/powersync.dart';
import 'package:rinde/comun/tema/tema.dart';
import 'package:rinde/funciones/sesion/sesion.dart';

Future<void> main() async {
  // Necesario para usar plugins (Supabase guarda la sesión) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await iniciarNube();
  final powerSync = await abrirPowerSync();
  runApp(ProviderScope(
    overrides: [powerSyncProvider.overrideWithValue(powerSync)],
    child: const RindeApp(),
  ));
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
