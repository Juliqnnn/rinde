import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/proveedores.dart';
import 'package:rinde/funciones/ingredientes/datos/proveedores_ingredientes.dart';
import 'package:rinde/comun/logica/formato.dart';
import 'package:rinde/comun/tema/colores.dart';
import 'package:rinde/funciones/ingredientes/pantallas/ajustar_stock.dart';
import 'package:rinde/funciones/ingredientes/pantallas/registrar_compra.dart';

class DetalleIngredientePantalla extends ConsumerWidget {
  final String ingredienteId;

  const DetalleIngredientePantalla({super.key, required this.ingredienteId});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
  }

  Future<void> _eliminar(
      BuildContext context, WidgetRef ref, Ingrediente ing) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar ${ing.nombre}?'),
        content: const Text(
            'Se quitará de tu lista. Las compras y ventas anteriores se conservan.'),
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
    await ref.read(baseDeDatosProvider).archivarIngrediente(ing.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lista = ref.watch(ingredientesProvider).asData?.value ?? [];
    final categorias = ref.watch(categoriasProvider).asData?.value ?? [];
    final ing = lista.where((i) => i.id == ingredienteId).firstOrNull;

    if (ing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final categoria =
        categorias.where((c) => c.id == ing.categoriaId).firstOrNull?.nombre ??
            'Sin categoría';
    final movimientos = ref.watch(movimientosProvider(ing.id));
    final mostrarExacto = ing.unidad != Unidad.unidades && ing.stock >= 1000;

    return Scaffold(
      appBar: AppBar(title: Text(ing.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colores.beige,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(categoria,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stock actual',
                      style: TextStyle(color: Colors.black54)),
                  Text(cantidadCorta(ing),
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.w800)),
                  if (mostrarExacto)
                    Text(
                      '${cantidadMixta(ing)} · ${cantidadExacta(ing)} exactos',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Colores.verde),
                    ),
                  if (ing.stock < 0)
                    const Text(
                      'El stock quedó negativo: ajústalo cuando lo cuentes.',
                      style: TextStyle(color: Colores.ambar),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Costo: ${costoTexto(ing)}'),
                  const SizedBox(height: 4),
                  Text(
                      'Valor del stock: ${pesos(ing.stock * ing.costoUnitario)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      _abrir(context, RegistrarCompraPantalla(ingrediente: ing)),
                  child: const Text('Registrar compra'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () =>
                      _abrir(context, AjustarStockPantalla(ingrediente: ing)),
                  child: const Text('Ajustar stock'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Últimos movimientos',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          movimientos.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('No pudimos cargar los movimientos.'),
            data: (lista) {
              if (lista.isEmpty) return const Text('Aún no hay movimientos.');
              return Column(
                children: [
                  for (final m in lista)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        title: Text(nombreMovimiento(m.tipo),
                            style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text([
                          fechaRelativa(m.fecha),
                          if (m.motivo != null) m.motivo!,
                          if (m.tipo == TipoMovimiento.compra &&
                              m.costoUnitario != null)
                            costoPorUnidad(m.costoUnitario!, ing.unidad),
                        ].join(' · ')),
                        trailing: Text(
                          '${m.cantidad >= 0 ? '+' : ''}'
                              '${cantidadDe(m.cantidad, ing.unidad)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color:
                            m.cantidad >= 0 ? Colores.verde : Colores.rojo,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _eliminar(context, ref, ing),
            icon: const Icon(Icons.delete_outline, color: Colores.rojo),
            label: const Text('Eliminar ingrediente',
                style: TextStyle(color: Colores.rojo)),
          ),
        ],
      ),
    );
  }
}