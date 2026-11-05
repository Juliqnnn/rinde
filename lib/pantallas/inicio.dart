import 'package:flutter/material.dart';
import 'pantalla_vacia.dart';

class InicioPantalla extends StatelessWidget {
  const InicioPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaVacia(
      titulo: 'Inicio',
      mensaje: 'Aquí verás cómo va tu día.',
    );
  }
}