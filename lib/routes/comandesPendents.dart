import 'package:flutter/material.dart';
import 'package:odooapp/routes/borradorScreen.dart';
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
  // Inicializamos los datos de ventas vacíos
  final Map<String, List<Map<String, dynamic>>> salesData = {
    'Borrador': [], // Ventas en borrador
    'Pendientes de enviar': [], // Ventas pendientes
    'Guardados': [], // Ventas guardadas
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSales(); // Cargar ventas guardadas al iniciar la pantalla
  }

  // Método para cargar las ventas desde SharedPreferences
  Future<void> _loadSavedSales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cargar Borrador
    String? draftSales = prefs.getString('draftSales');
    List<Map<String, dynamic>> drafts = [];
    if (draftSales != null) {
      List<dynamic> draftList = jsonDecode(draftSales);
      drafts = List<Map<String, dynamic>>.from(draftList);
    }

    // Cargar Guardados
    String? savedSales = prefs.getString('savedSales');
    List<Map<String, dynamic>> saved = [];
    if (savedSales != null) {
      List<dynamic> savedList = jsonDecode(savedSales);
      saved = List<Map<String, dynamic>>.from(savedList);
    }

    // Actualizar estado
    setState(() {
      salesData['Borrador'] = drafts;
      salesData['Guardados'] = saved;
    });
  }

  // Método para guardar las ventas en SharedPreferences
  Future<void> _saveSalesData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Guardar Borrador
    String draftSales = jsonEncode(salesData['Borrador']);
    await prefs.setString('draftSales', draftSales);

    // Guardar Guardados
    String savedSales = jsonEncode(salesData['Guardados']);
    await prefs.setString('savedSales', savedSales);
  }

  // Método para mostrar el cuadro de confirmación para eliminar una venta
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final TextStyle draftTitleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.tealAccent : Colors.blueAccent,
    );

    final TextStyle pendingTitleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.orangeAccent : Colors.deepOrange,
    );

    final TextStyle savedTitleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? Colors.greenAccent : Colors.green,
    );

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

          // Selección del estilo de título basado en la sección
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
              // Editar venta al tocar
              if (sectionTitle == 'Borrador') {
                final updatedSale = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDraftSaleScreen(draftSale: sale), // Nueva pantalla para gestionar borradores
                  ),
                );

                if (updatedSale != null) {
                  setState(() {
                    // Si la venta está marcada como completa, muévela a Guardados
                    if (updatedSale['status'] == 'completed') {
                      salesData['Borrador']!.remove(sale);
                      salesData['Guardados']!.add(updatedSale);
                    } else {
                      // Actualiza la venta en Borrador
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
              // Eliminar venta al mantener presionado
              if (sectionTitle == 'Borrador' || sectionTitle == 'Guardados') {
                _showDeleteConfirmation(context, sectionTitle, sale);
              }
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navegar a MySalesOdoo y esperar un resultado
          final newSale = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
                builder: (context) => const MySalesOdoo(
                      initialSale: {},
                    )),
          );

          // Si se recibe una nueva venta, agregarla a "Borrador" o "Guardados"
          if (newSale != null) {
            setState(() {
              if (newSale['title']?.startsWith('Borrador') ?? false) {
                // Agregar a la sección "Borrador"
                salesData['Borrador']?.add(newSale);
              } else {
                // Agregar a la sección "Guardados"
                salesData['Guardados']?.add(newSale);
              }
            });

            // Guardar los datos persistentes según la sección
            await _saveSalesData();
          }
        },
        label: const Row(
          children: [
            Text('Nueva venta'),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
