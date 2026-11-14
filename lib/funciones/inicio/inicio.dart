import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/powersync.dart';
import 'package:rinde/comun/widgets/pantalla_vacia.dart';
import 'package:rinde/funciones/local/local.dart';
import 'package:rinde/funciones/sesion/sesion.dart';
import 'package:rinde/funciones/sincronizacion/sincronizacion.dart';

class InicioPantalla extends ConsumerWidget {
  const InicioPantalla({super.key});

  // Al salir se borran los datos del teléfono (sincronizacionProvider lo
  // hace al ver la sesión cerrada). Lo que no se subió se pierde: avisar.
  Future<void> _salir(BuildContext context, WidgetRef ref) async {
    final pendientes = await cambiosSinSubir(ref.read(powerSyncProvider));
    if (!context.mounted) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: Text(
          'Se borrarán los datos de este teléfono. Los que ya están en la '
          'nube vuelven al entrar de nuevo. Los platos aún se guardan solo '
          'en el teléfono, así que se pierden.'
          '${pendientes > 0 ? '\n\nOjo: hay $pendientes cambios que todavía '
              'no se suben y se perderán. Conéctate a internet antes de '
              'salir.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmado == true) await ref.read(sesionProvider).salir();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correo = ref.watch(usuarioProvider).asData?.value?.email;
    final local = ref.watch(localActivoProvider);
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
                  onPressed: () => _salir(context, ref),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
