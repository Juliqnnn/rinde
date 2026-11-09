import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datos/proveedores.dart';
import '../logica/formato.dart';
import '../tema/colores.dart';
import 'detalle_ingrediente.dart';
import 'nuevo_ingrediente.dart';

enum Orden { mayorStock, menorStock, recientes, nombreAz, nombreZa }

const _nombresOrden = {
  Orden.mayorStock: 'Mayor stock',
  Orden.menorStock: 'Menor stock',
  Orden.recientes: 'Agregado recientemente',
  Orden.nombreAz: 'Nombre A-Z',
  Orden.nombreZa: 'Nombre Z-A',
};

class IngredientesPantalla extends ConsumerStatefulWidget {
  const IngredientesPantalla({super.key});

  @override
  ConsumerState<IngredientesPantalla> createState() =>
      _IngredientesPantallaState();
}

class _IngredientesPantallaState extends ConsumerState<IngredientesPantalla> {
  final _chipsCtrl = ScrollController();
  final _listaCtrl = ScrollController();
  final _buscador = TextEditingController();
  String _busqueda = '';
  String? _categoriaId; // null = todas
  Orden _orden = Orden.mayorStock;

  @override
  void dispose() {
    _chipsCtrl.dispose();
    _listaCtrl.dispose();
    _buscador.dispose();
    super.dispose();
  }

  bool get _hayFiltros => _busqueda.isNotEmpty || _categoriaId != null;

  void _limpiarFiltros() {
    setState(() {
      _busqueda = '';
      _categoriaId = null;
      _buscador.clear();
    });
    if (_chipsCtrl.hasClients) _chipsCtrl.jumpTo(0);
  }

  Future<void> _agregar() async {
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NuevoIngredientePantalla()),
    );
    if (creado != true || !mounted) return;
    // Después de crear: sin filtros y con lo nuevo arriba.
    _limpiarFiltros();
    setState(() => _orden = Orden.recientes);
    if (_listaCtrl.hasClients) _listaCtrl.jumpTo(0);
  }

  Widget _chip(String texto, bool activo, VoidCallback alTocar) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: activo,
        showCheckmark: false,
        selectedColor: Colores.pizarra,
        labelStyle: TextStyle(
          color: activo ? Colors.white : Colores.pizarra,
          fontWeight: FontWeight.w700,
        ),
        onSelected: (_) => alTocar(),
      ),
    );
  }

  Widget _barra(int cantidad) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            cantidad == 1 ? '1 ingrediente' : '$cantidad ingredientes',
            style: const TextStyle(color: Colores.pizarra),
          ),
          PopupMenuButton<Orden>(
            initialValue: _orden,
            onSelected: (o) => setState(() => _orden = o),
            itemBuilder: (_) => [
              for (final o in Orden.values)
                PopupMenuItem(value: o, child: Text(_nombresOrden[o]!)),
            ],
            child: Row(
              children: [
                Text(
                  _nombresOrden[_orden]!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.swap_vert, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio(Map<String, String> nombres) {
    if (!_hayFiltros) {
      return const Center(
        child: Text(
          'Aún no tienes ingredientes.\nAgrega el primero con el botón de abajo.',
          textAlign: TextAlign.center,
        ),
      );
    }
    final String mensaje;
    if (_busqueda.isNotEmpty) {
      mensaje = 'No encontramos «${_buscador.text.trim()}»'
          '${_categoriaId != null ? ' en «${nombres[_categoriaId] ?? ''}»' : ''}';
    } else {
      mensaje = 'No tienes ingredientes en «${nombres[_categoriaId] ?? ''}»';
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mensaje, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _limpiarFiltros,
            child: const Text('Quitar filtros'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProvider).asData?.value ?? [];
    final lista = ref.watch(ingredientesProvider);
    final nombres = {for (final c in categorias) c.id: c.nombre};

    return Column(
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
          onChanged: (v) => setState(() => _busqueda = v.trim().toLowerCase()),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: Scrollbar(
            controller: _chipsCtrl,
            thumbVisibility: true,
            thickness: 3,
            radius: const Radius.circular(3),
            child: ListView(
              controller: _chipsCtrl,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                _chip('Todas', _categoriaId == null,
                        () => setState(() => _categoriaId = null)),
                for (final c in categorias)
                  _chip(c.nombre, _categoriaId == c.id,
                          () => setState(() => _categoriaId = c.id)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: lista.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(
                child: Text('No pudimos cargar los ingredientes.')),
            data: (todos) {
              final filtrados = todos
                  .where((i) =>
              (_categoriaId == null || i.categoriaId == _categoriaId) &&
                  i.nombre.toLowerCase().contains(_busqueda))
                  .toList();
              filtrados.sort((a, b) => switch (_orden) {
                Orden.mayorStock => b.stock.compareTo(a.stock),
                Orden.menorStock => a.stock.compareTo(b.stock),
                Orden.recientes => b.creadoEn.compareTo(a.creadoEn),
                Orden.nombreAz => a.nombre
                    .toLowerCase()
                    .compareTo(b.nombre.toLowerCase()),
                Orden.nombreZa => b.nombre
                    .toLowerCase()
                    .compareTo(a.nombre.toLowerCase()),
              });
              return Column(
                children: [
                  _barra(filtrados.length),
                  Expanded(
                    child: filtrados.isEmpty
                        ? _vacio(nombres)
                        : Scrollbar(
                      controller: _listaCtrl,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _listaCtrl,
                        padding: const EdgeInsets.only(right: 10),
                        itemCount: filtrados.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                        itemBuilder: (_, k) {
                          final i = filtrados[k];
                          return Card(
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            elevation: 0,
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalleIngredientePantalla(
                                        ingredienteId: i.id,
                                      ),
                                ),
                              ),
                              title: Text(i.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                '${nombres[i.categoriaId] ?? 'Sin categoría'}'
                                    ' · ${costoTexto(i)}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colores.beige,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Text(
                                  cantidadMixta(i),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _agregar,
          child: const Text('+ Agregar ingrediente'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}