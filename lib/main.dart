// ignore_for_file: library_private_types_in_public_api, unused_field, prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:odooapp/routes/comandesPendents.dart';
import 'package:odooapp/routes/contacts.dart';
import 'package:odooapp/routes/products.dart';
import 'package:odooapp/routes/rutes.dart';
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
                    content: Text('Autenticación correcta...'),
                    backgroundColor: Color.fromARGB(255, 70, 206, 190),
                  ),
                );
              });
              return AuthenticatedHomeScreen(
                  onThemeChanged: _toggleTheme,
                  contactsFuture: _contactsFuture,
                  productsFuture: _productsFuture);
            } else {
              return AuthenticatedHomeScreen(
                onThemeChanged: _toggleTheme,
                contactsFuture: _contactsFuture,
                productsFuture: _productsFuture,
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

  AuthenticatedHomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.contactsFuture,
    required this.productsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onThemeChanged: onThemeChanged,
      contactsFuture: contactsFuture,
      productsFuture: productsFuture,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;
  final Future<List<dynamic>> contactsFuture;
  final Future<List<dynamic>> productsFuture;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.contactsFuture,
    required this.productsFuture,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF004C6E);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              onThemeChanged(!isDarkMode);
            },
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDarkMode ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: 230,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF00344D)
                    : const Color(0xFF004C6E),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Odoo DB',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  Icon(Icons.dashboard, size: 50, color: Colors.white),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shop),
              title: const Text('Productos'),
              onTap: () {
                Navigator.of(context).push(
                    _createRoute(MyProducts(productsFuture: productsFuture)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Contactos'),
              onTap: () {
                Navigator.of(context).push(
                  _createRoute(
                    MyEmployees(contactsFuture: contactsFuture),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Ventas'),
              onTap: () {
                Navigator.of(context)
                    .push(_createRoute(const MyWaitingSales()));
              },
            ),
            ListTile(
                leading: const Icon(Icons.route),
                title: const Text('Rutas'),
                onTap: () {
                  Navigator.of(context).push(_createRoute(const MyRoutes()));
                })
          ],
        ),
      ),
      body: Column(
        children: [
          Image.asset("lib/assets/rb_2149227348.png"),
          Center(
            child: Text(
              'Odoo DB',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
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
