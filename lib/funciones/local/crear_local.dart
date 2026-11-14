import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rinde/comun/tema/colores.dart';
import 'package:rinde/funciones/local/local.dart';
import 'package:rinde/funciones/sesion/sesion.dart';

class CrearLocalPantalla extends ConsumerStatefulWidget {
  const CrearLocalPantalla({super.key});

  @override
  ConsumerState<CrearLocalPantalla> createState() => _CrearLocalPantallaState();
}

class _CrearLocalPantallaState extends ConsumerState<CrearLocalPantalla> {
  final _nombre = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Escribe el nombre de tu local.');
      return;
    }
    final usuario = ref.read(usuarioProvider).asData?.value;
    if (usuario == null) return;

    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref.read(localRepositorioProvider).crear(usuario.id, nombre);
      // Listo: sigue "cargando" hasta que el local llegue sincronizado;
      // entonces localProvider cambia y la puerta muestra la app sola.
      return;
    } on LocalError catch (e) {
      _error = e.mensaje;
    } catch (_) {
      _error = 'No se pudo crear el local. Revisa tu conexión a internet.';
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colores.crema,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'Crea tu local',
                style: texto.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colores.pizarra,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Es el nombre de tu negocio. Podrás cambiarlo después.',
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nombre,
                autofocus: true,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _cargando ? null : _crear(),
                decoration: const InputDecoration(
                  labelText: 'Nombre del local',
                  hintText: 'Ej: Completos Don Julián',
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!,
                      style: const TextStyle(color: Colores.rojo)),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _cargando ? null : _crear,
                child: _cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear local'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    _cargando ? null : () => ref.read(sesionProvider).salir(),
                child: const Text('Usar otra cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
