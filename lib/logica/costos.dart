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