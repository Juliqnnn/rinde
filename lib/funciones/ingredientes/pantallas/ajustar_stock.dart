import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/proveedores.dart';
import 'package:rinde/comun/logica/formato.dart';
import 'package:rinde/comun/logica/medidas.dart';
import 'package:rinde/comun/tema/colores.dart';

const _motivos = ['Conteo', 'Merma', 'Regalo o consumo', 'Otro'];

class AjustarStockPantalla extends ConsumerStatefulWidget {
  final Ingrediente ingrediente;

  const AjustarStockPantalla({super.key, required this.ingrediente});

  @override
  ConsumerState<AjustarStockPantalla> createState() =>
      _AjustarStockPantallaState();
}

class _AjustarStockPantallaState extends ConsumerState<AjustarStockPantalla> {
  final _real = TextEditingController();
  late Medida _medida = medidasPara(widget.ingrediente.unidad).first;
  String _motivo = 'Conteo';
  String? _error;

  @override
  void dispose() {
    _real.dispose();
    super.dispose();
  }

  bool get _vacio => _real.text.trim().isEmpty;

  double get _realBase =>
      (double.tryParse(_real.text.replaceAll(',', '.')) ?? 0) * _medida.factor;

  Future<void> _guardar() async {
    if (_vacio) {
      setState(() => _error = 'Escribe cuánto hay realmente');
      return;
    }
    await ref.read(baseDeDatosProvider).ajustarStock(
      ingredienteId: widget.ingrediente.id,
      stockReal: _realBase,
      motivo: _motivo,
    );
    if (mounted) Navigator.pop(context);
  }

  Widget? _resumen() {
    if (_vacio) return null;
    final ing = widget.ingrediente;
    final dif = _realBase - ing.stock;
    if (dif == 0) {
      return _caja(const Color(0xFFF2EADF), 'No hay diferencia con lo anotado.');
    }
    if (dif < 0) {
      final perdida = -dif * ing.costoUnitario;
      return _caja(
        const Color(0xFFFEF2F2),
        'Faltan ${cantidadDe(-dif, ing.unidad)}'
            '${perdida > 0 ? ' · Pérdida: ${pesos(perdida)}' : ''}',
      );
    }
    return _caja(const Color(0xFFF0FDF4),
        'Sobran ${cantidadDe(dif, ing.unidad)} respecto a lo anotado.');
  }

  Widget _caja(Color color, String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(texto, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ing = widget.ingrediente;
    final opciones = medidasPara(ing.unidad);
    final resumen = _resumen();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustar stock')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text(ing.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('En la app hay ${cantidadDe(ing.stock, ing.unidad)}'),
            ),
          ),
          const SizedBox(height: 16),
          if (opciones.length > 1) ...[
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<Medida>(
                showSelectedIcon: false,
                segments: [
                  for (final m in opciones)
                    ButtonSegment(value: m, label: Text(m.nombre)),
                ],
                selected: {_medida},
                onSelectionChanged: (s) => setState(() => _medida = s.first),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _real,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: '¿Cuánto hay realmente?',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: '0',
              suffixText: _medida.etiqueta,
              errorText: _error,
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Motivo', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final m in _motivos)
                ChoiceChip(
                  label: Text(m),
                  selected: _motivo == m,
                  showCheckmark: false,
                  selectedColor: Colores.pizarra,
                  labelStyle: TextStyle(
                    color: _motivo == m ? Colors.white : Colores.pizarra,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _motivo = m),
                ),
            ],
          ),
          if (resumen != null) ...[const SizedBox(height: 16), resumen],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: _guardar,
            child: const Text('Guardar ajuste'),
          ),
        ),
      ),
    );
  }
}