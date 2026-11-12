import 'package:flutter_test/flutter_test.dart';
import 'package:rinde/funciones/local/local.dart';
import 'package:rinde/funciones/sincronizacion/subida.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

void main() {
  group('prepararFila', () {
    test('ingredientes: no sube stock ni costo y convierte archivado', () {
      final fila = prepararFila('ingredientes', {
        'local_id': 'L',
        'nombre': 'Palta',
        'unidad': 'gramos',
        'archivado': 1,
        'stock': 500.0,
        'costo_unitario': 12.0,
        'creado_en': '2026-11-12T20:03:17.847070 -03:00',
      });
      expect(fila, {
        'local_id': 'L',
        'nombre': 'Palta',
        'unidad': 'gramos',
        'archivado': true,
        'creado_en': '2026-11-12T20:03:17.847070 -03:00',
      });
    });

    test('un patch que solo cambió stock queda vacío', () {
      expect(prepararFila('ingredientes', {'stock': 10.0}), isEmpty);
    });

    test('locales, miembros y tablas desconocidas no se suben', () {
      expect(prepararFila('locales', {'nombre': 'x'}), isNull);
      expect(prepararFila('miembros', {'rol': 'dueno'}), isNull);
      expect(prepararFila('otra', {'a': 1}), isNull);
    });
  });

  group('esErrorPermanente', () {
    PostgrestException error(String codigo) =>
        PostgrestException(message: 'x', code: codigo);

    test('RLS, datos inválidos y reglas: permanentes', () {
      expect(esErrorPermanente(error('42501')), isTrue);
      expect(esErrorPermanente(error('22P02')), isTrue);
      expect(esErrorPermanente(error('23503')), isTrue);
      expect(esErrorPermanente(error('PGRST204')), isTrue);
    });

    test('token vencido y errores de red: se reintentan', () {
      expect(esErrorPermanente(error('PGRST301')), isFalse);
      expect(esErrorPermanente(Exception('sin internet')), isFalse);
    });
  });

  group('elegirLocal', () {
    const a = Local(id: 'a', nombre: 'Uno');
    const b = Local(id: 'b', nombre: 'Dos');

    test('sin locales → null', () => expect(elegirLocal([], 'a'), isNull));
    test('respeta el guardado', () => expect(elegirLocal([a, b], 'b'), b));
    test('guardado ajeno o inexistente → el primero', () {
      expect(elegirLocal([a, b], 'otro'), a);
      expect(elegirLocal([a, b], null), a);
    });
  });
}
