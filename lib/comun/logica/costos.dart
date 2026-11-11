// Costo promedio ponderado.
// Mezcla el valor del stock que ya tienes con el de la compra nueva.
// Con stock en cero o negativo, el costo es el de la compra.
double costoPromedio({
  required double stockActual,
  required double costoActual,
  required double cantidadNueva,
  required double costoNuevo,
}) {
  final base = stockActual > 0 ? stockActual : 0.0;
  final total = base + cantidadNueva;
  if (total <= 0) return costoNuevo;
  return (base * costoActual + cantidadNueva * costoNuevo) / total;
}

// Costo de un plato: suma de (cantidad × costo por g, ml o u) de cada ingrediente.
double costoDeItems(Iterable<(double, double)> items) {
  var total = 0.0;
  for (final (cantidad, costoUnitario) in items) {
    total += cantidad * costoUnitario;
  }
  return total;
}

// Margen = (precio − costo) ÷ precio. Sin precio no hay margen.
double? margen(double precio, double costo) =>
    precio > 0 ? (precio - costo) / precio : null;