import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/proveedores.dart';
import 'package:rinde/funciones/ingredientes/datos/proveedores_ingredientes.dart';
import 'package:rinde/comun/logica/formato.dart';
import 'package:rinde/comun/logica/medidas.dart';
import 'package:rinde/comun/tema/colores.dart';

enum Inicio { compre, yaTenia, sinStock }

class NuevoIngredientePantalla extends ConsumerStatefulWidget {
  final String? nombreInicial;

  const NuevoIngredientePantalla({super.key, this.nombreInicial});

  @override
  ConsumerState<NuevoIngredientePantalla> createState() =>
      _NuevoIngredientePantallaState();
}

class _NuevoIngredientePantallaState
    extends ConsumerState<NuevoIngredientePantalla> {
  final _nombre = TextEditingController();
  final _cantidad = TextEditingController();
  final _precio = TextEditingController();
  final _costoRef = TextEditingController();
  String? _categoriaId;
  Medida _medida = Medida.kg;
  Inicio _inicio = Inicio.compre;
  String? _errorNombre;
  String? _errorCantidad;
  @override
  void initState() {
    super.initState();
    _nombre.text = widget.nombreInicial ?? '';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _cantidad.dispose();
    _precio.dispose();
    _costoRef.dispose();
    super.dispose();
  }

  double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  String get _grande => switch (_medida.base) {
    Unidad.gramos => 'kg',
    Unidad.mililitros => 'L',
    Unidad.unidades => 'unidad',
  };

  // Costo por g, ml o unidad, según cómo parte el ingrediente.
  double get _costoBase {
    final cantidad = _num(_cantidad) * _medida.factor;
    if (_inicio == Inicio.compre) {
      return cantidad > 0 ? _num(_precio) / cantidad : 0;
    }
    if (_inicio == Inicio.yaTenia) {
      return _num(_costoRef) / (_medida.base == Unidad.unidades ? 1 : 1000);
    }
    return 0;
  }

  Future<void> _nuevaCategoria() async {
    final c = TextEditingController();
    final existentes = ref.read(categoriasProvider).asData?.value ?? [];
    String? error;
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogo) => AlertDialog(
          title: const Text('Nueva categoría'),
          content: TextField(
            controller: c,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setDialogo(() => error = null),
            decoration: InputDecoration(
              hintText: 'Ej: Congelados',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final texto = c.text.trim();
                if (texto.isEmpty) {
                  setDialogo(() => error = 'Escribe un nombre');
                  return;
                }
                final igual = existentes
                    .where((e) => normalizar(e.nombre) == normalizar(texto));
                if (igual.isNotEmpty) {
                  setDialogo(() =>
                  error = 'Ya existe la categoría «${igual.first.nombre}»');
                  return;
                }
                Navigator.pop(ctx, texto);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    if (nombre == null) return;
    final id = await ref.read(baseDeDatosProvider).crearCategoria(nombre);
    if (mounted) setState(() => _categoriaId = id);
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    final cantidad = _num(_cantidad) * _medida.factor;
    String? errorNombre;
    String? errorCantidad;
    if (nombre.isEmpty) {
      errorNombre = 'Ponle un nombre al ingrediente';
    } else {
      final existentes = ref.read(ingredientesProvider).asData?.value ?? [];
      final igual = existentes
          .where((i) => normalizar(i.nombre) == normalizar(nombre));
      if (igual.isNotEmpty) {
        errorNombre = 'Ya tienes «${igual.first.nombre}» en tu lista';
      }
    }
    if (_inicio != Inicio.sinStock && cantidad <= 0) {
      errorCantidad = 'Escribe cuánto hay';
    }
    if (errorNombre != null || errorCantidad != null) {
      setState(() {
        _errorNombre = errorNombre;
        _errorCantidad = errorCantidad;
      });
      return;
    }
    final id = await ref.read(baseDeDatosProvider).crearIngrediente(
      nombre: nombre,
      unidad: _medida.base,
      categoriaId: _categoriaId,
      costoUnitario: _costoBase,
      stock: _inicio == Inicio.sinStock ? 0 : cantidad,
      tipo: _inicio == Inicio.compre
          ? TipoMovimiento.compra
          : TipoMovimiento.inicial,
    );
    if (mounted) Navigator.pop(context, id);
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
      onChanged: (_) => setState(() {
        _errorNombre = null;
        _errorCantidad = null;
      }),
      decoration: InputDecoration(
        labelText: etiqueta,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: numerico ? '0' : null,
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

  Widget _menuMedida() {
    return PopupMenuButton<Medida>(
      initialValue: _medida,
      onSelected: (m) => setState(() => _medida = m),
      itemBuilder: (_) => [
        for (final m in Medida.values)
          PopupMenuItem(value: m, child: Text(m.nombre)),
      ],
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colores.pizarra,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _medida.etiqueta,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _opcionInicio(Inicio v, IconData icono, String titulo, String sub) {
    final activo = _inicio == v;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() {
          _inicio = v;
          _errorCantidad = null;
        }),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: activo ? const Color(0xFFFFF7ED) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: activo ? Colores.aji : const Color(0xFFE9DFD2),
              width: activo ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icono, color: activo ? Colores.aji : Colores.pizarra),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(sub,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              if (activo) const Icon(Icons.check_circle, color: Colores.aji),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _pista() {
    final costo = _costoBase;
    if (costo <= 0) return null;
    final u = _medida.base;
    final texto = u == Unidad.unidades
        ? 'Costo: ${pesos(costo, costo < 10 ? 1 : 0)} por unidad.'
        : 'Costo: ${pesos(costo * 1000)} por $_grande '
        '(${pesos(costo, costo < 10 ? 1 : 0)} por '
        '${u == Unidad.gramos ? 'gramo' : 'ml'}).';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
          '$texto Rinde usa este valor para calcular el costo de tus platos.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ref.watch(categoriasProvider).asData?.value ?? [];
    final pista = _pista();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo ingrediente')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campo(_nombre, 'Nombre',
                    numerico: false, error: _errorNombre),
              ),
              const SizedBox(width: 8),
              _menuMedida(),
            ],
          ),
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
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Nueva'),
                backgroundColor: Colors.white,
                onPressed: _nuevaCategoria,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('¿Con cuánto stock parte?',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _opcionInicio(Inicio.compre, Icons.shopping_basket_outlined,
              'Lo compré ahora', 'Cuánto compraste y a qué precio'),
          _opcionInicio(Inicio.yaTenia, Icons.inventory_2_outlined,
              'Ya lo tenía', 'Cuánto tienes y cuánto te cuesta, más o menos'),
          _opcionInicio(Inicio.sinStock, Icons.hourglass_empty,
              'Sin stock por ahora', 'Lo creas y cargas el stock después'),
          if (_inicio != Inicio.sinStock) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _campo(
                    _cantidad,
                    _inicio == Inicio.compre
                        ? 'Cantidad que compraste'
                        : 'Cantidad que tienes',
                    sufijo: _medida.etiqueta,
                    error: _errorCantidad,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _inicio == Inicio.compre
                      ? _campo(_precio, 'Precio que pagaste', prefijo: '\$')
                      : _campo(_costoRef, 'Costo por $_grande (aprox.)',
                      prefijo: '\$'),
                ),
              ],
            ),
            if (pista != null) ...[
              const SizedBox(height: 12),
              pista,
            ],
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
}