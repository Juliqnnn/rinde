import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:rinde/funciones/sesion/sesion.dart';

/// Error parecido al que lanza Supabase cuando no hay internet.
class _SinRed implements Exception {}

void main() {
  // En el test, el "usuario" es un texto: lo que importa es la regla.
  late StreamController<Object?> eventos;
  String? actual;

  setUp(() {
    eventos = StreamController<Object?>();
    actual = 'julian';
  });
  tearDown(() => eventos.close());

  Stream<String?> seguir({void Function(Object)? alError}) =>
      seguirUsuario<String>(eventos.stream, () => actual, alError: alError);

  test('al arrancar entrega la sesión guardada', () {
    expect(seguir(), emits('julian'));
  });

  test('sin internet: un error al renovar el token NO cierra la sesión',
      () async {
    final errores = <Object>[];
    final emitidos = <String?>[];
    final sub = seguir(alError: errores.add).listen(emitidos.add);

    eventos.add('initialSession');
    eventos.addError(_SinRed()); // falla la renovación del token
    eventos.addError(_SinRed()); // el auto refresh reintenta y vuelve a fallar
    await pumpEventQueue();

    expect(emitidos, ['julian', 'julian']);
    expect(emitidos, isNot(contains(null)));
    expect(errores, hasLength(2));

    // Vuelve internet: el token se renueva y el stream sigue vivo.
    eventos.add('tokenRefreshed');
    await pumpEventQueue();
    expect(emitidos.last, 'julian');
    await sub.cancel();
  });

  test('un error antiguo repetido al suscribirse (ReplaySubject) se ignora',
      () async {
    eventos.addError(_SinRed()); // ocurrió antes de que la app escuchara
    eventos.add('initialSession');
    final emitidos = await seguir().take(2).toList();
    expect(emitidos, ['julian', 'julian']);
  });

  test('cerrar sesión de verdad (signedOut) sí entrega null', () async {
    final emitidos = <String?>[];
    final sub = seguir().listen(emitidos.add);
    await pumpEventQueue();

    actual = null; // Supabase borra la sesión antes de avisar signedOut
    eventos.add('signedOut');
    await pumpEventQueue();

    expect(emitidos, ['julian', null]);
    await sub.cancel();
  });
}
