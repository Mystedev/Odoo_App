// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print, unused_element

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProducts extends StatefulWidget {
  final Future<List<dynamic>>productsFuture; 
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
    _loadProductsFromPreferences();
  }

  Future<void> _loadProductsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('products');

    if (jsonString != null) {
      final List<dynamic> products = jsonDecode(jsonString);
      setState(() {
        _productsFuture = Future.value(products); // Usar lista de products guardados en SharedPreferences
      });
    } else {
      // Si no hay productys guardados, utilizar la fuente proporcionada
      _productsFuture = widget.productsFuture;
    }
  }

  Future<void> fetchApi() async {
    setState(() {
      _productsFuture = ApiFetch.fetchProducts(); // Recargar productos
    });
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final listPriceController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: listPriceController,
                  decoration: const InputDecoration(labelText: 'Sales Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(labelText: 'Cost Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final listPrice =
                    double.tryParse(listPriceController.text.trim());
                final cost = double.tryParse(costController.text.trim());

                if (name.isEmpty || listPrice == null || cost == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields correctly!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await ApiFetch.addProduct(name, listPrice, cost);
                  Navigator.pop(context); // Cerrar diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  fetchApi(); // Recargar lista de productos
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteProductDialog(BuildContext context) async {
    try {
      final products = await ApiFetch.fetchProducts(); // Obtener productos

      if (products.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No products found to delete.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? selectedProductName;
      int? selectedProductId;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Product to Delete'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product['name'] ?? 'No Name'),
                        onTap: () {
                          setState(() {
                            selectedProductName = product['name'];
                            selectedProductId = product['id'];
                          });
                        },
                        selected: selectedProductId == product['id'],
                        selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedProductId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a product to delete.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        await ApiFetch.deleteProducts([selectedProductId!]);
                        Navigator.pop(context); // Cerrar diálogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Product "$selectedProductName" deleted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        fetchApi(); // Recargar lista de productos
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete product: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching products: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUpdateProductDialog(BuildContext context) async {
    try {
      final products = await ApiFetch.fetchProducts(); // Obtener productos

      if (products.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No products found to update.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? selectedProductName;
      int? selectedProductId;
      double? initialListPrice;
      double? initialCost;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Product to Update'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product['name'] ?? 'No Name'),
                        onTap: () {
                          setState(() {
                            selectedProductName = product['name'];
                            selectedProductId = product['id'];
                            initialListPrice = product['list_price'] ?? 0.0;
                            initialCost = product['standard_price'] ?? 0.0;
                          });
                        },
                        selected: selectedProductId == product['id'],
                        selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedProductId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a product to update.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context); // Cerrar selección
                      _showEditProductDialog(
                        context,
                        selectedProductId!,
                        selectedProductName!,
                        initialListPrice ?? 0.0,
                        initialCost ?? 0.0,
                      );
                    },
                    child: const Text('Next'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching products: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditProductDialog(BuildContext context, int productId,
      String initialName, double initialListPrice, double initialCost) {
    final nameController = TextEditingController(text: initialName);
    final listPriceController =
        TextEditingController(text: initialListPrice.toString());
    final costController = TextEditingController(text: initialCost.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Product Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: listPriceController,
                  decoration: const InputDecoration(labelText: 'Sales Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(labelText: 'Cost Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final listPrice =
                    double.tryParse(listPriceController.text.trim());
                final cost = double.tryParse(costController.text.trim());

                if (name.isEmpty || listPrice == null || cost == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('All fields are required and must be valid!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await ApiFetch.updateProduct(productId, {
                    "name": name,
                    "list_price": listPrice,
                    "standard_price": cost,
                  });
                  Navigator.pop(context); // Cerrar diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  fetchApi(); // Recargar lista de productos
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                title: Text(product['name'] ?? 'Unnamed'),
                subtitle:
                    Text('Sales Price: \$${product['list_price'] ?? 'N/A'}'),
                trailing: const Icon(Icons.shop),
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
            onTap: () => _showAddProductDialog(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.remove_shopping_cart),
            label: 'Delete',
            onTap: () => _showDeleteProductDialog(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.manage_history),
            label: 'Update',
            onTap: () => _showUpdateProductDialog(context),
          ),
        ],
      ),
    );
  }
}
