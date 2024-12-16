// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:odooapp/utilities/dialogProducts.dart';

class MyProducts extends StatefulWidget {
  final Future<List<dynamic>> productsFuture;
  const MyProducts(
      {super.key, required this.productsFuture}); // Inicializar el future

  @override
  _MyProductsState createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  late Future<List<dynamic>> _productsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.productsFuture;
  }

  Future<void> fetchApi() async {
    setState(() {
      _productsFuture = ApiFetch.fetchProducts(); // Recargar productos
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_outlined,
                color: Colors.white, size: 30),
            onPressed: () => fetchApi(), // Recargar productos
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture, // Usa el future actual
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(
                  product['name'] ?? 'Unnamed',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                subtitle:
                    Text('Sales Price: \$${product['list_price'] ?? 'N/A'}'),
                trailing: const Icon(Icons.shop, color: Color(0xFF00344D)),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      final isDarkMode =
                          Theme.of(context).brightness == Brightness.dark;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                'Sales Price: \$${product['list_price'] ?? 'N/A'}'),
                            const SizedBox(height: 5),
                            Text(
                                'Cost: \$${product['standard_price'] ?? 'N/A'}'),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz,
        activeIcon: Icons.close,
        buttonSize: const Size(20, 60),
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.add_shopping_cart),
              label: 'Add',
              onTap: () => DialogHelpersProducts.showAddProductDialog(
                  context, fetchApi)),
          SpeedDialChild(
              child: const Icon(Icons.remove_shopping_cart),
              label: 'Delete',
              onTap: () => DialogHelpersProducts.showDeleteProductDialog(
                  context, _productsFuture, fetchApi)),
          SpeedDialChild(
              child: const Icon(Icons.manage_history),
              label: 'Update',
              onTap: () => DialogHelpersProducts.showUpdateProductDialog(
                  context, _productsFuture, fetchApi)),
        ],
      ),
    );
  }
}
