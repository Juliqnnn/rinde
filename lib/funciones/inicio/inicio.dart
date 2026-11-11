import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/funciones/sesion/sesion.dart';
import 'package:rinde/comun/widgets/pantalla_vacia.dart';

class InicioPantalla extends ConsumerWidget {
  const InicioPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = ref.watch(usuarioProvider).asData?.value?.email;
    return Column(
      children: [
        const Expanded(
          child: PantallaVacia(
            titulo: 'Inicio',
            mensaje: 'Aquí verás cómo va tu día.',
          ),
        ),
        // Temporal (prueba de concepto): ver quién entró y poder salir.
        if (correo != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(child: Text(correo)),
                TextButton(
                  onPressed: () => ref.read(sesionProvider).salir(),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
