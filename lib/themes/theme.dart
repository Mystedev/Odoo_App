import 'package:flutter/material.dart';

// Tema claro
final ThemeData lightTheme = ThemeData(
  primarySwatch: const MaterialColor(0xFF004C6E, {
    50: Color(0xFFE1F1F6),
    100: Color(0xFFB3D7E0),
    200: Color(0xFF80BDD0),
    300: Color(0xFF4DB3C0),
    400: Color(0xFF26A8B0),
    500: Color(0xFF004C6E), 
    600: Color(0xFF004A65),
    700: Color(0xFF003E57),
    800: Color(0xFF00334A),
    900: Color(0xFF00233A),
  }),
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF004C6E), // Azul oscuro
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  primaryColor: const Color.fromARGB(255, 26, 71, 92),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, // Color del texto del botón
      backgroundColor: const Color(0xFF00344D), // Azul más oscuro para el fondo del botón
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
      backgroundColor: const Color(0xFF00344D), // Azul más oscuro para el fondo de los botones
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF00344D), // Azul oscuro para el botón flotante
    foregroundColor: Colors.white,
  ),
);

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
  scaffoldBackgroundColor: const Color.fromARGB(255, 35, 35, 35), // Fondo oscuro
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF00344D), // Azul oscuro del tema claro adaptado
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
