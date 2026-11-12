import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

/// Columnas que el teléfono puede subir a cada tabla de Postgres.
///
/// Es una lista PERMITIDA (no una lista de prohibidas): una columna nueva
/// del teléfono no viaja hasta que alguien la agregue aquí a propósito.
/// Así nunca suben stock / costo_unitario (solo locales hasta la etapa E).
///
/// locales y miembros no están: el teléfono no los escribe (se crean con
/// crear_local() en el servidor). Al agregar movimientos, platos y
/// receta_items a la sincronización (etapas E y F), se suman aquí.
const columnasPermitidas = <String, Set<String>>{
  'categorias': {'local_id', 'nombre', 'orden', 'creado_en', 'actualizado_en'},
  'ingredientes': {
    'local_id', 'nombre', 'categoria_id', 'unidad', 'stock_minimo',
    'archivado', 'creado_en', 'actualizado_en',
  },
};

/// Columnas booleanas: en el teléfono son 0/1, en Postgres true/false.
const _booleanas = <String, Set<String>>{
  'ingredientes': {'archivado'},
};

/// Deja solo las columnas permitidas de [tabla] y convierte los booleanos.
/// Devuelve null si la tabla no se puede subir.
Map<String, dynamic>? prepararFila(String tabla, Map<String, dynamic> datos) {
  final permitidas = columnasPermitidas[tabla];
  if (permitidas == null) return null;
  final booleanas = _booleanas[tabla] ?? const {};
  return {
    for (final MapEntry(:key, :value) in datos.entries)
      if (permitidas.contains(key))
        key: booleanas.contains(key) && value is num ? value != 0 : value,
  };
}

/// Errores que no se arreglan reintentando: el servidor dijo "no".
/// - 42501: RLS o permisos negados.  - 22xxx: dato inválido.
/// - 23xxx: viola una regla (check, llave foránea...).
/// - PGRSTxxx: PostgREST rechazó la petición (p. ej. columna inexistente),
///   salvo PGRST3xx: token vencido o inválido, se arregla renovándolo.
/// Cualquier otro error (sin internet, servidor caído) se reintenta.
bool esErrorPermanente(Object error) {
  if (error is! PostgrestException) return false;
  final codigo = error.code ?? '';
  return codigo == '42501' ||
      codigo.startsWith('22') ||
      codigo.startsWith('23') ||
      (codigo.startsWith('PGRST') && !codigo.startsWith('PGRST3'));
}

/// Tabla que el teléfono no puede subir (no está en [columnasPermitidas]).
class TablaNoPermitida implements Exception {
  final String tabla;
  const TablaNoPermitida(this.tabla);
  @override
  String toString() => 'La tabla $tabla no se sube desde el teléfono';
}
