import 'package:flutter/material.dart';

class MySalesOdoo extends StatefulWidget {
  const MySalesOdoo({super.key});

  @override
  State<MySalesOdoo> createState() => _MySalesOdooState();
}

class _MySalesOdooState extends State<MySalesOdoo> {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nrtController = TextEditingController();

  final List<Map<String, dynamic>> _products = [];
  double _totalAmount = 0.0;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Albarán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del Albarán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contacto',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nrtController,
                    decoration: const InputDecoration(
                      labelText: 'NRT',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Productos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildProductForm(),
                  const Divider(color: Colors.black),
                  if (_products.isNotEmpty)
                    _buildProductList()
                  else
                    const Text('No hay productos añadidos aún.'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 11, 61, 79),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$$_totalAmount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 42, 61),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: _submitAlbaran,
                  child: const Row(
                    children: [
                      Icon(Icons.send, size: 16),
                      SizedBox(width: 8),
                      Text('Enviar'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductForm() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _productNameController,
            decoration: const InputDecoration(
              labelText: 'Producto',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _unitPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Precio Unitario',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addProduct,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text(product['name']),
            subtitle: Text(
                'Cantidad: ${product['quantity']}, Precio: \$${product['unitPrice']}'),
            trailing: Text('Total: \$${product['total']}'),
            leading: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(product),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar el producto "${product['name']}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _removeProduct(product);
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addProduct() {
    final String name = _productNameController.text;
    final double? unitPrice = double.tryParse(_unitPriceController.text);
    final int? quantity = int.tryParse(_quantityController.text);

    if (name.isNotEmpty && unitPrice != null && quantity != null) {
      final double total = unitPrice * quantity;

      setState(() {
        _products.add({
          'name': name,
          'unitPrice': unitPrice,
          'quantity': quantity,
          'total': total,
        });
        _totalAmount += total;
      });

      _productNameController.clear();
      _unitPriceController.clear();
      _quantityController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena todos los campos del producto correctamente.'),
        ),
      );
    }
  }

  void _removeProduct(Map<String, dynamic> product) {
    setState(() {
      _products.remove(product);
      _totalAmount -= product['total'];
    });
  }

  void _submitAlbaran() {
    final String contact = _contactController.text;
    final String date = _dateController.text;
    final String nrt = _nrtController.text;

    if (contact.isEmpty || date.isEmpty || nrt.isEmpty || _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    final newAlbaran = {
      'contact': contact,
      'date': date,
      'nrt': nrt,
      'products': _products,
      'total': _totalAmount,
    };

    Navigator.pop(context, newAlbaran); // Devuelve el albarán a la pantalla principal

    setState(() {
      _contactController.clear();
      _dateController.clear();
      _nrtController.clear();
      _products.clear();
      _totalAmount = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Albarán enviado con éxito.')),snackBarAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      )
    );
  }
}
