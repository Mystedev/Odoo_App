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
          backgroundColor: isDarkMode? const Color.fromARGB(255, 24, 24, 24) : const Color.fromARGB(255, 242, 251, 252),
          shape: Border.all(
            color: Colors.transparent,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: isDarkMode? const Color(0xFF00838F) : const Color(0xFF00838F),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 50,top: 30),
                  child: Text(
                    'Odoo App',
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
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
            'Dashboard',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF006064),
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
