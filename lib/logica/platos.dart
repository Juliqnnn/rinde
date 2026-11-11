import '../datos/base_de_datos.dart';
import 'costos.dart';

class CostoPlato {
  final double costo; // $ por plato
  final bool conReceta;
  const CostoPlato(this.costo, this.conReceta);
}

// Con ingredientes, el costo se calcula. Sin ellos, vale el costo manual.
CostoPlato calcularCosto(
    Plato plato,
    List<RecetaItem> recetas,
    Map<String, Ingrediente> ingredientes,
    ) {
  final propios = recetas.where((r) => r.platoId == plato.id).toList();
  if (propios.isEmpty) return CostoPlato(plato.costoManual, false);
  final costo = costoDeItems([
    for (final r in propios)
      if (ingredientes[r.ingredienteId] != null)
        (r.cantidad, ingredientes[r.ingredienteId]!.costoUnitario),
  ]);
  return CostoPlato(costo, true);
}