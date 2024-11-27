import 'package:flutter/material.dart';

// Tema claro
final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  brightness: Brightness.light,


  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.deepPurple, // Color del botón
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.deepPurple),
  ),
);

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
      foregroundColor: const Color.fromARGB(255, 95, 7, 171), // Color del texto del botón
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.orangeAccent),
  ),
);
