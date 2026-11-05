import 'package:flutter/material.dart';
import 'pantalla_vacia.dart';

class PlatosPantalla extends StatelessWidget {
  const PlatosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaVacia(
      titulo: 'Platos',
      mensaje: 'Aquí cargarás tus platos e ingredientes.',
    );
  }
}