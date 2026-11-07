import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datos/base_de_datos.dart';
import '../datos/proveedores.dart';
import '../tema/colores.dart';

String _pesos(double n, [int dec = 0]) {
  final partes = n.toStringAsFixed(dec).split('.');
  final entero = partes[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '\$$entero${dec > 0 ? ',${partes[1]}' : ''}';
}

class NuevoIngredientePantalla extends ConsumerStatefulWidget {
  const NuevoIngredientePantalla({super.key});

  @override
  ConsumerState<NuevoIngredientePantalla> createState() =>
      _NuevoIngredientePantallaState();
}

class _NuevoIngredientePantallaState
    extends ConsumerState<NuevoIngredientePantalla> {
  final _nombre = TextEditingController();
  final _compra = TextEditingController();
  final _precio = TextEditingController();
  String? _categoriaId;
  Unidad _unidad = Unidad.gramos;
  bool _enGrande = true; // true = kg o L, false = g o ml
  String? _errorNombre;

  @override
  void dispose() {
    _nombre.dispose();
    _compra.dispose();
    _precio.dispose();
    super.dispose();
  }

  double _valor(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  // Cuántas g, ml o u hay en 1 de la unidad en que compraste.
  double get _factor {
    if (_unidad == Unidad.unidades) return 1;
    return _enGrande ? 1000 : 1;
  }

  String get _grande => switch (_unidad) {
    Unidad.gramos => 'kg',
    Unidad.mililitros => 'L',
    Unidad.unidades => 'u',
  };

  String get _chica => switch (_unidad) {
    Unidad.gramos => 'gramo',
    Unidad.mililitros => 'ml',
    Unidad.unidades => 'unidad',
  };

  // La unidad en que compraste, para mostrar junto a la cantidad.
  String get _etiquetaCompra => switch (_unidad) {
    Unidad.gramos => _enGrande ? 'kg' : 'g',
    Unidad.mililitros => _enGrande ? 'L' : 'ml',
    Unidad.unidades => 'u',
  };

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _errorNombre = 'Ponle un nombre al ingrediente');
      return;
    }
    final compra = _valor(_compra);
    final precio = _valor(_precio);
    final costoBase = compra > 0 ? precio / (compra * _factor) : 0.0;

    final db = ref.read(baseDeDatosProvider);
    await db.into(db.ingredientes).insert(
      IngredientesCompanion.insert(
        nombre: nombre,
        unidad: _unidad,
        categoriaId: Value(_categoriaId),
        costoUnitario: Value(costoBase),
        // La primera compra es el stock inicial.
        stock: Value(compra * _factor),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Widget _campo(
      TextEditingController c,
      String etiqueta, {
        String? sufijo,
        String? prefijo,
        bool numerico = true,
        String? error,
      }) {
    return TextField(
      controller: c,
      keyboardType: numerico
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      onChanged: (_) => setState(() => _errorNombre = null),
      decoration: InputDecoration(
        labelText: etiqueta,
        suffixText: sufijo,
        prefixText: prefijo,
        errorText: error,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProvider).asData?.value ?? [];
    final compra = _valor(_compra);
    final precio = _valor(_precio);
    final costoBase = compra > 0 ? precio / (compra * _factor) : 0.0;
    final porGrande = costoBase * _factor1000;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo ingrediente')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _campo(_nombre, 'Nombre', numerico: false, error: _errorNombre),
          const SizedBox(height: 16),
          const Text('Categoría',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final c in categorias)
                ChoiceChip(
                  label: Text(c.nombre),
                  selected: _categoriaId == c.id,
                  showCheckmark: false,
                  selectedColor: Colores.pizarra,
                  labelStyle: TextStyle(
                    color:
                    _categoriaId == c.id ? Colors.white : Colores.pizarra,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (v) =>
                      setState(() => _categoriaId = v ? c.id : null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Unidad>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: Unidad.gramos, label: Text('Peso')),
                ButtonSegment(
                    value: Unidad.mililitros, label: Text('Líquido')),
                ButtonSegment(value: Unidad.unidades, label: Text('Unidad')),
              ],
              selected: {_unidad},
              onSelectionChanged: (s) => setState(() {
                _unidad = s.first;
                _enGrande = true;
              }),
            ),
          ),
          if (_unidad != Unidad.unidades) ...[
            const SizedBox(height: 12),
            const Text('¿En qué lo compraste?',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(_unidad == Unidad.gramos
                        ? 'Kilos (kg)'
                        : 'Litros (L)'),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(_unidad == Unidad.gramos
                        ? 'Gramos (g)'
                        : 'Mililitros (ml)'),
                  ),
                ],
                selected: {_enGrande},
                onSelectionChanged: (s) =>
                    setState(() => _enGrande = s.first),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _campo(_compra, 'Cantidad que compraste',
                      sufijo: _etiquetaCompra)),
              const SizedBox(width: 12),
              Expanded(
                  child: _campo(_precio, 'Precio que pagaste', prefijo: '\$')),
            ],
          ),
          if (compra > 0 && precio > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _unidad == Unidad.unidades
                    ? 'Costo: ${_pesos(costoBase, costoBase < 10 ? 1 : 0)} por unidad. '
                    'Rinde usa este valor para calcular el costo de tus platos.'
                    : 'Costo: ${_pesos(porGrande)} por $_grande '
                    '(${_pesos(costoBase, costoBase < 10 ? 1 : 0)} por $_chica). '
                    'Rinde usa este valor para calcular el costo de tus platos.',
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: _guardar,
            child: const Text('Guardar ingrediente'),
          ),
        ),
      ),
    );
  }

  double get _factor1000 => _unidad == Unidad.unidades ? 1 : 1000;
}