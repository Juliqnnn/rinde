import 'package:flutter/material.dart';
import 'package:rinde/comun/tema/colores.dart';

ThemeData crearTema() {
  final esquema = ColorScheme.fromSeed(seedColor: Colores.aji).copyWith(
    primary: Colores.pizarra,
    onPrimary: Colors.white,
    secondary: Colores.aji,
    surface: Colores.crema,
    error: Colores.rojo,
  );
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    colorScheme: esquema,
    scaffoldBackgroundColor: Colores.crema,
  );
  return base.copyWith(
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Colores.beige,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colores.crema,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
              ? Colores.pizarra
              : Colors.white,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : Colores.pizarra,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}