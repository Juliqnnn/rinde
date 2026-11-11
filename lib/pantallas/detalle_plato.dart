import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datos/base_de_datos.dart';
import '../datos/proveedores.dart';
import '../logica/costos.dart';
import '../logica/formato.dart';
import '../logica/fotos.dart';
import '../logica/platos.dart';
import '../tema/colores.dart';
import 'foto_plato.dart';
import 'selector_ingrediente.dart';

class DetallePlatoPantalla extends ConsumerWidget {
  final String platoId;

  const DetallePlatoPantalla({super.key, required this.platoId});

  Future<void> _agregar(
      BuildContext context, WidgetRef ref, Plato plato) async {
    final item = await Navigator.push<ItemReceta>(
      context,
      MaterialPageRoute(builder: (_) => const SelectorIngredientePantalla()),
    );
    if (item == null) return;
    await ref.read(baseDeDatosProvider).agregarAReceta(
      platoId: plato.id,
      ingredienteId: item.ingrediente.id,
      cantidad: item.cantidad,
    );
  }

  Future<void> _cambiarFoto(
      BuildContext context, WidgetRef ref, Plato plato) async {
    final r = await pedirFoto(context, puedeQuitar: plato.foto != null);
    if (r == null || !context.mounted) return;
    final nueva = r.ruta == null ? null : await guardarFoto(r.ruta!);
    await ref.read(baseDeDatosProvider).cambiarFotoPlato(plato.id, nueva);
    if (plato.foto != null) await borrarFoto(plato.foto!);
  }

  Future<void> _eliminar(
      BuildContext context, WidgetRef ref, Plato plato) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar ${plato.nombre}?'),
        content: const Text(
            'Se quitará de tu lista. Las ventas anteriores se conservan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
            const Text('Eliminar', style: TextStyle(color: Colores.rojo)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(baseDeDatosProvider).archivarPlato(plato.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platos = ref.watch(platosProvider).asData?.value ?? [];
    final plato = platos.where((p) => p.id == platoId).firstOrNull;
    if (plato == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final recetas = ref.watch(recetasProvider).asData?.value ?? [];
    final todos = ref.watch(todosLosIngredientesProvider).asData?.value ?? [];
    final ings = {for (final i in todos) i.id: i};
    final items = recetas.where((r) => r.platoId == plato.id).toList();
    final c = calcularCosto(plato, recetas, ings);
    final ganancia = plato.precioVenta - c.costo;

    return Scaffold(
      appBar: AppBar(title: Text(plato.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                InkWell(
                  onTap: () => _cambiarFoto(context, ref, plato),
                  child: FotoPlato(
                      nombre: plato.nombre, foto: plato.foto, tamano: 120),
                ),
                TextButton(
                  onPressed: () => _cambiarFoto(context, ref, plato),
                  child: Text(
                      plato.foto == null ? '+ Agregar foto' : 'Cambiar foto'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Precio de venta',
                      style: TextStyle(color: Colors.black54)),
                  Text(pesos(plato.precioVenta),
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Costo: ${pesos(c.costo)}'
                      '${c.conReceta ? '' : ' (lo escribiste tú)'}'),
                  Text(
                    'Ganancia: ${pesos(ganancia)} · '
                        'Margen ${porcentaje(margen(plato.precioVenta, c.costo))}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: ganancia < 0 ? Colores.rojo : Colores.verde,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ingredientes',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Text(
                'Este plato no tiene ingredientes. Si los agregas, Rinde calculará '
                    'tu costo real y te avisará cuando se acabe el stock.',
              ),
            )
          else
            for (final r in items)
              Builder(builder: (context) {
                final ing = ings[r.ingredienteId];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                  elevation: 0,
                  child: ListTile(
                    title: Text(ing?.nombre ?? 'Ingrediente eliminado',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(ing == null
                        ? '—'
                        : cantidadDe(r.cantidad, ing.unidad)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ing == null
                              ? ''
                              : pesos(r.cantidad * ing.costoUnitario),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                          tooltip: 'Quitar del plato',
                          icon: const Icon(Icons.close),
                          onPressed: () => ref
                              .read(baseDeDatosProvider)
                              .quitarDeReceta(r.id),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _agregar(context, ref, plato),
            child: Text(items.isEmpty
                ? '+ Agregar ingredientes'
                : '+ Agregar otro ingrediente'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _eliminar(context, ref, plato),
            icon: const Icon(Icons.delete_outline, color: Colores.rojo),
            label: const Text('Eliminar plato',
                style: TextStyle(color: Colores.rojo)),
          ),
        ],
      ),
    );
  }
}