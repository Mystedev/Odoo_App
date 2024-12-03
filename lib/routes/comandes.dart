// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_declarations, unused_element

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';

class MySalesOdoo extends StatefulWidget {
  const MySalesOdoo({super.key});

  @override
  State<MySalesOdoo> createState() => _MySalesOdooState();
}

class _MySalesOdooState extends State<MySalesOdoo> {
  final TextEditingController _dateController = TextEditingController();
  final List<Map<String, dynamic>> _products = [];
  int? _selectedCustomerId;
  int? _selectedProductId;

  String _selectedCustomerName = '';
  String _selectedCustomerVat = '';
  double _totalAmount = 0.0;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Venta')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerSelection(),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Productos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildProductForm(),
                  const Divider(),
                  _products.isNotEmpty
                      ? _buildProductList()
                      : const Text('No hay productos.'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return InkWell(
      onTap: _showCustomerSelectionDialog,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Cliente',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _selectedCustomerName.isEmpty
              ? 'Selecciona un cliente'
              : _selectedCustomerName,
        ),
      ),
    );
  }

  Widget _buildProductForm() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Indicador de carga
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Error al cargar productos');
        }

        final products = snapshot.data!;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Producto',
                      border: OutlineInputBorder(),
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem<int>(
                        value: product['id'],
                        child: Text(product['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
                        final selectedProduct = products
                            .firstWhere((product) => product['id'] == value);
                        _productNameController.text = selectedProduct['name'];
                        _unitPriceController.text =
                            selectedProduct['list_price'].toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _unitPriceController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
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
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addProduct,
                  color: Colors.green,
                  constraints: const BoxConstraints(
                    maxWidth: 40,
                    maxHeight: 40,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ListTile(
          title: Text(product['name']),
          subtitle: Text(
              'Cantidad: ${product['quantity']}, Precio: \$${product['unitPrice']}'),
          trailing: Text('Total: \$${product['total']}'),
          leading: IconButton(
            icon: const Icon(Icons.delete,
                color: Color.fromARGB(255, 166, 51, 43)),
            onPressed: () => _removeProduct(product),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 65,
      color: const Color.fromARGB(255, 38, 82, 104),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: \$$_totalAmount',
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
            onPressed: _submitOrder,
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showCustomerSelectionDialog() async {
    try {
      final customers = await ApiFetch.fetchContacts();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Busca un cliente'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return ListTile(
                    title: Text(customer['name']),
                    onTap: () {
                      setState(() {
                        _selectedCustomerId = customer['id'];
                        _selectedCustomerName = customer['name'];
                        _selectedCustomerVat = customer['vat'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      throw Exception('Formato de fecha inválido. Usa YYYY-MM-DD');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      final products =
          await ApiFetch.fetchProducts(); // Recuperar productos desde Odoo
      return List<Map<String, dynamic>>.from(products);
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  void _addProduct() {
    if (_selectedProductId == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos del producto')),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    final unitPrice = double.tryParse(_unitPriceController.text);

    if (quantity != null && unitPrice != null) {
      setState(() {
        _products.add({
          "productId": _selectedProductId,
          "name":
              _productNameController.text, // Nombre del producto seleccionado
          "quantity": quantity,
          "unitPrice": unitPrice,
          "total": unitPrice * quantity,
        });
        _totalAmount += unitPrice * quantity;
      });

      _quantityController.clear();
      _productNameController.clear();
      _unitPriceController.clear();
      _selectedProductId = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cantidad o precio inválido')),
      );
    }
  }

  // Eliminar un producto si no se quiere mantener en la orden
  void _removeProduct(Map<String, dynamic> product) {
    setState(() {
      _products.remove(product);
      _totalAmount -= product['total'];
    });
  }

  // Funcion para comprobar que los campos no esten vacios y enviar los datos
  void _submitOrder() async {
    if (_selectedCustomerId == null ||
        _dateController.text.isEmpty ||
        _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aviso: Completa todos los campos')),
      );
      return;
    }

    try {
      // Formatea la fecha correctamente
      final String formattedDate = _formatDate(_dateController.text);

      // Genera las líneas de pedido
      final List<List<dynamic>> orderLines =
          ApiFetch.createOrderLines(_products);
      print('Order Lines: $orderLines');

      // Crea la orden de venta
      final orderId = await ApiFetch.addSaleOrder(
        customerId: _selectedCustomerId!,
        orderDate: formattedDate, // Usa la fecha formateada
        orderLines: orderLines, //
      );
      // Mensaje de orden creada exitosamente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Orden creada con éxito. ID: $orderId',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Vaciar los inputs de los datos
      setState(() {
        _selectedCustomerId = null;
        _selectedCustomerName = '';
        _products.clear();
        _totalAmount = 0.0;
        _dateController.clear();
      });
    } catch (e) {
      // Error al crear la orden de venta
      print('Error al crear la orden: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al crear la orden: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
