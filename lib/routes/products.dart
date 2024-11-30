// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  _MyProductsState createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts(); // Inicializa la lista de productos
  }

  Future<List<dynamic>> fetchProducts() async {
    await ApiFetch.authenticate(); // Autenticación
    return await ApiFetch.fetchProducts(); // Obtener productos
  }

  Future<void> fetchApi() async {
    await ApiFetch.authenticate(); // Autenticación
    setState(() {
      _productsFuture = fetchProducts(); // Recargar la lista de productos
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
                Navigator.pop(context); // Cerrar el cuadro de diálogo
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
                  Navigator.pop(context); // Cerrar el cuadro de diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  fetchApi(); // Recargar la lista después de agregar un nuevo producto
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
                      Navigator.pop(context); // Cerrar el diálogo
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
                        Navigator.pop(context); // Cerrar el diálogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Product "$selectedProductName" deleted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
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
                      Navigator.pop(context); // Cerrar el diálogo
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

  void _showEditProductDialog(BuildContext context, int productId, String initialName, double initialListPrice, double initialCost) {
  final nameController = TextEditingController(text: initialName);
  final listPriceController = TextEditingController(text: initialListPrice.toString());
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
              Navigator.pop(context); // Cerrar el cuadro de diálogo
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final listPrice = double.tryParse(listPriceController.text.trim());
              final cost = double.tryParse(costController.text.trim());

              if (name.isEmpty || listPrice == null || cost == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields are required and must be valid!'),
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
                Navigator.pop(context); // Cerrar el cuadro de diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                fetchApi(); // Recargar la lista de productos
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
            onPressed: () => fetchApi(), // Recargar la lista de productos
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture, // Utiliza el future actual
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Indicador de carga
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error 1: ${snapshot.error}'), // Mostrar errores
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No products found'), // Sin datos
            );
          }

          // Mostrar la lista de productos
          final products = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Mostrar el BottomSheet con los detalles del producto
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
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
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black, // Cambia según el tema
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Sales Price: \$${product['list_price'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Cost: \$${product['standard_price'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Category: ${product['categ_name'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: const ButtonStyle(
                                      foregroundColor:
                                          WidgetStatePropertyAll(Colors.white),
                                      backgroundColor:
                                          WidgetStatePropertyAll(Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Close'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: ListTile(
                      title: Text(product['name'] ?? 'No Name'),
                      subtitle: Text(
                        'Sales Price: \$${product['list_price'] ?? 'N/A'}',
                      ),
                      trailing: const Icon(Icons.shop),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz,
        activeIcon: Icons.close,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004C6E),
        buttonSize: const Size(20, 60),
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: const Icon(
              Icons.add_shopping_cart,
              color: Color(0xFF004C6E),
            ),
            backgroundColor: Colors.white,
            label: 'Add',
            onTap: () => _showAddProductDialog(context),
          ),
          SpeedDialChild(
              child: const Icon(
                Icons.remove_shopping_cart,
                color: Color(0xFF004C6E),
              ),
              backgroundColor: Colors.white,
              label: 'Delete',
              onTap: () => _showDeleteProductDialog(context)),
          SpeedDialChild(
            child: const Icon(
              Icons.manage_history,
              color: Color(0xFF004C6E),
            ),
            backgroundColor: Colors.white,
            label: 'Update product',
            onTap: () => _showUpdateProductDialog(context),
          ),
        ],
      ),
    );
  }
}
