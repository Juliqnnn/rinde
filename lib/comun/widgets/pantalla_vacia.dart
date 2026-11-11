import 'package:flutter/material.dart';

class PantallaVacia extends StatelessWidget {
  final String titulo;
  final String mensaje;

  const PantallaVacia({super.key, required this.titulo, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(child: Center(child: Text(mensaje))),
        ],
      ),
    );
  }
}