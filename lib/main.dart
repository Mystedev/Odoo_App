// ignore_for_file: library_private_types_in_public_api, unused_field, prefer_final_fields, unused_element, unnecessary_import
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:odooapp/HomeScreen.dart';
import 'package:odooapp/api/apiAccess.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:odooapp/themes/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<List<dynamic>> _productsFuture = Future.value([]);
  late Future<List<dynamic>> _contactsFuture = Future.value([]);
  late Future<List<dynamic>> _routesFuture = Future.value([]);
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    // Ejecuta la autenticación y luego recupera los datos al iniciar el estado del widget.
    _authenticateAndFetchData();
  }

  Future<void> _authenticateAndFetchData() async {
    // Asegúrate de que la autenticación sea exitosa antes de obtener los productos y contactos
    await ApiFetch.authenticate();
    setState(() {
      // Lista de productos obtenidos correctamente despues de la autenticación
      _productsFuture = ApiFetch.fetchProducts();
      // Lista de contactos obtenidos correctamente despues de la autenticación
      _contactsFuture = ApiFetch.fetchContacts();
      // Lista de rutas obtenidas correctamente despues de la autenticación
      _routesFuture = ApiFetch.fetchRoutes();
    });
  }

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
        child: FutureBuilder<void>(
          future: ApiFetch.authenticate(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // En lugar de bloquear, permitir acceso mostrando un mensaje
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Obteniendo datos...'),
                    backgroundColor: Color.fromARGB(255, 56, 129, 122),
                  ),
                );
              });
              return AuthenticatedHomeScreen(
                  onThemeChanged: _toggleTheme,
                  contactsFuture: _contactsFuture,
                  productsFuture: _productsFuture,
                  routesFuture: _routesFuture);
            } else {
              return AuthenticatedHomeScreen(
                onThemeChanged: _toggleTheme,
                contactsFuture: _contactsFuture,
                productsFuture: _productsFuture,
                routesFuture: _routesFuture,
              );
            }
          },
        ),
      ),
    );
  }
}

class AuthenticatedHomeScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;
  final Future<List<dynamic>> contactsFuture;
  final Future<List<dynamic>> productsFuture;
  final Future<List<dynamic>> routesFuture;

  const AuthenticatedHomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.contactsFuture,
    required this.productsFuture,
    required this.routesFuture,
  });

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onThemeChanged: onThemeChanged,
      contactsFuture: contactsFuture,
      productsFuture: productsFuture,
      routes: routesFuture,
    );
  }
}



Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
