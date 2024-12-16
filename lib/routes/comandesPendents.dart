import 'package:flutter/material.dart';
import 'package:odooapp/routes/comandes.dart';
import 'package:odooapp/widgets/widgetsVentas/salesSectionPendents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyWaitingSales extends StatefulWidget {
  const MyWaitingSales({super.key});

  @override
  State<MyWaitingSales> createState() => _MyWaitingSalesState();
}

class _MyWaitingSalesState extends State<MyWaitingSales> {
  final Map<String, List<Map<String, dynamic>>> salesData = {
    'Borrador': [],
    'Pendientes de enviar': [],
    'Guardados': [],
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSales();
  }

  Future<void> _loadSavedSales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? draftSales = prefs.getString('draftSales');
    List<Map<String, dynamic>> drafts = [];
    if (draftSales != null) {
      List<dynamic> draftList = jsonDecode(draftSales);
      drafts = List<Map<String, dynamic>>.from(draftList);
    }

    String? savedSales = prefs.getString('savedSales');
    List<Map<String, dynamic>> saved = [];
    if (savedSales != null) {
      List<dynamic> savedList = jsonDecode(savedSales);
      saved = List<Map<String, dynamic>>.from(savedList);
    }

    setState(() {
      salesData['Borrador'] = drafts;
      salesData['Guardados'] = saved;
    });
  }

  Future<void> _saveSalesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String draftSales = jsonEncode(salesData['Borrador']);
    await prefs.setString('draftSales', draftSales);

    String savedSales = jsonEncode(salesData['Guardados']);
    await prefs.setString('savedSales', savedSales);
  }

  void _showDeleteConfirmation(
      BuildContext context, String section, Map<String, dynamic> sale) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Deseas eliminar esta venta de $section?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  salesData[section]!.remove(sale);
                });
                _saveSalesData();
                Navigator.pop(context);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle draftTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 255, 68, 68), // Color para 'Borrador'
    );

    const TextStyle pendingTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 130, 199, 120), // Color para 'Pendientes de enviar'
    );

    const TextStyle savedTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 105, 204, 240), // Color para 'Guardados'
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Ventas'),
        centerTitle: true, // Centrar el título
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        children: salesData.entries.map((entry) {
          final sectionTitle = entry.key;
          final sectionSales = entry.value;

          TextStyle sectionTitleStyle;
          if (sectionTitle == 'Borrador') {
            sectionTitleStyle = draftTitleStyle;
          } else if (sectionTitle == 'Pendientes de enviar') {
            sectionTitleStyle = pendingTitleStyle;
          } else {
            sectionTitleStyle = savedTitleStyle;
          }

          return SalesSection(
            title: sectionTitle,
            titleStyle: sectionTitleStyle,
            sales: sectionSales,
            onSaleTap: (sale) async {
              if (sectionTitle == 'Borrador') {
                final updatedSale = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MySalesOdoo(initialSale: sale),
                  ),
                );

                if (updatedSale != null) {
                  setState(() {
                    if (updatedSale['status'] == 'completed') {
                      salesData['Borrador']!.remove(sale);
                      salesData['Guardados']!.add(updatedSale);
                    } else {
                      int index = salesData['Borrador']!.indexOf(sale);
                      if (index != -1) {
                        salesData['Borrador']![index] = updatedSale;
                      }
                    }
                  });
                  await _saveSalesData();
                }
              }
            },
            onSaleLongPress: (sale) {
              if (sectionTitle == 'Borrador' || sectionTitle == 'Guardados') {
                _showDeleteConfirmation(context, sectionTitle, sale);
              }
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newSale = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
                builder: (context) => const MySalesOdoo(
                      initialSale: {},
                    )),
          );

          if (newSale != null) {
            setState(() {
              if (newSale['title']?.startsWith('Borrador') ?? false) {
                salesData['Borrador']?.add(newSale);
              } else {
                salesData['Guardados']?.add(newSale);
              }
            });

            await _saveSalesData();
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

