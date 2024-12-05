// ignore_for_file: use_build_context_synchronously, avoid_print

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
      appBar: AppBar(
        title: const Text('Crear Venta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información del Cliente'),
              const SizedBox(height: 8),
              _buildCustomerCard(),
              const SizedBox(height: 16),
              _buildSectionTitle('Detalles de la Venta'),
              const SizedBox(height: 8),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildSectionTitle('Productos'),
              const SizedBox(height: 8),
              _buildProductForm(),
              const SizedBox(height: 16),
              const Divider(),
              _products.isNotEmpty
                  ? _buildProductList()
                  : const Text('No hay productos añadidos.'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Título de cada sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Tarjeta de selección del cliente
  Widget _buildCustomerCard() {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: _showCustomerSelectionDialog,
        title: const Text('Seleccionar Cliente'),
        subtitle: Row(
          children: [
            const Icon(Icons.person_2),
            const SizedBox(width: 15),
            Text(
              _selectedCustomerName.isEmpty
                  ? 'Ningún cliente seleccionado'
                  : _selectedCustomerName,
            ),
            const SizedBox(width: 15),
            // Verifica si el vat es 'false', y si lo es, no muestra nada, si no lo es, muestra el vat
            Text(
              (_selectedCustomerVat == 'false' || _selectedCustomerVat.isEmpty)
                  ? ''
                  : _selectedCustomerVat,
            )
          ],
        ),
        trailing: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  // Campo de selección de fecha con un mejor estilo
  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      readOnly: true,
      onTap: _selectDate,
      decoration: InputDecoration(
        labelText: 'Fecha',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(Icons.calendar_today),
        hintText: 'YYYY-MM-DD',
      ),
    );
  }

  // Formulario de selección de producto
  Widget _buildProductForm() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Error al cargar productos');
        }

        final products = snapshot.data!;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Producto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _unitPriceController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Precio Unitario',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: Colors.green,
                      onPressed: _addProduct,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Lista de productos añadidos con estilo de tarjetas
  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            title: Text(product['name']),
            subtitle: Text(
                'Cantidad: ${product['quantity']} - Precio: \$${product['unitPrice']}'),
            trailing: Text('Total: \$${product['total']}'),
            leading: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeProduct(product),
            ),
          ),
        );
      },
    );
  }

  // Barra inferior con el botón de enviar
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 65,
      color: const Color.fromARGB(255, 49, 87, 105),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total: \$$_totalAmount',
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
            onPressed: _submitOrder,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de lógica del formulario (sin cambios significativos)
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

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    try {
      final products = await ApiFetch.fetchProducts();
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
          "name": _productNameController.text,
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

  void _removeProduct(Map<String, dynamic> product) {
    setState(() {
      _products.remove(product);
      _totalAmount -= product['total'];
    });
  }

  void _submitOrder() async {
    // Valida el formulario antes de enviar
    if (_selectedCustomerId == null ||
        _dateController.text.isEmpty ||
        _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      final orderLines = ApiFetch.createOrderLines(_products);
      final orderId = await ApiFetch.addSaleOrder(
        customerId: _selectedCustomerId!,
        orderDate: _dateController.text,
        vat: _selectedCustomerVat,
        orderLines: orderLines,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orden creada con éxito. ID: $orderId'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _products.clear();
        _totalAmount = 0.0;
        _dateController.clear();
        _selectedCustomerName = '';
        _selectedCustomerId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la orden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mostrar el diálogo de selección de clientes (sin cambios significativos)
  void _showCustomerSelectionDialog() async {
    try {
      final customers = await ApiFetch.fetchContacts(); // Llamada a la API
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Selecciona un Cliente'),
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
                        print('Vat del cliente: ${customer['vat']}');
                        _selectedCustomerId = customer['id'];
                        _selectedCustomerName = customer['name'];
                        _selectedCustomerVat = customer['vat'] != null &&
                                customer['vat'] != 'false'
                            ? customer['vat'].toString()
                            : '';
                      });
                      Navigator.pop(
                          context); // Cierra el diálogo después de la selección
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
}
