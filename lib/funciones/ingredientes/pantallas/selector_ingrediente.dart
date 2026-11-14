import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/proveedores.dart';
import 'package:rinde/funciones/ingredientes/datos/proveedores_ingredientes.dart';
import 'package:rinde/comun/logica/formato.dart';
import 'package:rinde/comun/logica/medidas.dart';
import 'package:rinde/comun/tema/colores.dart';
import 'package:rinde/funciones/ingredientes/pantallas/nuevo_ingrediente.dart';

// Un ingrediente elegido para una receta, con su cantidad en g, ml o u.
class ItemReceta {
  final Ingrediente ingrediente;
  final double cantidad;
  const ItemReceta(this.ingrediente, this.cantidad);
}

class SelectorIngredientePantalla extends ConsumerStatefulWidget {
  const SelectorIngredientePantalla({super.key});

  @override
  ConsumerState<SelectorIngredientePantalla> createState() =>
      _SelectorIngredientePantallaState();
}

class _SelectorIngredientePantallaState
    extends ConsumerState<SelectorIngredientePantalla> {
  final _buscador = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<double?> _pedirCantidad(Ingrediente ing) {
    final opciones = medidasPara(ing.unidad);
    var medida = opciones.first;
    final c = TextEditingController();
    String? error;
    return showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(ing.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (opciones.length > 1) ...[
                SegmentedButton<Medida>(
                  showSelectedIcon: false,
                  segments: [
                    for (final m in opciones)
                      ButtonSegment(value: m, label: Text(m.etiqueta)),
                  ],
                  selected: {medida},
                  onSelectionChanged: (s) => setD(() => medida = s.first),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: c,
                autofocus: true,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setD(() => error = null),
                decoration: InputDecoration(
                  labelText: '¿Cuánto lleva cada plato?',
                  suffixText: medida.etiqueta,
                  errorText: error,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
                if (v <= 0) {
                  setD(() => error = 'Escribe una cantidad');
                  return;
                }
                Navigator.pop(ctx, v * medida.factor);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  // Crea un ingrediente nuevo y lo agrega al plato sin salir de aquí.
  Future<void> _crear(String nombreInicial) async {
    final id = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => NuevoIngredientePantalla(nombreInicial: nombreInicial),
      ),
    );
    if (id == null || !mounted) return;
    final ing = await ref.read(baseDeDatosProvider).ingredientePorId(id);
    if (!mounted) return;
    final cant = await _pedirCantidad(ing);
    if (cant == null || !mounted) return;
    Navigator.pop(context, ItemReceta(ing, cant));
  }

  @override
  Widget build(BuildContext context) {
    final lista = ref.watch(ingredientesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar ingrediente')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            TextField(
              controller: _buscador,
              decoration: const InputDecoration(
                hintText: 'Buscar ingrediente',
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
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _crear(''),
              child: const Text('+ Crear ingrediente nuevo'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: lista.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(
                    child: Text('No pudimos cargar los ingredientes.')),
                data: (todos) {
                  final filtrados = todos
                      .where((i) => normalizar(i.nombre).contains(_busqueda))
                      .toList();
                  if (todos.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aún no tienes ingredientes.\nCrea el primero con el botón de arriba.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (filtrados.isEmpty) {
                    final texto = _buscador.text.trim();
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('No encontramos «$texto»'),
                          TextButton(
                            onPressed: () => _crear(texto),
                            child: Text('Crear «$texto»'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtrados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, k) {
                      final i = filtrados[k];
                      return Card(
                        margin: EdgeInsets.zero,
                        color: Colors.white,
                        elevation: 0,
                        child: ListTile(
                          title: Text(i.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text(costoTexto(i)),
                          trailing: const Icon(Icons.add_circle_outline,
                              color: Colores.aji),
                          onTap: () async {
                            final cant = await _pedirCantidad(i);
                            if (cant == null || !context.mounted) return;
                            Navigator.pop(context, ItemReceta(i, cant));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}