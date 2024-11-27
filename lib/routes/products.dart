import 'package:flutter/material.dart';
import 'package:odooapp/widgets/apiProducts.dart';

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
                final listPrice = double.tryParse(listPriceController.text.trim());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_outlined, color: Colors.white, size: 30),
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
              child: Text('Error: ${snapshot.error}'), // Mostrar errores
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No products found'), // Sin datos
            );
          }

          // Mostrar la lista de productos
          final products = snapshot.data!;
          return ListView.builder(
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
                                      foregroundColor: WidgetStatePropertyAll(
                                          Colors.white),
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.black),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        foregroundColor: Colors.white,
        onPressed: () => _showAddProductDialog(context), // Llama al diálogo
        child: const Icon(
          Icons.add,
          weight: 200,
          size: 30,
        ),
      ),
    );
  }
}
