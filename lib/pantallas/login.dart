import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../datos/sesion.dart';
import '../tema/colores.dart';

class LoginPantalla extends ConsumerStatefulWidget {
  const LoginPantalla({super.key});

  @override
  ConsumerState<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends ConsumerState<LoginPantalla> {
  bool _cargando = false;
  String? _error;

  Future<void> _entrar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref.read(sesionProvider).entrarConGoogle();
      // No navegamos: al cambiar la sesión, main.dart muestra la app sola.
    } on GoogleSignInException catch (e) {
      // Si el usuario cerró el selector de cuentas no es un error.
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _error = 'No se pudo entrar con Google (${e.code.name}).';
      }
    } catch (e) {
      _error = 'No se pudo entrar: $e';
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colores.crema,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Rinde',
                textAlign: TextAlign.center,
                style: texto.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colores.aji,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stock, recetas y ventas de tu local.',
                textAlign: TextAlign.center,
                style: texto.titleMedium?.copyWith(color: Colores.pizarra),
              ),
              const Spacer(),
              if (!nubeConfigurada)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Falta config.json. Corre la app con '
                    '--dart-define-from-file=config.json',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colores.rojo),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colores.rojo),
                  ),
                ),
              FilledButton.icon(
                onPressed: _cargando || !nubeConfigurada ? null : _entrar,
                icon: _cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Continuar con Google'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
