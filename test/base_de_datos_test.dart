import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:powersync/powersync.dart';
import 'package:rinde/comun/datos/base_de_datos.dart';
import 'package:rinde/comun/datos/esquema_powersync.dart';

// Prueba Drift sobre la base real de PowerSync (sin conectarse a la nube):
// que las vistas acepten lo que escribe Drift y que se lea bien.
void main() {
  late Directory carpeta;
  late PowerSyncDatabase ps;
  late BaseDeDatos db;
  const localA = 'aaaaaaaa-0000-4000-8000-000000000001';
  const localB = 'bbbbbbbb-0000-4000-8000-000000000002';

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('rinde_test');
    ps = PowerSyncDatabase(
      schema: esquemaPowerSync,
      path: '${carpeta.path}/prueba.db',
    );
    await ps.initialize();
    db = BaseDeDatos(ps, localId: localA);
  });

  tearDown(() async {
    await db.close();
    await ps.close();
    await carpeta.delete(recursive: true);
  });

  test('crear ingrediente con stock: guarda local_id y anota movimiento',
      () async {
    final catId = await db.crearCategoria('Panes');
    final id = await db.crearIngrediente(
      nombre: 'Pan de completo',
      unidad: Unidad.unidades,
      categoriaId: catId,
      costoUnitario: 150,
      stock: 20,
    );

    final ing = await db.ingredientePorId(id);
    expect(ing.localId, localA);
    expect(ing.categoriaId, catId);
    expect(ing.unidad, Unidad.unidades);
    expect(ing.stock, 20);
    expect(ing.archivado, isFalse);

    final movs = await db.select(db.movimientos).get();
    expect(movs, hasLength(1));
    expect(movs.single.localId, localA);
    expect(movs.single.cantidad, 20);
  });

  test('compra recalcula costo promedio y ajuste anota la diferencia',
      () async {
    final id = await db.crearIngrediente(
      nombre: 'Palta',
      unidad: Unidad.gramos,
      costoUnitario: 10,
      stock: 1000,
    );
    await db.registrarCompra(
        ingredienteId: id, cantidad: 1000, precioTotal: 20000);
    var ing = await db.ingredientePorId(id);
    expect(ing.stock, 2000);
    expect(ing.costoUnitario, 15);

    await db.ajustarStock(ingredienteId: id, stockReal: 1800, motivo: 'merma');
    ing = await db.ingredientePorId(id);
    expect(ing.stock, 1800);
  });

  test('fechas vuelven como DateTime (guardadas como texto)', () async {
    final antes = DateTime.now().subtract(const Duration(seconds: 1));
    final id =
        await db.crearIngrediente(nombre: 'Tomate', unidad: Unidad.gramos);
    final ing = await db.ingredientePorId(id);
    expect(ing.creadoEn.isAfter(antes), isTrue);
  });

  test('ingrediente bajado de la nube sin stock ni costo se lee como 0',
      () async {
    // Así llega una fila sincronizada: sin las columnas solo locales.
    await ps.execute(
      'INSERT INTO ingredientes (id, local_id, nombre, unidad, stock_minimo, '
      'archivado, creado_en, actualizado_en) '
      "VALUES (uuid(), ?, 'Mayo', 'gramos', 0, 0, "
      "'2026-11-12 15:00:00.123456Z', '2026-11-12 15:00:00.123456Z')",
      [localA],
    );
    final ing = (await db.select(db.ingredientes).get()).single;
    expect(ing.stock, 0);
    expect(ing.costoUnitario, 0);
    expect(ing.creadoEn.toUtc(), DateTime.utc(2026, 11, 12, 15, 0, 0, 123, 456));
  });

  test('un ingrediente de otro local no se puede leer ni archivar por su id',
      () async {
    const ajeno = 'cccccccc-0000-4000-8000-000000000003';
    await ps.execute(
      'INSERT INTO ingredientes (id, local_id, nombre, unidad, archivado) '
      "VALUES (?, ?, 'Queso', 'gramos', 0)",
      [ajeno, localB],
    );
    await expectLater(db.ingredientePorId(ajeno), throwsStateError);

    await db.archivarIngrediente(ajeno);
    final fila = await ps.get(
        'SELECT archivado FROM ingredientes WHERE id = ?', [ajeno]);
    expect(fila['archivado'], 0);
  });
}
