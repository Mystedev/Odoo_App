import 'package:flutter/material.dart';
import 'package:odooapp/routes/comandes.dart';
import 'package:odooapp/widgets/widgetsVentas/salesCardPendents.dart';
import 'package:odooapp/widgets/widgetsVentas/salesSectionPendents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyWaitingSales extends StatefulWidget {
  const MyWaitingSales({super.key});

  @override
  State<MyWaitingSales> createState() => _MyWaitingSalesState();
}

class _MyWaitingSalesState extends State<MyWaitingSales> {
  // Inicializamos los datos de ventas vacíos
  final Map<String, List<Map<String, dynamic>>> salesData = {
    'Borrador': [],
    'Pendientes de enviar': [],
    'Guardados': [], // Solo se irán guardando las nuevas ventas
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSales(); // Cargar ventas guardadas al iniciar la pantalla
  }

  // Método para cargar las ventas desde SharedPreferences
  Future<void> _loadSavedSales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedSales = prefs.getString('savedSales');

    if (savedSales != null) {
      // Convertir de JSON a lista de ventas
      List<dynamic> salesList = jsonDecode(savedSales);

      setState(() {
        salesData['Guardados'] = List<Map<String, dynamic>>.from(salesList);
      });
    }
  }

  // Método para agregar una nueva venta a "Guardados" y guardar en SharedPreferences
  Future<void> _addToSavedSales(Map<String, dynamic> newSale) async {
    setState(() {
      salesData['Guardados']?.add(newSale);
    });

    // Guardar la nueva lista de ventas en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedSales = jsonEncode(salesData['Guardados']);
    await prefs.setString('savedSales', savedSales);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Ventas'),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: salesData.entries.map((entry) {
          final sectionTitle = entry.key;
          final sectionSales = entry.value;

          return SalesSection(
            title: sectionTitle,
            sales: sectionSales,
            onSaleTap: (sale) {
              // Navegar a la pantalla de detalles cuando se pulsa una venta
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SaleDetailsPage(sale: sale),
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navegar a MySalesOdoo y esperar un resultado
          final newSale = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(builder: (context) => const MySalesOdoo()),
          );

          // Si se recibe una nueva venta, agregarla a "Guardados"
          if (newSale != null) {
            _addToSavedSales(newSale);
          }
        },
        label: const Row(
          children: [
            Text('Nueva venta'),
            SizedBox(width: 10),
            Icon(Icons.add),
          ],
        ),
      ),
    );
  }
}
