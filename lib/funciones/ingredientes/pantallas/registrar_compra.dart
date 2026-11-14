import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/proveedores.dart';
import 'package:rinde/comun/logica/costos.dart';
import 'package:rinde/comun/logica/formato.dart';
import 'package:rinde/comun/logica/medidas.dart';

class RegistrarCompraPantalla extends ConsumerStatefulWidget {
  final Ingrediente ingrediente;

  const RegistrarCompraPantalla({super.key, required this.ingrediente});

  @override
  ConsumerState<RegistrarCompraPantalla> createState() =>
      _RegistrarCompraPantallaState();
}

class _RegistrarCompraPantallaState
    extends ConsumerState<RegistrarCompraPantalla> {
  final _cantidad = TextEditingController();
  final _precio = TextEditingController();
  late Medida _medida = medidasPara(widget.ingrediente.unidad).first;
  String? _error;

  @override
  void dispose() {
    _cantidad.dispose();
    _precio.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  double get _cantidadBase => _num(_cantidad) * _medida.factor;

  Future<void> _guardar() async {
    if (_cantidadBase <= 0 || _num(_precio) <= 0) {
      setState(() => _error = 'Escribe cuánto compraste y cuánto pagaste');
      return;
    }
    await ref.read(baseDeDatosProvider).registrarCompra(
      ingredienteId: widget.ingrediente.id,
      cantidad: _cantidadBase,
      precioTotal: _num(_precio),
    );
    if (mounted) Navigator.pop(context);
  }

  Widget _campo(TextEditingController c, String etiqueta,
      {String? sufijo, String? prefijo}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() => _error = null),
      decoration: InputDecoration(
        labelText: etiqueta,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: '0',
        suffixText: sufijo,
        prefixText: prefijo,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget? _resumen() {
    final ing = widget.ingrediente;
    final cantidad = _cantidadBase;
    final precio = _num(_precio);
    if (cantidad <= 0 || precio <= 0) return null;
    final costoCompra = precio / cantidad;
    final nuevo = costoPromedio(
      stockActual: ing.stock,
      costoActual: ing.costoUnitario,
      cantidadNueva: cantidad,
      costoNuevo: costoCompra,
    );
    final antes = ing.costoUnitario > 0
        ? ' (antes ${costoPorUnidad(ing.costoUnitario, ing.unidad)})'
        : '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Esta compra: ${costoPorUnidad(costoCompra, ing.unidad)}'),
          const SizedBox(height: 4),
          Text(
            'Costo promedio: ${costoPorUnidad(nuevo, ing.unidad)}$antes',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
              'Tu stock quedará en ${cantidadDe(ing.stock + cantidad, ing.unidad)}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ing = widget.ingrediente;
    final opciones = medidasPara(ing.unidad);
    final resumen = _resumen();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar compra')),
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
              subtitle: Text('Tienes ${cantidadDe(ing.stock, ing.unidad)}'),
            ),
          ),
          const SizedBox(height: 16),
          if (opciones.length > 1) ...[
            const Text('¿En qué lo compraste?',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campo(_cantidad, 'Cantidad que compraste',
                    sufijo: _medida.etiqueta),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(_precio, 'Precio total pagado', prefijo: '\$'),
              ),
            ],
          ),
          if (resumen != null) ...[const SizedBox(height: 12), resumen],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: _guardar,
            child: const Text('Guardar compra'),
          ),
        ),
      ),
    );
  }
}