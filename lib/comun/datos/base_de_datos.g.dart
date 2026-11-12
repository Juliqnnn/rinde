// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_de_datos.dart';

// ignore_for_file: type=lint
class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: () => DateTime.now(),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localId,
    nombre,
    orden,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final String id;
  final String localId;
  final String nombre;
  final int orden;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const Categoria({
    required this.id,
    required this.localId,
    required this.nombre,
    required this.orden,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_id'] = Variable<String>(localId);
    map['nombre'] = Variable<String>(nombre);
    map['orden'] = Variable<int>(orden);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      localId: Value(localId),
      nombre: Value(nombre),
      orden: Value(orden),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<String>(json['id']),
      localId: serializer.fromJson<String>(json['localId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      orden: serializer.fromJson<int>(json['orden']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localId': serializer.toJson<String>(localId),
      'nombre': serializer.toJson<String>(nombre),
      'orden': serializer.toJson<int>(orden),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  Categoria copyWith({
    String? id,
    String? localId,
    String? nombre,
    int? orden,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => Categoria(
    id: id ?? this.id,
    localId: localId ?? this.localId,
    nombre: nombre ?? this.nombre,
    orden: orden ?? this.orden,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      localId: data.localId.present ? data.localId.value : this.localId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      orden: data.orden.present ? data.orden.value : this.orden,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('nombre: $nombre, ')
          ..write('orden: $orden, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, localId, nombre, orden, creadoEn, actualizadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.localId == this.localId &&
          other.nombre == this.nombre &&
          other.orden == this.orden &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<String> id;
  final Value<String> localId;
  final Value<String> nombre;
  final Value<int> orden;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<int> rowid;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.localId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.orden = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String localId,
    required String nombre,
    this.orden = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       nombre = Value(nombre);
  static Insertable<Categoria> custom({
    Expression<String>? id,
    Expression<String>? localId,
    Expression<String>? nombre,
    Expression<int>? orden,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localId != null) 'local_id': localId,
      if (nombre != null) 'nombre': nombre,
      if (orden != null) 'orden': orden,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriasCompanion copyWith({
    Value<String>? id,
    Value<String>? localId,
    Value<String>? nombre,
    Value<int>? orden,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      nombre: nombre ?? this.nombre,
      orden: orden ?? this.orden,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('nombre: $nombre, ')
          ..write('orden: $orden, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientesTable extends Ingredientes
    with TableInfo<$IngredientesTable, Ingrediente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<String> categoriaId = GeneratedColumn<String>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Unidad, String> unidad =
      GeneratedColumn<String>(
        'unidad',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Unidad>($IngredientesTable.$converterunidad);
  @override
  late final GeneratedColumnWithTypeConverter<double, double> costoUnitario =
      GeneratedColumn<double>(
        'costo_unitario',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        clientDefault: () => 0,
      ).withConverter<double>($IngredientesTable.$convertercostoUnitario);
  @override
  late final GeneratedColumnWithTypeConverter<double, double> stock =
      GeneratedColumn<double>(
        'stock',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        clientDefault: () => 0,
      ).withConverter<double>($IngredientesTable.$converterstock);
  static const VerificationMeta _stockMinimoMeta = const VerificationMeta(
    'stockMinimo',
  );
  @override
  late final GeneratedColumn<double> stockMinimo = GeneratedColumn<double>(
    'stock_minimo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _archivadoMeta = const VerificationMeta(
    'archivado',
  );
  @override
  late final GeneratedColumn<bool> archivado = GeneratedColumn<bool>(
    'archivado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archivado" IN (0, 1))',
    ),
    clientDefault: () => false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: () => DateTime.now(),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localId,
    nombre,
    categoriaId,
    unidad,
    costoUnitario,
    stock,
    stockMinimo,
    archivado,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingrediente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
        _stockMinimoMeta,
        stockMinimo.isAcceptableOrUnknown(
          data['stock_minimo']!,
          _stockMinimoMeta,
        ),
      );
    }
    if (data.containsKey('archivado')) {
      context.handle(
        _archivadoMeta,
        archivado.isAcceptableOrUnknown(data['archivado']!, _archivadoMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingrediente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingrediente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria_id'],
      ),
      unidad: $IngredientesTable.$converterunidad.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unidad'],
        )!,
      ),
      costoUnitario: $IngredientesTable.$convertercostoUnitario.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}costo_unitario'],
        ),
      ),
      stock: $IngredientesTable.$converterstock.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}stock'],
        ),
      ),
      stockMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_minimo'],
      )!,
      archivado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archivado'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $IngredientesTable createAlias(String alias) {
    return $IngredientesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Unidad, String, String> $converterunidad =
      const EnumNameConverter<Unidad>(Unidad.values);
  static TypeConverter<double, double?> $convertercostoUnitario =
      const _CeroSiNulo();
  static TypeConverter<double, double?> $converterstock = const _CeroSiNulo();
}

class Ingrediente extends DataClass implements Insertable<Ingrediente> {
  final String id;
  final String localId;
  final String nombre;
  final String? categoriaId;
  final Unidad unidad;
  final double costoUnitario;
  final double stock;
  final double stockMinimo;
  final bool archivado;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const Ingrediente({
    required this.id,
    required this.localId,
    required this.nombre,
    this.categoriaId,
    required this.unidad,
    required this.costoUnitario,
    required this.stock,
    required this.stockMinimo,
    required this.archivado,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_id'] = Variable<String>(localId);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<String>(categoriaId);
    }
    {
      map['unidad'] = Variable<String>(
        $IngredientesTable.$converterunidad.toSql(unidad),
      );
    }
    {
      map['costo_unitario'] = Variable<double>(
        $IngredientesTable.$convertercostoUnitario.toSql(costoUnitario),
      );
    }
    {
      map['stock'] = Variable<double>(
        $IngredientesTable.$converterstock.toSql(stock),
      );
    }
    map['stock_minimo'] = Variable<double>(stockMinimo);
    map['archivado'] = Variable<bool>(archivado);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  IngredientesCompanion toCompanion(bool nullToAbsent) {
    return IngredientesCompanion(
      id: Value(id),
      localId: Value(localId),
      nombre: Value(nombre),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      unidad: Value(unidad),
      costoUnitario: Value(costoUnitario),
      stock: Value(stock),
      stockMinimo: Value(stockMinimo),
      archivado: Value(archivado),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory Ingrediente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingrediente(
      id: serializer.fromJson<String>(json['id']),
      localId: serializer.fromJson<String>(json['localId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      categoriaId: serializer.fromJson<String?>(json['categoriaId']),
      unidad: $IngredientesTable.$converterunidad.fromJson(
        serializer.fromJson<String>(json['unidad']),
      ),
      costoUnitario: serializer.fromJson<double>(json['costoUnitario']),
      stock: serializer.fromJson<double>(json['stock']),
      stockMinimo: serializer.fromJson<double>(json['stockMinimo']),
      archivado: serializer.fromJson<bool>(json['archivado']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localId': serializer.toJson<String>(localId),
      'nombre': serializer.toJson<String>(nombre),
      'categoriaId': serializer.toJson<String?>(categoriaId),
      'unidad': serializer.toJson<String>(
        $IngredientesTable.$converterunidad.toJson(unidad),
      ),
      'costoUnitario': serializer.toJson<double>(costoUnitario),
      'stock': serializer.toJson<double>(stock),
      'stockMinimo': serializer.toJson<double>(stockMinimo),
      'archivado': serializer.toJson<bool>(archivado),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  Ingrediente copyWith({
    String? id,
    String? localId,
    String? nombre,
    Value<String?> categoriaId = const Value.absent(),
    Unidad? unidad,
    double? costoUnitario,
    double? stock,
    double? stockMinimo,
    bool? archivado,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => Ingrediente(
    id: id ?? this.id,
    localId: localId ?? this.localId,
    nombre: nombre ?? this.nombre,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    unidad: unidad ?? this.unidad,
    costoUnitario: costoUnitario ?? this.costoUnitario,
    stock: stock ?? this.stock,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    archivado: archivado ?? this.archivado,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  Ingrediente copyWithCompanion(IngredientesCompanion data) {
    return Ingrediente(
      id: data.id.present ? data.id.value : this.id,
      localId: data.localId.present ? data.localId.value : this.localId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      unidad: data.unidad.present ? data.unidad.value : this.unidad,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
      stock: data.stock.present ? data.stock.value : this.stock,
      stockMinimo: data.stockMinimo.present
          ? data.stockMinimo.value
          : this.stockMinimo,
      archivado: data.archivado.present ? data.archivado.value : this.archivado,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingrediente(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('nombre: $nombre, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('unidad: $unidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('stock: $stock, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('archivado: $archivado, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localId,
    nombre,
    categoriaId,
    unidad,
    costoUnitario,
    stock,
    stockMinimo,
    archivado,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingrediente &&
          other.id == this.id &&
          other.localId == this.localId &&
          other.nombre == this.nombre &&
          other.categoriaId == this.categoriaId &&
          other.unidad == this.unidad &&
          other.costoUnitario == this.costoUnitario &&
          other.stock == this.stock &&
          other.stockMinimo == this.stockMinimo &&
          other.archivado == this.archivado &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class IngredientesCompanion extends UpdateCompanion<Ingrediente> {
  final Value<String> id;
  final Value<String> localId;
  final Value<String> nombre;
  final Value<String?> categoriaId;
  final Value<Unidad> unidad;
  final Value<double> costoUnitario;
  final Value<double> stock;
  final Value<double> stockMinimo;
  final Value<bool> archivado;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<int> rowid;
  const IngredientesCompanion({
    this.id = const Value.absent(),
    this.localId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.unidad = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.stock = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.archivado = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientesCompanion.insert({
    this.id = const Value.absent(),
    required String localId,
    required String nombre,
    this.categoriaId = const Value.absent(),
    required Unidad unidad,
    this.costoUnitario = const Value.absent(),
    this.stock = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.archivado = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       nombre = Value(nombre),
       unidad = Value(unidad);
  static Insertable<Ingrediente> custom({
    Expression<String>? id,
    Expression<String>? localId,
    Expression<String>? nombre,
    Expression<String>? categoriaId,
    Expression<String>? unidad,
    Expression<double>? costoUnitario,
    Expression<double>? stock,
    Expression<double>? stockMinimo,
    Expression<bool>? archivado,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localId != null) 'local_id': localId,
      if (nombre != null) 'nombre': nombre,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (unidad != null) 'unidad': unidad,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (stock != null) 'stock': stock,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (archivado != null) 'archivado': archivado,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientesCompanion copyWith({
    Value<String>? id,
    Value<String>? localId,
    Value<String>? nombre,
    Value<String?>? categoriaId,
    Value<Unidad>? unidad,
    Value<double>? costoUnitario,
    Value<double>? stock,
    Value<double>? stockMinimo,
    Value<bool>? archivado,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return IngredientesCompanion(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      nombre: nombre ?? this.nombre,
      categoriaId: categoriaId ?? this.categoriaId,
      unidad: unidad ?? this.unidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      stock: stock ?? this.stock,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      archivado: archivado ?? this.archivado,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<String>(categoriaId.value);
    }
    if (unidad.present) {
      map['unidad'] = Variable<String>(
        $IngredientesTable.$converterunidad.toSql(unidad.value),
      );
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<double>(
        $IngredientesTable.$convertercostoUnitario.toSql(costoUnitario.value),
      );
    }
    if (stock.present) {
      map['stock'] = Variable<double>(
        $IngredientesTable.$converterstock.toSql(stock.value),
      );
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<double>(stockMinimo.value);
    }
    if (archivado.present) {
      map['archivado'] = Variable<bool>(archivado.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientesCompanion(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('nombre: $nombre, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('unidad: $unidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('stock: $stock, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('archivado: $archivado, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovimientosTable extends Movimientos
    with TableInfo<$MovimientosTable, Movimiento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredienteIdMeta = const VerificationMeta(
    'ingredienteId',
  );
  @override
  late final GeneratedColumn<String> ingredienteId = GeneratedColumn<String>(
    'ingrediente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoMovimiento, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoMovimiento>($MovimientosTable.$convertertipo);
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoUnitarioMeta = const VerificationMeta(
    'costoUnitario',
  );
  @override
  late final GeneratedColumn<double> costoUnitario = GeneratedColumn<double>(
    'costo_unitario',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localId,
    ingredienteId,
    tipo,
    cantidad,
    costoUnitario,
    motivo,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Movimiento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('ingrediente_id')) {
      context.handle(
        _ingredienteIdMeta,
        ingredienteId.isAcceptableOrUnknown(
          data['ingrediente_id']!,
          _ingredienteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredienteIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
        _costoUnitarioMeta,
        costoUnitario.isAcceptableOrUnknown(
          data['costo_unitario']!,
          _costoUnitarioMeta,
        ),
      );
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Movimiento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Movimiento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      ingredienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingrediente_id'],
      )!,
      tipo: $MovimientosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      costoUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_unitario'],
      ),
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $MovimientosTable createAlias(String alias) {
    return $MovimientosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoMovimiento, String, String> $convertertipo =
      const EnumNameConverter<TipoMovimiento>(TipoMovimiento.values);
}

class Movimiento extends DataClass implements Insertable<Movimiento> {
  final String id;
  final String localId;
  final String ingredienteId;
  final TipoMovimiento tipo;
  final double cantidad;
  final double? costoUnitario;
  final String? motivo;
  final DateTime fecha;
  const Movimiento({
    required this.id,
    required this.localId,
    required this.ingredienteId,
    required this.tipo,
    required this.cantidad,
    this.costoUnitario,
    this.motivo,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_id'] = Variable<String>(localId);
    map['ingrediente_id'] = Variable<String>(ingredienteId);
    {
      map['tipo'] = Variable<String>(
        $MovimientosTable.$convertertipo.toSql(tipo),
      );
    }
    map['cantidad'] = Variable<double>(cantidad);
    if (!nullToAbsent || costoUnitario != null) {
      map['costo_unitario'] = Variable<double>(costoUnitario);
    }
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  MovimientosCompanion toCompanion(bool nullToAbsent) {
    return MovimientosCompanion(
      id: Value(id),
      localId: Value(localId),
      ingredienteId: Value(ingredienteId),
      tipo: Value(tipo),
      cantidad: Value(cantidad),
      costoUnitario: costoUnitario == null && nullToAbsent
          ? const Value.absent()
          : Value(costoUnitario),
      motivo: motivo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivo),
      fecha: Value(fecha),
    );
  }

  factory Movimiento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Movimiento(
      id: serializer.fromJson<String>(json['id']),
      localId: serializer.fromJson<String>(json['localId']),
      ingredienteId: serializer.fromJson<String>(json['ingredienteId']),
      tipo: $MovimientosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      costoUnitario: serializer.fromJson<double?>(json['costoUnitario']),
      motivo: serializer.fromJson<String?>(json['motivo']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localId': serializer.toJson<String>(localId),
      'ingredienteId': serializer.toJson<String>(ingredienteId),
      'tipo': serializer.toJson<String>(
        $MovimientosTable.$convertertipo.toJson(tipo),
      ),
      'cantidad': serializer.toJson<double>(cantidad),
      'costoUnitario': serializer.toJson<double?>(costoUnitario),
      'motivo': serializer.toJson<String?>(motivo),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  Movimiento copyWith({
    String? id,
    String? localId,
    String? ingredienteId,
    TipoMovimiento? tipo,
    double? cantidad,
    Value<double?> costoUnitario = const Value.absent(),
    Value<String?> motivo = const Value.absent(),
    DateTime? fecha,
  }) => Movimiento(
    id: id ?? this.id,
    localId: localId ?? this.localId,
    ingredienteId: ingredienteId ?? this.ingredienteId,
    tipo: tipo ?? this.tipo,
    cantidad: cantidad ?? this.cantidad,
    costoUnitario: costoUnitario.present
        ? costoUnitario.value
        : this.costoUnitario,
    motivo: motivo.present ? motivo.value : this.motivo,
    fecha: fecha ?? this.fecha,
  );
  Movimiento copyWithCompanion(MovimientosCompanion data) {
    return Movimiento(
      id: data.id.present ? data.id.value : this.id,
      localId: data.localId.present ? data.localId.value : this.localId,
      ingredienteId: data.ingredienteId.present
          ? data.ingredienteId.value
          : this.ingredienteId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Movimiento(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('ingredienteId: $ingredienteId, ')
          ..write('tipo: $tipo, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('motivo: $motivo, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localId,
    ingredienteId,
    tipo,
    cantidad,
    costoUnitario,
    motivo,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Movimiento &&
          other.id == this.id &&
          other.localId == this.localId &&
          other.ingredienteId == this.ingredienteId &&
          other.tipo == this.tipo &&
          other.cantidad == this.cantidad &&
          other.costoUnitario == this.costoUnitario &&
          other.motivo == this.motivo &&
          other.fecha == this.fecha);
}

class MovimientosCompanion extends UpdateCompanion<Movimiento> {
  final Value<String> id;
  final Value<String> localId;
  final Value<String> ingredienteId;
  final Value<TipoMovimiento> tipo;
  final Value<double> cantidad;
  final Value<double?> costoUnitario;
  final Value<String?> motivo;
  final Value<DateTime> fecha;
  final Value<int> rowid;
  const MovimientosCompanion({
    this.id = const Value.absent(),
    this.localId = const Value.absent(),
    this.ingredienteId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.motivo = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovimientosCompanion.insert({
    this.id = const Value.absent(),
    required String localId,
    required String ingredienteId,
    required TipoMovimiento tipo,
    required double cantidad,
    this.costoUnitario = const Value.absent(),
    this.motivo = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       ingredienteId = Value(ingredienteId),
       tipo = Value(tipo),
       cantidad = Value(cantidad);
  static Insertable<Movimiento> custom({
    Expression<String>? id,
    Expression<String>? localId,
    Expression<String>? ingredienteId,
    Expression<String>? tipo,
    Expression<double>? cantidad,
    Expression<double>? costoUnitario,
    Expression<String>? motivo,
    Expression<DateTime>? fecha,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localId != null) 'local_id': localId,
      if (ingredienteId != null) 'ingrediente_id': ingredienteId,
      if (tipo != null) 'tipo': tipo,
      if (cantidad != null) 'cantidad': cantidad,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (motivo != null) 'motivo': motivo,
      if (fecha != null) 'fecha': fecha,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovimientosCompanion copyWith({
    Value<String>? id,
    Value<String>? localId,
    Value<String>? ingredienteId,
    Value<TipoMovimiento>? tipo,
    Value<double>? cantidad,
    Value<double?>? costoUnitario,
    Value<String?>? motivo,
    Value<DateTime>? fecha,
    Value<int>? rowid,
  }) {
    return MovimientosCompanion(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      ingredienteId: ingredienteId ?? this.ingredienteId,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      motivo: motivo ?? this.motivo,
      fecha: fecha ?? this.fecha,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (ingredienteId.present) {
      map['ingrediente_id'] = Variable<String>(ingredienteId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $MovimientosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<double>(costoUnitario.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosCompanion(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('ingredienteId: $ingredienteId, ')
          ..write('tipo: $tipo, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('motivo: $motivo, ')
          ..write('fecha: $fecha, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlatosTable extends Platos with TableInfo<$PlatosTable, Plato> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioVentaMeta = const VerificationMeta(
    'precioVenta',
  );
  @override
  late final GeneratedColumn<double> precioVenta = GeneratedColumn<double>(
    'precio_venta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoManualMeta = const VerificationMeta(
    'costoManual',
  );
  @override
  late final GeneratedColumn<double> costoManual = GeneratedColumn<double>(
    'costo_manual',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    clientDefault: () => 0,
  );
  static const VerificationMeta _fotoMeta = const VerificationMeta('foto');
  @override
  late final GeneratedColumn<String> foto = GeneratedColumn<String>(
    'foto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoExternoMeta = const VerificationMeta(
    'codigoExterno',
  );
  @override
  late final GeneratedColumn<String> codigoExterno = GeneratedColumn<String>(
    'codigo_externo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivadoMeta = const VerificationMeta(
    'archivado',
  );
  @override
  late final GeneratedColumn<bool> archivado = GeneratedColumn<bool>(
    'archivado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archivado" IN (0, 1))',
    ),
    clientDefault: () => false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: () => DateTime.now(),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localId,
    nombre,
    precioVenta,
    costoManual,
    foto,
    codigoExterno,
    archivado,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'platos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plato> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
        _precioVentaMeta,
        precioVenta.isAcceptableOrUnknown(
          data['precio_venta']!,
          _precioVentaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioVentaMeta);
    }
    if (data.containsKey('costo_manual')) {
      context.handle(
        _costoManualMeta,
        costoManual.isAcceptableOrUnknown(
          data['costo_manual']!,
          _costoManualMeta,
        ),
      );
    }
    if (data.containsKey('foto')) {
      context.handle(
        _fotoMeta,
        foto.isAcceptableOrUnknown(data['foto']!, _fotoMeta),
      );
    }
    if (data.containsKey('codigo_externo')) {
      context.handle(
        _codigoExternoMeta,
        codigoExterno.isAcceptableOrUnknown(
          data['codigo_externo']!,
          _codigoExternoMeta,
        ),
      );
    }
    if (data.containsKey('archivado')) {
      context.handle(
        _archivadoMeta,
        archivado.isAcceptableOrUnknown(data['archivado']!, _archivadoMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plato map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plato(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      precioVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_venta'],
      )!,
      costoManual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_manual'],
      )!,
      foto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto'],
      ),
      codigoExterno: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_externo'],
      ),
      archivado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archivado'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $PlatosTable createAlias(String alias) {
    return $PlatosTable(attachedDatabase, alias);
  }
}

class Plato extends DataClass implements Insertable<Plato> {
  final String id;
  final String localId;
  final String nombre;
  final double precioVenta;
  final double costoManual;
  final String? foto;
  final String? codigoExterno;
  final bool archivado;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const Plato({
    required this.id,
    required this.localId,
    required this.nombre,
    required this.precioVenta,
    required this.costoManual,
    this.foto,
    this.codigoExterno,
    required this.archivado,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_id'] = Variable<String>(localId);
    map['nombre'] = Variable<String>(nombre);
    map['precio_venta'] = Variable<double>(precioVenta);
    map['costo_manual'] = Variable<double>(costoManual);
    if (!nullToAbsent || foto != null) {
      map['foto'] = Variable<String>(foto);
    }
    if (!nullToAbsent || codigoExterno != null) {
      map['codigo_externo'] = Variable<String>(codigoExterno);
    }
    map['archivado'] = Variable<bool>(archivado);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  PlatosCompanion toCompanion(bool nullToAbsent) {
    return PlatosCompanion(
      id: Value(id),
      localId: Value(localId),
      nombre: Value(nombre),
      precioVenta: Value(precioVenta),
      costoManual: Value(costoManual),
      foto: foto == null && nullToAbsent ? const Value.absent() : Value(foto),
      codigoExterno: codigoExterno == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoExterno),
      archivado: Value(archivado),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory Plato.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plato(
      id: serializer.fromJson<String>(json['id']),
      localId: serializer.fromJson<String>(json['localId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      precioVenta: serializer.fromJson<double>(json['precioVenta']),
      costoManual: serializer.fromJson<double>(json['costoManual']),
      foto: serializer.fromJson<String?>(json['foto']),
      codigoExterno: serializer.fromJson<String?>(json['codigoExterno']),
      archivado: serializer.fromJson<bool>(json['archivado']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localId': serializer.toJson<String>(localId),
      'nombre': serializer.toJson<String>(nombre),
      'precioVenta': serializer.toJson<double>(precioVenta),
      'costoManual': serializer.toJson<double>(costoManual),
      'foto': serializer.toJson<String?>(foto),
      'codigoExterno': serializer.toJson<String?>(codigoExterno),
      'archivado': serializer.toJson<bool>(archivado),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  Plato copyWith({
    String? id,
    String? localId,
    String? nombre,
    double? precioVenta,
    double? costoManual,
    Value<String?> foto = const Value.absent(),
    Value<String?> codigoExterno = const Value.absent(),
    bool? archivado,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => Plato(
    id: id ?? this.id,
    localId: localId ?? this.localId,
    nombre: nombre ?? this.nombre,
    precioVenta: precioVenta ?? this.precioVenta,
    costoManual: costoManual ?? this.costoManual,
    foto: foto.present ? foto.value : this.foto,
    codigoExterno: codigoExterno.present
        ? codigoExterno.value
        : this.codigoExterno,
    archivado: archivado ?? this.archivado,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  Plato copyWithCompanion(PlatosCompanion data) {
    return Plato(
      id: data.id.present ? data.id.value : this.id,
      localId: data.localId.present ? data.localId.value : this.localId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      precioVenta: data.precioVenta.present
          ? data.precioVenta.value
          : this.precioVenta,
      costoManual: data.costoManual.present
          ? data.costoManual.value
          : this.costoManual,
      foto: data.foto.present ? data.foto.value : this.foto,
      codigoExterno: data.codigoExterno.present
          ? data.codigoExterno.value
          : this.codigoExterno,
      archivado: data.archivado.present ? data.archivado.value : this.archivado,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plato(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('nombre: $nombre, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('costoManual: $costoManual, ')
          ..write('foto: $foto, ')
          ..write('codigoExterno: $codigoExterno, ')
          ..write('archivado: $archivado, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localId,
    nombre,
    precioVenta,
    costoManual,
    foto,
    codigoExterno,
    archivado,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plato &&
          other.id == this.id &&
          other.localId == this.localId &&
          other.nombre == this.nombre &&
          other.precioVenta == this.precioVenta &&
          other.costoManual == this.costoManual &&
          other.foto == this.foto &&
          other.codigoExterno == this.codigoExterno &&
          other.archivado == this.archivado &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class PlatosCompanion extends UpdateCompanion<Plato> {
  final Value<String> id;
  final Value<String> localId;
  final Value<String> nombre;
  final Value<double> precioVenta;
  final Value<double> costoManual;
  final Value<String?> foto;
  final Value<String?> codigoExterno;
  final Value<bool> archivado;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<int> rowid;
  const PlatosCompanion({
    this.id = const Value.absent(),
    this.localId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.costoManual = const Value.absent(),
    this.foto = const Value.absent(),
    this.codigoExterno = const Value.absent(),
    this.archivado = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlatosCompanion.insert({
    this.id = const Value.absent(),
    required String localId,
    required String nombre,
    required double precioVenta,
    this.costoManual = const Value.absent(),
    this.foto = const Value.absent(),
    this.codigoExterno = const Value.absent(),
    this.archivado = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       nombre = Value(nombre),
       precioVenta = Value(precioVenta);
  static Insertable<Plato> custom({
    Expression<String>? id,
    Expression<String>? localId,
    Expression<String>? nombre,
    Expression<double>? precioVenta,
    Expression<double>? costoManual,
    Expression<String>? foto,
    Expression<String>? codigoExterno,
    Expression<bool>? archivado,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localId != null) 'local_id': localId,
      if (nombre != null) 'nombre': nombre,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (costoManual != null) 'costo_manual': costoManual,
      if (foto != null) 'foto': foto,
      if (codigoExterno != null) 'codigo_externo': codigoExterno,
      if (archivado != null) 'archivado': archivado,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlatosCompanion copyWith({
    Value<String>? id,
    Value<String>? localId,
    Value<String>? nombre,
    Value<double>? precioVenta,
    Value<double>? costoManual,
    Value<String?>? foto,
    Value<String?>? codigoExterno,
    Value<bool>? archivado,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return PlatosCompanion(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      nombre: nombre ?? this.nombre,
      precioVenta: precioVenta ?? this.precioVenta,
      costoManual: costoManual ?? this.costoManual,
      foto: foto ?? this.foto,
      codigoExterno: codigoExterno ?? this.codigoExterno,
      archivado: archivado ?? this.archivado,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<double>(precioVenta.value);
    }
    if (costoManual.present) {
      map['costo_manual'] = Variable<double>(costoManual.value);
    }
    if (foto.present) {
      map['foto'] = Variable<String>(foto.value);
    }
    if (codigoExterno.present) {
      map['codigo_externo'] = Variable<String>(codigoExterno.value);
    }
    if (archivado.present) {
      map['archivado'] = Variable<bool>(archivado.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatosCompanion(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('nombre: $nombre, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('costoManual: $costoManual, ')
          ..write('foto: $foto, ')
          ..write('codigoExterno: $codigoExterno, ')
          ..write('archivado: $archivado, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecetaItemsTable extends RecetaItems
    with TableInfo<$RecetaItemsTable, RecetaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecetaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platoIdMeta = const VerificationMeta(
    'platoId',
  );
  @override
  late final GeneratedColumn<String> platoId = GeneratedColumn<String>(
    'plato_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredienteIdMeta = const VerificationMeta(
    'ingredienteId',
  );
  @override
  late final GeneratedColumn<String> ingredienteId = GeneratedColumn<String>(
    'ingrediente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localId,
    platoId,
    ingredienteId,
    cantidad,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receta_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecetaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('plato_id')) {
      context.handle(
        _platoIdMeta,
        platoId.isAcceptableOrUnknown(data['plato_id']!, _platoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_platoIdMeta);
    }
    if (data.containsKey('ingrediente_id')) {
      context.handle(
        _ingredienteIdMeta,
        ingredienteId.isAcceptableOrUnknown(
          data['ingrediente_id']!,
          _ingredienteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredienteIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecetaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecetaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      platoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plato_id'],
      )!,
      ingredienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingrediente_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
    );
  }

  @override
  $RecetaItemsTable createAlias(String alias) {
    return $RecetaItemsTable(attachedDatabase, alias);
  }
}

class RecetaItem extends DataClass implements Insertable<RecetaItem> {
  final String id;
  final String localId;
  final String platoId;
  final String ingredienteId;
  final double cantidad;
  const RecetaItem({
    required this.id,
    required this.localId,
    required this.platoId,
    required this.ingredienteId,
    required this.cantidad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_id'] = Variable<String>(localId);
    map['plato_id'] = Variable<String>(platoId);
    map['ingrediente_id'] = Variable<String>(ingredienteId);
    map['cantidad'] = Variable<double>(cantidad);
    return map;
  }

  RecetaItemsCompanion toCompanion(bool nullToAbsent) {
    return RecetaItemsCompanion(
      id: Value(id),
      localId: Value(localId),
      platoId: Value(platoId),
      ingredienteId: Value(ingredienteId),
      cantidad: Value(cantidad),
    );
  }

  factory RecetaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecetaItem(
      id: serializer.fromJson<String>(json['id']),
      localId: serializer.fromJson<String>(json['localId']),
      platoId: serializer.fromJson<String>(json['platoId']),
      ingredienteId: serializer.fromJson<String>(json['ingredienteId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localId': serializer.toJson<String>(localId),
      'platoId': serializer.toJson<String>(platoId),
      'ingredienteId': serializer.toJson<String>(ingredienteId),
      'cantidad': serializer.toJson<double>(cantidad),
    };
  }

  RecetaItem copyWith({
    String? id,
    String? localId,
    String? platoId,
    String? ingredienteId,
    double? cantidad,
  }) => RecetaItem(
    id: id ?? this.id,
    localId: localId ?? this.localId,
    platoId: platoId ?? this.platoId,
    ingredienteId: ingredienteId ?? this.ingredienteId,
    cantidad: cantidad ?? this.cantidad,
  );
  RecetaItem copyWithCompanion(RecetaItemsCompanion data) {
    return RecetaItem(
      id: data.id.present ? data.id.value : this.id,
      localId: data.localId.present ? data.localId.value : this.localId,
      platoId: data.platoId.present ? data.platoId.value : this.platoId,
      ingredienteId: data.ingredienteId.present
          ? data.ingredienteId.value
          : this.ingredienteId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecetaItem(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('platoId: $platoId, ')
          ..write('ingredienteId: $ingredienteId, ')
          ..write('cantidad: $cantidad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, localId, platoId, ingredienteId, cantidad);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecetaItem &&
          other.id == this.id &&
          other.localId == this.localId &&
          other.platoId == this.platoId &&
          other.ingredienteId == this.ingredienteId &&
          other.cantidad == this.cantidad);
}

class RecetaItemsCompanion extends UpdateCompanion<RecetaItem> {
  final Value<String> id;
  final Value<String> localId;
  final Value<String> platoId;
  final Value<String> ingredienteId;
  final Value<double> cantidad;
  final Value<int> rowid;
  const RecetaItemsCompanion({
    this.id = const Value.absent(),
    this.localId = const Value.absent(),
    this.platoId = const Value.absent(),
    this.ingredienteId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecetaItemsCompanion.insert({
    this.id = const Value.absent(),
    required String localId,
    required String platoId,
    required String ingredienteId,
    required double cantidad,
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       platoId = Value(platoId),
       ingredienteId = Value(ingredienteId),
       cantidad = Value(cantidad);
  static Insertable<RecetaItem> custom({
    Expression<String>? id,
    Expression<String>? localId,
    Expression<String>? platoId,
    Expression<String>? ingredienteId,
    Expression<double>? cantidad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localId != null) 'local_id': localId,
      if (platoId != null) 'plato_id': platoId,
      if (ingredienteId != null) 'ingrediente_id': ingredienteId,
      if (cantidad != null) 'cantidad': cantidad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecetaItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? localId,
    Value<String>? platoId,
    Value<String>? ingredienteId,
    Value<double>? cantidad,
    Value<int>? rowid,
  }) {
    return RecetaItemsCompanion(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      platoId: platoId ?? this.platoId,
      ingredienteId: ingredienteId ?? this.ingredienteId,
      cantidad: cantidad ?? this.cantidad,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (platoId.present) {
      map['plato_id'] = Variable<String>(platoId.value);
    }
    if (ingredienteId.present) {
      map['ingrediente_id'] = Variable<String>(ingredienteId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecetaItemsCompanion(')
          ..write('id: $id, ')
          ..write('localId: $localId, ')
          ..write('platoId: $platoId, ')
          ..write('ingredienteId: $ingredienteId, ')
          ..write('cantidad: $cantidad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDeDatos extends GeneratedDatabase {
  _$BaseDeDatos(QueryExecutor e) : super(e);
  $BaseDeDatosManager get managers => $BaseDeDatosManager(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $IngredientesTable ingredientes = $IngredientesTable(this);
  late final $MovimientosTable movimientos = $MovimientosTable(this);
  late final $PlatosTable platos = $PlatosTable(this);
  late final $RecetaItemsTable recetaItems = $RecetaItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categorias,
    ingredientes,
    movimientos,
    platos,
    recetaItems,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CategoriasTableCreateCompanionBuilder = CategoriasCompanion Function({
  Value<String> id,
  required String localId,
  required String nombre,
  Value<int> orden,
  Value<DateTime> creadoEn,
  Value<DateTime> actualizadoEn,
  Value<int> rowid,
});
typedef $$CategoriasTableUpdateCompanionBuilder = CategoriasCompanion Function({
  Value<String> id,
  Value<String> localId,
  Value<String> nombre,
  Value<int> orden,
  Value<DateTime> creadoEn,
  Value<DateTime> actualizadoEn,
  Value<int> rowid,
});

class $$CategoriasTableFilterComposer
    extends Composer<_$BaseDeDatos, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$BaseDeDatos, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (
            Categoria,
            BaseReferences<_$BaseDeDatos, $CategoriasTable, Categoria>,
          ),
          Categoria,
          PrefetchHooks Function()
        > {
  $$CategoriasTableTableManager(_$BaseDeDatos db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                localId: localId,
                nombre: nombre,
                orden: orden,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String localId,
                required String nombre,
                Value<int> orden = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                localId: localId,
                nombre: nombre,
                orden: orden,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriasTable, Categoria>(table),
                  BaseReferences<_$BaseDeDatos, $CategoriasTable, Categoria>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, BaseReferences<_$BaseDeDatos, $CategoriasTable, Categoria>),
      Categoria,
      PrefetchHooks Function()
    >;
typedef $$IngredientesTableCreateCompanionBuilder =
    IngredientesCompanion Function({
      Value<String> id,
      required String localId,
      required String nombre,
      Value<String?> categoriaId,
      required Unidad unidad,
      Value<double> costoUnitario,
      Value<double> stock,
      Value<double> stockMinimo,
      Value<bool> archivado,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<int> rowid,
    });
typedef $$IngredientesTableUpdateCompanionBuilder =
    IngredientesCompanion Function({
      Value<String> id,
      Value<String> localId,
      Value<String> nombre,
      Value<String?> categoriaId,
      Value<Unidad> unidad,
      Value<double> costoUnitario,
      Value<double> stock,
      Value<double> stockMinimo,
      Value<bool> archivado,
      Value<DateTime> creadoEn,
      Value<DateTime> actualizadoEn,
      Value<int> rowid,
    });

class $$IngredientesTableFilterComposer
    extends Composer<_$BaseDeDatos, $IngredientesTable> {
  $$IngredientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Unidad, Unidad, String> get unidad =>
      $composableBuilder(
        column: $table.unidad,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<double, double, double> get costoUnitario =>
      $composableBuilder(
        column: $table.costoUnitario,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<double, double, double> get stock =>
      $composableBuilder(
        column: $table.stock,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archivado => $composableBuilder(
    column: $table.archivado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IngredientesTableOrderingComposer
    extends Composer<_$BaseDeDatos, $IngredientesTable> {
  $$IngredientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archivado => $composableBuilder(
    column: $table.archivado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientesTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $IngredientesTable> {
  $$IngredientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Unidad, String> get unidad =>
      $composableBuilder(column: $table.unidad, builder: (column) => column);

  GeneratedColumnWithTypeConverter<double, double> get costoUnitario =>
      $composableBuilder(
        column: $table.costoUnitario,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<double, double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archivado =>
      $composableBuilder(column: $table.archivado, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$IngredientesTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $IngredientesTable,
          Ingrediente,
          $$IngredientesTableFilterComposer,
          $$IngredientesTableOrderingComposer,
          $$IngredientesTableAnnotationComposer,
          $$IngredientesTableCreateCompanionBuilder,
          $$IngredientesTableUpdateCompanionBuilder,
          (
            Ingrediente,
            BaseReferences<_$BaseDeDatos, $IngredientesTable, Ingrediente>,
          ),
          Ingrediente,
          PrefetchHooks Function()
        > {
  $$IngredientesTableTableManager(_$BaseDeDatos db, $IngredientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> categoriaId = const Value.absent(),
                Value<Unidad> unidad = const Value.absent(),
                Value<double> costoUnitario = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<bool> archivado = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientesCompanion(
                id: id,
                localId: localId,
                nombre: nombre,
                categoriaId: categoriaId,
                unidad: unidad,
                costoUnitario: costoUnitario,
                stock: stock,
                stockMinimo: stockMinimo,
                archivado: archivado,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String localId,
                required String nombre,
                Value<String?> categoriaId = const Value.absent(),
                required Unidad unidad,
                Value<double> costoUnitario = const Value.absent(),
                Value<double> stock = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<bool> archivado = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IngredientesCompanion.insert(
                id: id,
                localId: localId,
                nombre: nombre,
                categoriaId: categoriaId,
                unidad: unidad,
                costoUnitario: costoUnitario,
                stock: stock,
                stockMinimo: stockMinimo,
                archivado: archivado,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IngredientesTable, Ingrediente>(table),
                  BaseReferences<
                    _$BaseDeDatos,
                    $IngredientesTable,
                    Ingrediente
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IngredientesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $IngredientesTable,
      Ingrediente,
      $$IngredientesTableFilterComposer,
      $$IngredientesTableOrderingComposer,
      $$IngredientesTableAnnotationComposer,
      $$IngredientesTableCreateCompanionBuilder,
      $$IngredientesTableUpdateCompanionBuilder,
      (
        Ingrediente,
        BaseReferences<_$BaseDeDatos, $IngredientesTable, Ingrediente>,
      ),
      Ingrediente,
      PrefetchHooks Function()
    >;
typedef $$MovimientosTableCreateCompanionBuilder =
    MovimientosCompanion Function({
      Value<String> id,
      required String localId,
      required String ingredienteId,
      required TipoMovimiento tipo,
      required double cantidad,
      Value<double?> costoUnitario,
      Value<String?> motivo,
      Value<DateTime> fecha,
      Value<int> rowid,
    });
typedef $$MovimientosTableUpdateCompanionBuilder =
    MovimientosCompanion Function({
      Value<String> id,
      Value<String> localId,
      Value<String> ingredienteId,
      Value<TipoMovimiento> tipo,
      Value<double> cantidad,
      Value<double?> costoUnitario,
      Value<String?> motivo,
      Value<DateTime> fecha,
      Value<int> rowid,
    });

class $$MovimientosTableFilterComposer
    extends Composer<_$BaseDeDatos, $MovimientosTable> {
  $$MovimientosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredienteId => $composableBuilder(
    column: $table.ingredienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoMovimiento, TipoMovimiento, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MovimientosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $MovimientosTable> {
  $$MovimientosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredienteId => $composableBuilder(
    column: $table.ingredienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MovimientosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $MovimientosTable> {
  $$MovimientosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get ingredienteId => $composableBuilder(
    column: $table.ingredienteId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoMovimiento, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);
}

class $$MovimientosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $MovimientosTable,
          Movimiento,
          $$MovimientosTableFilterComposer,
          $$MovimientosTableOrderingComposer,
          $$MovimientosTableAnnotationComposer,
          $$MovimientosTableCreateCompanionBuilder,
          $$MovimientosTableUpdateCompanionBuilder,
          (
            Movimiento,
            BaseReferences<_$BaseDeDatos, $MovimientosTable, Movimiento>,
          ),
          Movimiento,
          PrefetchHooks Function()
        > {
  $$MovimientosTableTableManager(_$BaseDeDatos db, $MovimientosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> ingredienteId = const Value.absent(),
                Value<TipoMovimiento> tipo = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<double?> costoUnitario = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosCompanion(
                id: id,
                localId: localId,
                ingredienteId: ingredienteId,
                tipo: tipo,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                motivo: motivo,
                fecha: fecha,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String localId,
                required String ingredienteId,
                required TipoMovimiento tipo,
                required double cantidad,
                Value<double?> costoUnitario = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosCompanion.insert(
                id: id,
                localId: localId,
                ingredienteId: ingredienteId,
                tipo: tipo,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                motivo: motivo,
                fecha: fecha,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovimientosTable, Movimiento>(table),
                  BaseReferences<_$BaseDeDatos, $MovimientosTable, Movimiento>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MovimientosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $MovimientosTable,
      Movimiento,
      $$MovimientosTableFilterComposer,
      $$MovimientosTableOrderingComposer,
      $$MovimientosTableAnnotationComposer,
      $$MovimientosTableCreateCompanionBuilder,
      $$MovimientosTableUpdateCompanionBuilder,
      (
        Movimiento,
        BaseReferences<_$BaseDeDatos, $MovimientosTable, Movimiento>,
      ),
      Movimiento,
      PrefetchHooks Function()
    >;
typedef $$PlatosTableCreateCompanionBuilder = PlatosCompanion Function({
  Value<String> id,
  required String localId,
  required String nombre,
  required double precioVenta,
  Value<double> costoManual,
  Value<String?> foto,
  Value<String?> codigoExterno,
  Value<bool> archivado,
  Value<DateTime> creadoEn,
  Value<DateTime> actualizadoEn,
  Value<int> rowid,
});
typedef $$PlatosTableUpdateCompanionBuilder = PlatosCompanion Function({
  Value<String> id,
  Value<String> localId,
  Value<String> nombre,
  Value<double> precioVenta,
  Value<double> costoManual,
  Value<String?> foto,
  Value<String?> codigoExterno,
  Value<bool> archivado,
  Value<DateTime> creadoEn,
  Value<DateTime> actualizadoEn,
  Value<int> rowid,
});

class $$PlatosTableFilterComposer
    extends Composer<_$BaseDeDatos, $PlatosTable> {
  $$PlatosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoManual => $composableBuilder(
    column: $table.costoManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foto => $composableBuilder(
    column: $table.foto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoExterno => $composableBuilder(
    column: $table.codigoExterno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archivado => $composableBuilder(
    column: $table.archivado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlatosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $PlatosTable> {
  $$PlatosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoManual => $composableBuilder(
    column: $table.costoManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foto => $composableBuilder(
    column: $table.foto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoExterno => $composableBuilder(
    column: $table.codigoExterno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archivado => $composableBuilder(
    column: $table.archivado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlatosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $PlatosTable> {
  $$PlatosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costoManual => $composableBuilder(
    column: $table.costoManual,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foto =>
      $composableBuilder(column: $table.foto, builder: (column) => column);

  GeneratedColumn<String> get codigoExterno => $composableBuilder(
    column: $table.codigoExterno,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archivado =>
      $composableBuilder(column: $table.archivado, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$PlatosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $PlatosTable,
          Plato,
          $$PlatosTableFilterComposer,
          $$PlatosTableOrderingComposer,
          $$PlatosTableAnnotationComposer,
          $$PlatosTableCreateCompanionBuilder,
          $$PlatosTableUpdateCompanionBuilder,
          (Plato, BaseReferences<_$BaseDeDatos, $PlatosTable, Plato>),
          Plato,
          PrefetchHooks Function()
        > {
  $$PlatosTableTableManager(_$BaseDeDatos db, $PlatosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlatosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlatosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlatosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<double> precioVenta = const Value.absent(),
                Value<double> costoManual = const Value.absent(),
                Value<String?> foto = const Value.absent(),
                Value<String?> codigoExterno = const Value.absent(),
                Value<bool> archivado = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlatosCompanion(
                id: id,
                localId: localId,
                nombre: nombre,
                precioVenta: precioVenta,
                costoManual: costoManual,
                foto: foto,
                codigoExterno: codigoExterno,
                archivado: archivado,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String localId,
                required String nombre,
                required double precioVenta,
                Value<double> costoManual = const Value.absent(),
                Value<String?> foto = const Value.absent(),
                Value<String?> codigoExterno = const Value.absent(),
                Value<bool> archivado = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlatosCompanion.insert(
                id: id,
                localId: localId,
                nombre: nombre,
                precioVenta: precioVenta,
                costoManual: costoManual,
                foto: foto,
                codigoExterno: codigoExterno,
                archivado: archivado,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlatosTable, Plato>(table),
                  BaseReferences<_$BaseDeDatos, $PlatosTable, Plato>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlatosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $PlatosTable,
      Plato,
      $$PlatosTableFilterComposer,
      $$PlatosTableOrderingComposer,
      $$PlatosTableAnnotationComposer,
      $$PlatosTableCreateCompanionBuilder,
      $$PlatosTableUpdateCompanionBuilder,
      (Plato, BaseReferences<_$BaseDeDatos, $PlatosTable, Plato>),
      Plato,
      PrefetchHooks Function()
    >;
typedef $$RecetaItemsTableCreateCompanionBuilder =
    RecetaItemsCompanion Function({
      Value<String> id,
      required String localId,
      required String platoId,
      required String ingredienteId,
      required double cantidad,
      Value<int> rowid,
    });
typedef $$RecetaItemsTableUpdateCompanionBuilder =
    RecetaItemsCompanion Function({
      Value<String> id,
      Value<String> localId,
      Value<String> platoId,
      Value<String> ingredienteId,
      Value<double> cantidad,
      Value<int> rowid,
    });

class $$RecetaItemsTableFilterComposer
    extends Composer<_$BaseDeDatos, $RecetaItemsTable> {
  $$RecetaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platoId => $composableBuilder(
    column: $table.platoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredienteId => $composableBuilder(
    column: $table.ingredienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecetaItemsTableOrderingComposer
    extends Composer<_$BaseDeDatos, $RecetaItemsTable> {
  $$RecetaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platoId => $composableBuilder(
    column: $table.platoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredienteId => $composableBuilder(
    column: $table.ingredienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecetaItemsTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $RecetaItemsTable> {
  $$RecetaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get platoId =>
      $composableBuilder(column: $table.platoId, builder: (column) => column);

  GeneratedColumn<String> get ingredienteId => $composableBuilder(
    column: $table.ingredienteId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);
}

class $$RecetaItemsTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $RecetaItemsTable,
          RecetaItem,
          $$RecetaItemsTableFilterComposer,
          $$RecetaItemsTableOrderingComposer,
          $$RecetaItemsTableAnnotationComposer,
          $$RecetaItemsTableCreateCompanionBuilder,
          $$RecetaItemsTableUpdateCompanionBuilder,
          (
            RecetaItem,
            BaseReferences<_$BaseDeDatos, $RecetaItemsTable, RecetaItem>,
          ),
          RecetaItem,
          PrefetchHooks Function()
        > {
  $$RecetaItemsTableTableManager(_$BaseDeDatos db, $RecetaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecetaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecetaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecetaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localId = const Value.absent(),
                Value<String> platoId = const Value.absent(),
                Value<String> ingredienteId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecetaItemsCompanion(
                id: id,
                localId: localId,
                platoId: platoId,
                ingredienteId: ingredienteId,
                cantidad: cantidad,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String localId,
                required String platoId,
                required String ingredienteId,
                required double cantidad,
                Value<int> rowid = const Value.absent(),
              }) => RecetaItemsCompanion.insert(
                id: id,
                localId: localId,
                platoId: platoId,
                ingredienteId: ingredienteId,
                cantidad: cantidad,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecetaItemsTable, RecetaItem>(table),
                  BaseReferences<_$BaseDeDatos, $RecetaItemsTable, RecetaItem>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecetaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $RecetaItemsTable,
      RecetaItem,
      $$RecetaItemsTableFilterComposer,
      $$RecetaItemsTableOrderingComposer,
      $$RecetaItemsTableAnnotationComposer,
      $$RecetaItemsTableCreateCompanionBuilder,
      $$RecetaItemsTableUpdateCompanionBuilder,
      (
        RecetaItem,
        BaseReferences<_$BaseDeDatos, $RecetaItemsTable, RecetaItem>,
      ),
      RecetaItem,
      PrefetchHooks Function()
    >;

class $BaseDeDatosManager {
  final _$BaseDeDatos _db;
  $BaseDeDatosManager(this._db);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$IngredientesTableTableManager get ingredientes =>
      $$IngredientesTableTableManager(_db, _db.ingredientes);
  $$MovimientosTableTableManager get movimientos =>
      $$MovimientosTableTableManager(_db, _db.movimientos);
  $$PlatosTableTableManager get platos =>
      $$PlatosTableTableManager(_db, _db.platos);
  $$RecetaItemsTableTableManager get recetaItems =>
      $$RecetaItemsTableTableManager(_db, _db.recetaItems);
}
