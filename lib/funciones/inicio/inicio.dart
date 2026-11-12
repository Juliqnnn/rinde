import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/widgets/pantalla_vacia.dart';
import 'package:rinde/funciones/local/local.dart';
import 'package:rinde/funciones/sesion/sesion.dart';

class InicioPantalla extends ConsumerWidget {
  const InicioPantalla({super.key});

  Future<void> _salir(WidgetRef ref) async {
    final usuario = ref.read(usuarioProvider).asData?.value;
    // Borra la copia del local guardada en el teléfono antes de salir.
    if (usuario != null) {
      await ref.read(localRepositorioProvider).olvidar(usuario.id);
    }
    await ref.read(sesionProvider).salir();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = ref.watch(usuarioProvider).asData?.value?.email;
    final local = ref.watch(localProvider).asData?.value;
    return Column(
      children: [
        Expanded(
          child: PantallaVacia(
            titulo: local?.nombre ?? 'Inicio',
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
                  onPressed: () => _salir(ref),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
