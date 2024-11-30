// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:odooapp/routes/employees.dart';
import 'package:odooapp/routes/products.dart';
import 'package:odooapp/themes/theme.dart';
import 'package:odooapp/routes/comandes.dart';
import 'package:odooapp/widgets/albaranesScreen.dart';

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
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                    ),
                    Icon(Icons.dashboard,size: 50,color: Colors.white,)
                  ],
                )),
            ListTile(
              leading: const Icon(Icons.shop),
              title: const Text('Products'),
              onTap: () {
                Navigator.of(context).push(_createRoute(const MyProducts()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Employees'),
              onTap: () {
                Navigator.of(context).push(_createRoute(const MyEmployees()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Comandes'),
              onTap: () {
                Navigator.of(context).push(_createRoute(const AlbaranesScreen()));
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
          const SizedBox(height: 200,),
          Container(
            child: Text('Dashboard',style: TextStyle(
              color: isDarkMode ? Colors.white : const Color.fromARGB(255, 0, 34, 58), 
              fontSize: 30,
              fontWeight: FontWeight.bold
            ),),
          )
        ],
      ),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
