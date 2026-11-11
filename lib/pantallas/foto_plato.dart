import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logica/fotos.dart';
import '../tema/colores.dart';

final carpetaFotosProvider =
FutureProvider<String>((ref) async => (await carpetaFotos()).path);

class FotoPlato extends ConsumerWidget {
  final String nombre;
  final String? foto; // nombre del archivo ya guardado
  final String? rutaLocal; // foto recién elegida, todavía sin guardar
  final double tamano;

  const FotoPlato({
    super.key,
    required this.nombre,
    this.foto,
    this.rutaLocal,
    this.tamano = 48,
  });

  Widget _letra() {
    final n = nombre.trim();
    return Container(
      color: const Color(0xFFF9ECE7),
      alignment: Alignment.center,
      child: Text(
        n.isEmpty ? '?' : n[0].toUpperCase(),
        style: TextStyle(
          fontSize: tamano * 0.45,
          fontWeight: FontWeight.w800,
          color: Colores.aji,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget imagen;
    if (rutaLocal != null) {
      imagen = Image.file(File(rutaLocal!),
          fit: BoxFit.cover, errorBuilder: (_, _, _) => _letra());
    } else if (foto != null) {
      final dir = ref.watch(carpetaFotosProvider).asData?.value;
      imagen = dir == null
          ? _letra()
          : Image.file(File('$dir/$foto'),
          fit: BoxFit.cover, errorBuilder: (_, _, _) => _letra());
    } else {
      imagen = _letra();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(tamano * 0.25),
      child: SizedBox(width: tamano, height: tamano, child: imagen),
    );
  }
}