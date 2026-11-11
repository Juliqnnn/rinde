import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/proveedores.dart';
import 'package:rinde/funciones/platos/datos/proveedores_platos.dart';
import 'package:rinde/comun/logica/costos.dart';
import 'package:rinde/comun/logica/formato.dart';
import 'package:rinde/funciones/platos/logica/fotos.dart';
import 'package:rinde/funciones/platos/pantallas/foto_plato.dart';
import 'package:rinde/funciones/ingredientes/pantallas/selector_ingrediente.dart';

class NuevoPlatoPantalla extends ConsumerStatefulWidget {
  const NuevoPlatoPantalla({super.key});

  @override
  ConsumerState<NuevoPlatoPantalla> createState() => _NuevoPlatoPantallaState();
}

class _NuevoPlatoPantallaState extends ConsumerState<NuevoPlatoPantalla> {
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _costo = TextEditingController();
  final List<ItemReceta> _items = [];
  String? _fotoRuta; // foto elegida, todavía sin copiar a la app
  String? _errorNombre;
  String? _errorPrecio;

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _costo.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  // Con ingredientes se calcula; sin ellos vale lo que escribas.
  double get _costoTotal => _items.isEmpty
      ? _num(_costo)
      : costoDeItems(
      _items.map((i) => (i.cantidad, i.ingrediente.costoUnitario)));

  Future<void> _cambiarFoto() async {
    final r = await pedirFoto(context, puedeQuitar: _fotoRuta != null);
    if (r == null || !mounted) return;
    setState(() => _fotoRuta = r.ruta);
  }

  Future<void> _agregarIngrediente() async {
    final item = await Navigator.push<ItemReceta>(
      context,
      MaterialPageRoute(builder: (_) => const SelectorIngredientePantalla()),
    );
    if (item == null) return;
    setState(() {
      final k =
      _items.indexWhere((x) => x.ingrediente.id == item.ingrediente.id);
      if (k >= 0) {
        _items[k] =
            ItemReceta(item.ingrediente, _items[k].cantidad + item.cantidad);
      } else {
        _items.add(item);
      }
    });
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final precio = _num(_precio);
    String? errorNombre;
    String? errorPrecio;
    if (nombre.isEmpty) {
      errorNombre = 'Ponle un nombre al plato';
    } else {
      final existentes = ref.read(platosProvider).asData?.value ?? [];
      final igual =
      existentes.where((p) => normalizar(p.nombre) == normalizar(nombre));
      if (igual.isNotEmpty) {
        errorNombre = 'Ya tienes «${igual.first.nombre}» en tu lista';
      }
    }
    if (precio <= 0) errorPrecio = 'Escribe el precio de venta';
    if (errorNombre != null || errorPrecio != null) {
      setState(() {
        _errorNombre = errorNombre;
        _errorPrecio = errorPrecio;
      });
      return;
    }
    final foto = _fotoRuta == null ? null : await guardarFoto(_fotoRuta!);
    await ref.read(baseDeDatosProvider).crearPlato(
      nombre: nombre,
      precioVenta: precio,
      costoManual: _items.isEmpty ? _num(_costo) : 0,
      foto: foto,
      receta: [
        for (final i in _items)
          (ingredienteId: i.ingrediente.id, cantidad: i.cantidad),
      ],
    );
    if (mounted) Navigator.pop(context, true);
  }

  Widget _campo(
      TextEditingController c,
      String etiqueta, {
        String? prefijo,
        bool numerico = true,
        String? error,
      }) {
    return TextField(
      controller: c,
      keyboardType: numerico
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      textCapitalization:
      numerico ? TextCapitalization.none : TextCapitalization.sentences,
      onChanged: (_) => setState(() {
        _errorNombre = null;
        _errorPrecio = null;
      }),
      decoration: InputDecoration(
        labelText: etiqueta,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: numerico ? '0' : null,
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

  Widget _bloqueFoto() {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            InkWell(
              onTap: _cambiarFoto,
              child: FotoPlato(
                nombre: _nombre.text,
                rutaLocal: _fotoRuta,
                tamano: 72,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¿Alguna foto que represente este plato?',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const Text('Opcional',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: _cambiarFoto,
                    child: Text(
                        _fotoRuta == null ? '+ Agregar foto' : 'Cambiar foto'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _resumen() {
    final precio = _num(_precio);
    if (precio <= 0) return null;
    final costo = _costoTotal;
    final ganancia = precio - costo;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ganancia < 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ganancia por plato: ${pesos(ganancia)}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          Text('Margen: ${porcentaje(margen(precio, costo))}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _resumen();
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo plato')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _bloqueFoto(),
          const SizedBox(height: 12),
          _campo(_nombre, 'Nombre', numerico: false, error: _errorNombre),
          const SizedBox(height: 12),
          _campo(_precio, 'Precio de venta',
              prefijo: '\$', error: _errorPrecio),
          const SizedBox(height: 12),
          if (_items.isEmpty) ...[
            _campo(_costo, 'Costo del plato (lo escribes tú)', prefijo: '\$'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Text.rich(TextSpan(children: [
                TextSpan(
                    text: 'Sugerencia: ',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(
                    text:
                    'agrega los ingredientes y Rinde calculará tu costo real y te avisará cuando se acabe el stock. Puedes hacerlo ahora o más tarde.'),
              ])),
            ),
          ] else ...[
            const Text('Ingredientes',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            for (final i in _items)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.white,
                elevation: 0,
                child: ListTile(
                  title: Text(i.ingrediente.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle:
                  Text(cantidadDe(i.cantidad, i.ingrediente.unidad)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pesos(i.cantidad * i.ingrediente.costoUnitario),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        tooltip: 'Quitar',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _items.remove(i)),
                      ),
                    ],
                  ),
                ),
              ),
            Text('Costo calculado: ${pesos(_costoTotal)}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _agregarIngrediente,
            child: Text(_items.isEmpty
                ? '+ Agregar ingredientes (opcional)'
                : '+ Agregar otro ingrediente'),
          ),
          if (resumen != null) ...[const SizedBox(height: 12), resumen],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: _guardar,
            child: const Text('Guardar plato'),
          ),
        ),
      ),
    );
  }
}