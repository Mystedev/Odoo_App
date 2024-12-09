import 'package:flutter/material.dart';

class EditDraftSaleScreen extends StatefulWidget {
  final Map<String, dynamic> draftSale;

  const EditDraftSaleScreen({super.key, required this.draftSale});

  @override
  State<EditDraftSaleScreen> createState() => _EditDraftSaleScreenState();
}

class _EditDraftSaleScreenState extends State<EditDraftSaleScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadDraftData();
  }

  void _loadDraftData() {
    // Cargar los datos de la venta en borrador
    _dateController.text = widget.draftSale['date'] ?? '';
    _customerController.text = widget.draftSale['customerName'] ?? '';
    _products =
        List<Map<String, dynamic>>.from(widget.draftSale['products'] ?? []);
  }

  // Método para agregar un producto vacío
  void _addProduct() {
    setState(() {
      _products.add({'name': '', 'quantity': 1, 'price': 0.0});
    });
  }

  // Método para eliminar un producto
  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Borrador'),
        backgroundColor: Colors.red.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Fecha'),
            ),
            TextField(
              controller: _customerController,
              decoration: const InputDecoration(labelText: 'Cliente'),
            ),
            const SizedBox(height: 20),
            const Text('Productos'),
            // Lista de productos con sus campos
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller:
                                TextEditingController(text: product['name']),
                            decoration: const InputDecoration(
                                labelText: 'Nombre del Producto'),
                            onChanged: (value) {
                              setState(() {
                                product['name'] = value;
                              });
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: product['quantity'].toString()),
                            decoration:
                                const InputDecoration(labelText: 'Cantidad'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                product['quantity'] = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                                text: product['price'].toString()),
                            decoration:
                                const InputDecoration(labelText: 'Precio'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                product['price'] =
                                    double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeProduct(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Guardar los cambios en la venta borrador
            final updatedSale = {
              'date': _dateController.text,
              'customerName': _customerController.text,
              'products': _products,
            };
            Navigator.pop(
                context, updatedSale); // Volver con la venta actualizada
          },
          label: const Text('Guardar cambios')),
    );
  }
}
