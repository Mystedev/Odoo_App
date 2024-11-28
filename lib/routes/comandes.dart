import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';

class MySalesOdoo extends StatefulWidget {
  const MySalesOdoo({super.key});

  @override
  State<MySalesOdoo> createState() => _MySalesOdooState();
}

class _MySalesOdooState extends State<MySalesOdoo> {
  List<dynamic> sales = [];
  List<dynamic> salesTest = []; // Lista de ventas de prueba

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      await ApiFetch.authenticate(); // Intentar autenticarse con Odoo
      final fetchedSales = await ApiFetch.fetchSales(); // Intentar obtener datos reales
      setState(() {
        sales = fetchedSales;
      });
    } catch (e) {
      print('No se pudo acceder a Odoo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ventas'),
      ),
      body: sales.isNotEmpty // Si hay ventas desde Odoo
          ? ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return ListTile(
                  title: Text(sale['name']),
                  subtitle: Text(
                      'Fecha: ${sale['date_order']}, Total: ${sale['amount_total']} €'),
                  leading: const Icon(Icons.shopping_cart),
                );
              },
            )
          : salesTest.isNotEmpty // Si no hay ventas de Odoo pero sí hay ventas de prueba
              ? ListView.builder(
                  itemCount: salesTest.length,
                  itemBuilder: (context, index) {
                    final sale = salesTest[index];
                    return ListTile(
                      title: Text(sale['name']),
                      subtitle: Text('Fecha: ${sale['date_order']}, Total: ${sale['amount_total']} €'),
                      leading: const Icon(Icons.sell),
                    );
                  },
                )
              : const Center(child: Text('No hay ventas aún.')), // Si no hay ventas de ningún tipo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTestSale, // Llamar a la función para agregar venta de prueba
        label: const Text('Añadir Venta'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Función para añadir una nueva venta de prueba a la lista salesTest
  void _addTestSale() {
    setState(() {
      salesTest.add({
        'name': 'Venta de Prueba ${salesTest.length + 1}',
        'date_order': DateTime.now().toString().split(' ')[0],
        'amount_total': (100 + salesTest.length * 50).toString(),
      });
    });
  }
}
