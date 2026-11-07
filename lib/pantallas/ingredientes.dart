import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datos/base_de_datos.dart';
import '../datos/proveedores.dart';
import '../tema/colores.dart';
import 'nuevo_ingrediente.dart';

String _unidadCorta(Unidad u) => switch (u) {
  Unidad.gramos => 'g',
  Unidad.mililitros => 'ml',
  Unidad.unidades => 'u',
};

String _numero(double n) =>
    n.toStringAsFixed(n % 1 == 0 ? 0 : 1).replaceAll('.', ',');

// 1500 g se muestra como 1,5 kg; 2000 ml como 2 L.
String _cantidad(Ingrediente i) {
  if (i.unidad != Unidad.unidades && i.stock >= 1000) {
    final grande = i.unidad == Unidad.gramos ? 'kg' : 'L';
    return '${_numero(i.stock / 1000)} $grande';
  }
  return '${_numero(i.stock)} ${_unidadCorta(i.unidad)}';
}

class IngredientesPantalla extends ConsumerStatefulWidget {
  const IngredientesPantalla({super.key});

  @override
  ConsumerState<IngredientesPantalla> createState() =>
      _IngredientesPantallaState();
}

class _IngredientesPantallaState extends ConsumerState<IngredientesPantalla> {
  String _busqueda = '';
  String? _categoriaId; // null = todas

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

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProvider).asData?.value ?? [];
    final lista = ref.watch(ingredientesProvider);
    final nombres = {for (final c in categorias) c.id: c.nombre};

    return Column(
      children: [
        TextField(
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
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('Todas', _categoriaId == null,
                      () => setState(() => _categoriaId = null)),
              for (final c in categorias)
                _chip(c.nombre, _categoriaId == c.id,
                        () => setState(() => _categoriaId = c.id)),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
              if (filtrados.isEmpty) {
                return const Center(
                    child: Text('Aún no hay ingredientes aquí.'));
              }
              return ListView.separated(
                itemCount: filtrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, k) {
                  final i = filtrados[k];
                  return Card(
                    margin: EdgeInsets.zero,
                    color: Colors.white,
                    elevation: 0,
                    child: ListTile(
                      title: Text(i.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle:
                      Text(nombres[i.categoriaId] ?? 'Sin categoría'),
                      trailing: Text(
                        _cantidad(i),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NuevoIngredientePantalla(),
            ),
          ),
          child: const Text('+ Agregar ingrediente'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}