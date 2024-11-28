import 'package:flutter/material.dart';

// Tema claro
final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 133, 63, 143),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor:
            const Color.fromARGB(255, 255, 255, 255), // Color del botón
        backgroundColor: const Color.fromARGB(255, 133, 63, 143),
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
      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      backgroundColor: const Color.fromARGB(255, 133, 63, 143),
    )),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 133, 63, 143),
        foregroundColor: Colors.white),);

// Tema oscuro
final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.lightGreen,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 28, 28, 28),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 67, 40, 142),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor:
          const Color.fromARGB(255, 95, 7, 171), // Color del texto del botón
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.orangeAccent),
  ),
);
