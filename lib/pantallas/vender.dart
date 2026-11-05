import 'package:flutter/material.dart';
import 'pantalla_vacia.dart';

class VenderPantalla extends StatelessWidget {
  const VenderPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaVacia(
      titulo: 'Vender',
      mensaje: 'Aquí registrarás tus ventas.',
    );
  }
}