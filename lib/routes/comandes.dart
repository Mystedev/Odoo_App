// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';
import 'package:odooapp/utilities/salesHelpers.dart';

class MySalesOdoo extends StatefulWidget {
  final Map<String, dynamic> initialSale;

  const MySalesOdoo({super.key, required this.initialSale});

  @override
  State<MySalesOdoo> createState() => _MySalesOdooState();
}

class _MySalesOdooState extends State<MySalesOdoo> {
  List<Map<String, dynamic>> _products = [];
  int? _selectedCustomerId;
  int? _selectedProductId;
  String _selectedCustomerName = '';
  String _selectedCustomerVat = '';
  double _totalAmount = 0.0;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _isDraft = false; // Variable para controlar el estado de borrador

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Cargar datos de la venta inicial desde el borrador
    if (widget.initialSale.isNotEmpty) {
      _selectedCustomerName = widget.initialSale['customerName'] ?? '';
      _selectedCustomerVat = widget.initialSale['vat'] ?? '';
      _dateController.text = widget.initialSale['date'] ?? '';
      _products =
          List<Map<String, dynamic>>.from(widget.initialSale['products'] ?? []);
      _totalAmount =
          double.tryParse(widget.initialSale['totalAmount'] ?? '0.0') ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        foregroundColor: Colors.white,
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
        onTap: () =>
            SalesHelper.showCustomerSelectionDialog(context, (id, name, vat) {
          setState(() {
            _selectedCustomerId = id;
            _selectedCustomerName = name;
            _selectedCustomerVat = vat;
          });
        }),
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
      onTap: () => SalesHelper.selectDate(context, _dateController),
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
      future: SalesHelper.fetchProducts(),
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
                      final selectedProduct = products.firstWhere((product) => product['id'] == value);
                      _productNameController.text = selectedProduct['name'];
                      _unitPriceController.text = selectedProduct['list_price'].toString();
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
                      onPressed: () {
                        SalesHelper.addProduct(
                          context,
                          _products,
                          _productNameController,
                          _unitPriceController,
                          _quantityController,
                          _selectedProductId,
                          _totalAmount,
                          (updatedProducts, updatedTotal) {
                            setState(() {
                              _products = updatedProducts;
                              _totalAmount = updatedTotal;
                            });
                          },
                        );
                      },
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

  // Lista de productos añadidos
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

  // Barra inferior con el botón de guardar y enviar
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 65,
      color: const Color.fromARGB(255, 49, 87, 105),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 244, 245, 247)),
            onPressed: () {
              final draftSale = {
                'title': 'Borrador - ${_dateController.text}',
                'description': 'Venta en progreso guardada.',
                'customerName': _selectedCustomerName,
                'vat': _selectedCustomerVat,
                'date': _dateController.text,
                'products': _products
                    .map((product) => {
                          'name': product['name'],
                          'quantity': product['quantity'].toString(),
                          'unitPrice': product['unitPrice'].toString(),
                          'total': product['total'].toString(),
                        })
                    .toList(),
                'totalAmount': _totalAmount.toString(),
              };

              // Actualizamos el estado para indicar que estamos en borrador
              setState(() {
                _isDraft = true;
              });

              Navigator.pop(context, draftSale);
            },
            child: const Text(
              'Borrador',
              style: TextStyle(color: Colors.red),
            ),
          ),
          Text('Total: \$$_totalAmount',
              style: const TextStyle(fontSize: 18, color: Colors.white)),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.send,
              color: Colors.blue,
            ),
            label: const Text(
              'Enviar',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Eliminar un producto de la lista
  void _removeProduct(Map<String, dynamic> product) {
    setState(() {
      _products.remove(product);
      _totalAmount -= product['total'];
    });
  }

  // Función para enviar la orden
  void _submitOrder() async {
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

      final newSale = {
        'title': 'Venta $orderId',
        'description': 'Venta enviada con éxito el ${_dateController.text}.',
        'customerName': _selectedCustomerName,
        'vat': _selectedCustomerVat,
        'date': _dateController.text,
        'products': _products
            .map((product) => {
                  'name': product['name'],
                  'quantity': product['quantity'].toString(),
                  'unitPrice': product['unitPrice'].toString(),
                  'total': product['total'].toString(),
                })
            .toList(),
        'totalAmount': _totalAmount.toString(),
        'status': 'pending', // Estado de venta pendiente
      };

      Navigator.pop(context, newSale);

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
}
