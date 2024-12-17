import 'package:flutter/material.dart';
import 'package:odooapp/routes/comandesPendents.dart';
import 'package:odooapp/routes/contacts.dart';
import 'package:odooapp/routes/products.dart';
import 'package:odooapp/routes/rutes.dart';

class HomeScreen extends StatelessWidget {
  final void Function(bool) onThemeChanged;
  final Future<List<dynamic>> contactsFuture;
  final Future<List<dynamic>> productsFuture;
  final Future<List<dynamic>> routes;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.contactsFuture,
    required this.productsFuture,
    required this.routes
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                      .push(_createRoute(const MyWaitingSales(filterById: null,)));
                },
              ),
              ListTile(
                  leading: const Icon(Icons.route),
                  title: const Text('Rutas'),
                  onTap: () {
                    Navigator.of(context).push(_createRoute(MyRoutes(routesFuture:routes)));
                  })
            ],
          ),
        ),
        body: const Center(
          child: Text(
            'Odoo DB',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 23, 48, 95),
            ),
          ),
        ));
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
