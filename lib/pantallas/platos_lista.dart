import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datos/base_de_datos.dart';
import '../datos/proveedores.dart';
import '../logica/costos.dart';
import '../logica/formato.dart';
import '../logica/platos.dart';
import '../tema/colores.dart';
import 'detalle_plato.dart';
import 'foto_plato.dart';
import 'nuevo_plato.dart';

class PlatosListaPantalla extends ConsumerStatefulWidget {
  const PlatosListaPantalla({super.key});

  @override
  ConsumerState<PlatosListaPantalla> createState() =>
      _PlatosListaPantallaState();
}

class _PlatosListaPantallaState extends ConsumerState<PlatosListaPantalla> {
  final _buscador = TextEditingController();
  final _listaCtrl = ScrollController();
  String _busqueda = '';

  @override
  void dispose() {
    _buscador.dispose();
    _listaCtrl.dispose();
    super.dispose();
  }

  void _limpiar() {
    setState(() {
      _busqueda = '';
      _buscador.clear();
    });
  }

  Future<void> _agregar() async {
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NuevoPlatoPantalla()),
    );
    if (creado == true && mounted) _limpiar();
  }

  Widget _etiquetaSinIngredientes() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Text('Sin ingredientes',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colores.ambar)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platos = ref.watch(platosProvider);
    final recetas = ref.watch(recetasProvider).asData?.value ?? [];
    final todos = ref.watch(todosLosIngredientesProvider).asData?.value ?? [];
    final ings = {for (final i in todos) i.id: i};

    return Column(
      children: [
        TextField(
          controller: _buscador,
          decoration: const InputDecoration(
            hintText: 'Buscar plato',
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => setState(() => _busqueda = normalizar(v)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: platos.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
            const Center(child: Text('No pudimos cargar los platos.')),
            data: (lista) {
              final filtrados = lista
                  .where((p) => normalizar(p.nombre).contains(_busqueda))
                  .toList();
              if (lista.isEmpty) {
                return const Center(
                  child: Text(
                    'Aún no tienes platos.\nAgrega el primero con el botón de abajo.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (filtrados.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('No encontramos «${_buscador.text.trim()}»'),
                      TextButton(
                        onPressed: _limpiar,
                        child: const Text('Quitar búsqueda'),
                      ),
                    ],
                  ),
                );
              }
              return Scrollbar(
                controller: _listaCtrl,
                thumbVisibility: true,
                child: ListView.separated(
                  controller: _listaCtrl,
                  padding: const EdgeInsets.only(right: 10),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, k) {
                    final Plato p = filtrados[k];
                    final c = calcularCosto(p, recetas, ings);
                    return Card(
                      margin: EdgeInsets.zero,
                      color: Colors.white,
                      elevation: 0,
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetallePlatoPantalla(platoId: p.id),
                          ),
                        ),
                        leading: FotoPlato(nombre: p.nombre, foto: p.foto),
                        title: Text(p.nombre,
                            style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Costo ${pesos(c.costo)}'
                                ' · Margen ${porcentaje(margen(p.precioVenta, c.costo))}'),
                            if (!c.conReceta) _etiquetaSinIngredientes(),
                          ],
                        ),
                        trailing: Text(
                          pesos(p.precioVenta),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _agregar,
          child: const Text('+ Agregar plato'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}