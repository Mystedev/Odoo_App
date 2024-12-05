// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:odooapp/routes/comandes.dart';
import 'package:odooapp/routes/comandesPendents.dart';
import 'package:odooapp/routes/contacts.dart';
import 'package:odooapp/routes/products.dart';
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
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tema de la pantalla
    return MaterialApp(
      title: 'Main App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: AnimatedTheme(
        data: _themeMode == ThemeMode.dark ? darkTheme : lightTheme,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AuthenticatedHomeScreen(onThemeChanged: _toggleTheme),
      ),
    );
  }
}

class AuthenticatedHomeScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;

  const AuthenticatedHomeScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: ApiFetch.authenticate(), // Autenticación inicial
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // En lugar de bloquear, permitir acceso mostrando un mensaje
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Autenticación correcta...'),
                backgroundColor: Color.fromARGB(255, 70, 206, 92),
              ),
            );
          });
        }
        // Autenticación exitosa o con error, se sigue mostrando el HomeScreen
        return HomeScreen(onThemeChanged: onThemeChanged);
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF004C6E);

    return Scaffold(
      appBar: AppBar(
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
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                  Icon(Icons.dashboard, size: 50, color: Colors.white),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shop),
              title: const Text('Products'),
              onTap: () {
                Navigator.of(context).push(_createRoute(const MyProducts()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Contacts'),
              onTap: () {
                Navigator.of(context).push(_createRoute(const MyEmployees()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Comandes'),
              onTap: () {
                Navigator.of(context)
                    .push(_createRoute(const MyWaitingSales()));
              },
            ),
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
      const begin =
          Offset(1.0, 0.0); // Comienza fuera de la pantalla a la derecha
      const end = Offset.zero; // Termina en la posición original (pantalla)
      const curve = Curves.easeInOut; // Transición suave

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
