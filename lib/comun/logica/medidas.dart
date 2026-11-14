import 'package:rinde/comun/datos/base_de_datos.dart';

enum Medida { kg, g, l, ml, u }

extension MedidaX on Medida {
  String get etiqueta => switch (this) {
    Medida.kg => 'kg',
    Medida.g => 'g',
    Medida.l => 'L',
    Medida.ml => 'ml',
    Medida.u => 'u',
  };

  String get nombre => switch (this) {
    Medida.kg => 'Kilos (kg)',
    Medida.g => 'Gramos (g)',
    Medida.l => 'Litros (L)',
    Medida.ml => 'Mililitros (ml)',
    Medida.u => 'Unidades',
  };

  Unidad get base => switch (this) {
    Medida.kg || Medida.g => Unidad.gramos,
    Medida.l || Medida.ml => Unidad.mililitros,
    Medida.u => Unidad.unidades,
  };

  // Cuántos g, ml o u hay en 1 de esta medida.
  double get factor => (this == Medida.kg || this == Medida.l) ? 1000 : 1;
}

// Las medidas que tienen sentido para un ingrediente ya creado.
List<Medida> medidasPara(Unidad u) => switch (u) {
  Unidad.gramos => [Medida.kg, Medida.g],
  Unidad.mililitros => [Medida.l, Medida.ml],
  Unidad.unidades => [Medida.u],
};