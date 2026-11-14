import 'package:rinde/comun/datos/base_de_datos.dart';

String unidadCorta(Unidad u) => switch (u) {
  Unidad.gramos => 'g',
  Unidad.mililitros => 'ml',
  Unidad.unidades => 'u',
};

String decimal(double n) =>
    n.toStringAsFixed(n % 1 == 0 ? 0 : 1).replaceAll('.', ',');

String miles(double n) => n
    .round()
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

String pesos(double n, [int dec = 0]) {
  final partes = n.toStringAsFixed(dec).split('.');
  final entero = partes[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '\$$entero${dec > 0 ? ',${partes[1]}' : ''}';
}

// 1500 g -> "1,5 kg"; 800 g -> "800 g"
String cantidadCorta(Ingrediente i) {
  if (i.unidad != Unidad.unidades && i.stock >= 1000) {
    final grande = i.unidad == Unidad.gramos ? 'kg' : 'L';
    return '${decimal(i.stock / 1000)} $grande';
  }
  return '${decimal(i.stock)} ${unidadCorta(i.unidad)}';
}

// 1500 g -> "1 kg 500 g"; 800 g -> "800 g"; 30 u -> "30 u"
String cantidadMixta(Ingrediente i) {
  final u = unidadCorta(i.unidad);
  if (i.unidad == Unidad.unidades || i.stock < 1000) {
    return '${decimal(i.stock)} $u';
  }
  final grande = i.unidad == Unidad.gramos ? 'kg' : 'L';
  final kilos = i.stock ~/ 1000;
  final resto = (i.stock % 1000).round();
  return resto == 0 ? '$kilos $grande' : '$kilos $grande $resto $u';
}

// 1500 -> "1.500 g"
String cantidadExacta(Ingrediente i) =>
    '${i.stock % 1 == 0 ? miles(i.stock) : decimal(i.stock)} ${unidadCorta(i.unidad)}';

// "$5.800 por kg", "$250 por unidad" o "Sin costo"
String costoTexto(Ingrediente i) {
  if (i.costoUnitario == 0) return 'Sin costo';
  if (i.unidad == Unidad.unidades) {
    return '${pesos(i.costoUnitario, i.costoUnitario < 10 ? 1 : 0)} por unidad';
  }
  final grande = i.unidad == Unidad.gramos ? 'kg' : 'L';
  return '${pesos(i.costoUnitario * 1000)} por $grande';
}

String nombreMovimiento(TipoMovimiento t) => switch (t) {
  TipoMovimiento.inicial => 'Stock inicial',
  TipoMovimiento.compra => 'Compra',
  TipoMovimiento.ajuste => 'Ajuste',
  TipoMovimiento.venta => 'Venta',
};

String fechaRelativa(DateTime f) {
  final hoy = DateTime.now();
  final dias = DateTime(hoy.year, hoy.month, hoy.day)
      .difference(DateTime(f.year, f.month, f.day))
      .inDays;
  final hora =
      '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
  if (dias == 0) return 'Hoy $hora';
  if (dias == 1) return 'Ayer $hora';
  return 'Hace $dias días';
}

String normalizar(String s) {
  const con = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sin = 'aaaaeeeeiiiioooouuuun';
  var r = s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  for (var i = 0; i < con.length; i++) {
    r = r.replaceAll(con[i], sin[i]);
  }
  return r;
}

// Costo por kg, L o unidad a partir de un costo por g, ml o u.
String costoPorUnidad(double costo, Unidad u) {
  if (costo == 0) return 'Sin costo';
  if (u == Unidad.unidades) {
    return '${pesos(costo, costo < 10 ? 1 : 0)} por unidad';
  }
  final grande = u == Unidad.gramos ? 'kg' : 'L';
  return '${pesos(costo * 1000)} por $grande';
}

// 1500 -> "1 kg 500 g"; -300 -> "−300 g"; 30 u -> "30 u"
String cantidadDe(double valor, Unidad u) {
  final signo = valor < 0 ? '−' : '';
  final v = valor.abs();
  final corta = unidadCorta(u);
  if (u == Unidad.unidades || v < 1000) {
    return '$signo${decimal(v)} $corta';
  }
  final grande = u == Unidad.gramos ? 'kg' : 'L';
  final kilos = v ~/ 1000;
  final resto = (v % 1000).round();
  return resto == 0
      ? '$signo$kilos $grande'
      : '$signo$kilos $grande $resto $corta';
}

// 0.625 -> "62,5 %"; null -> "—"
String porcentaje(double? m) {
  if (m == null) return '—';
  final v = (m * 1000).round() / 10;
  return '${v.toStringAsFixed(v % 1 == 0 ? 0 : 1).replaceAll('.', ',')} %';
}