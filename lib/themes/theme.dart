// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

// Tema claro
final ThemeData lightTheme = ThemeData(
  primarySwatch: const MaterialColor(0xFF006064, {
    50: Color(0xFFE0F7FA),
    100: Color(0xFFB2EBF2),
    200: Color(0xFF80DEEA),
    300: Color(0xFF4DD0E1),
    400: Color(0xFF26C6DA),
    500: Color(0xFF00BCD4),
    600: Color(0xFF00ACC1),
    700: Color(0xFF0097A7),
    800: Color(0xFF00838F),
    900: Color(0xFF006064),
  }),
  scaffoldBackgroundColor: Color.fromARGB(255, 242, 251, 252),
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF00838F), 
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  primaryColor: const Color(0xFF0097A7),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, 
      backgroundColor:
          const Color(0xFF0097A7), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF0097A7),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFE0F7FA),
    foregroundColor: Color.fromARGB(255, 0, 0, 0),
  ),
);
// ------------------------------------------------------------------
// Tema oscuro ajustado
final ThemeData darkTheme = ThemeData(
  primarySwatch: const MaterialColor(0xFF004C6E, {
    50: Color(0xFF1A2D37),
    100: Color(0xFF16272E),
    200: Color(0xFF112125),
    300: Color(0xFF0D1B1D),
    400: Color(0xFF091519),
    500: Color(0xFF061012),
    600: Color(0xFF050E0F),
    700: Color(0xFF040B0C),
    800: Color(0xFF03090A),
    900: Color(0xFF020607),
  }),
  brightness: Brightness.dark,
  scaffoldBackgroundColor:
      const Color.fromARGB(255, 24, 24, 24), // Fondo oscuro
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF006064), // Azul oscuro del tema claro adaptado
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF004C6E), // Azul oscuro del tema claro
      foregroundColor: Colors.white, // Color del texto del botón
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.white), // Texto en blanco
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF004C6E), // Azul oscuro para los botones
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF004C6E), // Azul oscuro adaptado del tema claro
    foregroundColor: Colors.white,
  ),
);
