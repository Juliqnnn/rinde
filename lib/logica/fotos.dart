import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../tema/colores.dart';

// El resultado de elegir una foto. ruta == null significa «quitar la foto».
class FotoElegida {
  final String? ruta;
  const FotoElegida(this.ruta);
}

// Carpeta donde viven las fotos de la app.
Future<Directory> carpetaFotos() async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory('${base.path}/fotos');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

// Copia la foto elegida a la carpeta de la app y devuelve solo su nombre.
Future<String> guardarFoto(String rutaTemporal) async {
  final dir = await carpetaFotos();
  final nombre = '${const Uuid().v4()}.jpg';
  await File(rutaTemporal).copy('${dir.path}/$nombre');
  return nombre;
}

Future<void> borrarFoto(String nombre) async {
  final f = File('${(await carpetaFotos()).path}/$nombre');
  if (await f.exists()) await f.delete();
}

Future<FotoElegida?> pedirFoto(
    BuildContext context, {
      bool puedeQuitar = false,
    }) async {
  final origen = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tomar foto'),
            onTap: () => Navigator.pop(ctx, 'camara'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(ctx, 'galeria'),
          ),
          if (puedeQuitar)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colores.rojo),
              title: const Text('Quitar foto',
                  style: TextStyle(color: Colores.rojo)),
              onTap: () => Navigator.pop(ctx, 'quitar'),
            ),
        ],
      ),
    ),
  );
  if (origen == null) return null;
  if (origen == 'quitar') return const FotoElegida(null);
  try {
    final foto = await ImagePicker().pickImage(
      source: origen == 'camara' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1000,
      imageQuality: 80,
    );
    if (foto == null) return null;
    return FotoElegida(foto.path);
  } catch (_) {
    return null;
  }
}