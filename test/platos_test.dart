import 'package:flutter_test/flutter_test.dart';
import 'package:rinde/logica/costos.dart';

void main() {
  test('costo de un plato con ingredientes', () {
    // 1 pan a $250, 60 g de palta a $5,8 por g, 40 g de tomate a $1,5 por g
    final costo = costoDeItems([(1.0, 250.0), (60.0, 5.8), (40.0, 1.5)]);
    expect(costo, closeTo(658, 0.001));
  });

  test('un plato sin ingredientes cuesta cero', () {
    expect(costoDeItems([]), 0);
  });

  test('margen del completo de la guía: 62,5 %', () {
    expect(margen(2800, 1050), closeTo(0.625, 0.0001));
  });

  test('sin precio no hay margen', () {
    expect(margen(0, 100), isNull);
  });
}