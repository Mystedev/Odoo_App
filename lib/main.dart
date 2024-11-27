// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:odooapp/routes/employees.dart';
import 'package:odooapp/routes/products.dart';
import 'package:odooapp/themes/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: AnimatedTheme(
        data: _themeMode == ThemeMode.dark ? darkTheme : lightTheme,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: HomeScreen(onThemeChanged: _toggleTheme),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        body: Center(
          child: SizedBox(
              width: 250,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Odoo DB',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode
                          ? Colors.white
                          : const Color.fromARGB(255, 80, 2, 133),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      width: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(10),
                          foregroundColor: WidgetStateProperty.all(
                              isDarkMode ? Colors.black : Colors.deepPurple),
                          backgroundColor: WidgetStateProperty.all(isDarkMode
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color.fromARGB(255, 255, 255, 255)),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .push(_createRoute(const MyProducts()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Products',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            Icon(Icons.shopping_cart),
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(10),
                        foregroundColor: WidgetStateProperty.all(
                            isDarkMode ? Colors.black : Colors.deepPurple),
                        backgroundColor: WidgetStateProperty.all(isDarkMode
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(255, 255, 255, 255)),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .push(_createRoute(const MyEmployees()));
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Employees',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          Icon(Icons.person),
                        ],
                      ),
                    ),
                  )
                ],
              )),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            onThemeChanged(!isDarkMode);
          },
          backgroundColor: isDarkMode ? Colors.white : Colors.deepPurpleAccent,
          foregroundColor: isDarkMode ? Colors.deepPurpleAccent : Colors.white,
          child: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        ));
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;

      var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeIn));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
