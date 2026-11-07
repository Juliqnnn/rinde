import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tema/tema.dart';
import 'pantallas/estructura.dart';

void main() {
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
      home: const Estructura(),
    );
  }
}