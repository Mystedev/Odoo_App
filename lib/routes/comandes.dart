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
  late Future<List<dynamic>> _contactList = Future.value();
  late Future<List<dynamic>> _productList;
  int? _selectedCustomerId;
  int? _selectedProductId;
  String _selectedCustomerName = '';
  String _selectedCustomerVat = '';
  double _totalAmount = 0.0;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _contactList = _loadContactsFromAPI();
    _productList = _loadProductsFromAPI();
  }

  // Cargar datos iniciales de la venta o borrador
  void _loadInitialData() {
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

  // Obtener contactos desde la API
  Future<List<dynamic>> _loadContactsFromAPI() async {
    try {
      return await ApiFetch
          .fetchContacts(); // Usamos la API para obtener contactos
    } catch (e) {
      throw Exception('Error al obtener contactos: $e');
    }
  }

  // Obtener productos desde la API
  Future<List<dynamic>> _loadProductsFromAPI() async {
    try {
      return await ApiFetch
          .fetchProducts(); // Usamos la API para obtener productos
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCustomerCard() {
  return FutureBuilder<List<dynamic>>(
    future: _contactList,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No se pudieron cargar los contactos.');
      }

      // Convierte la lista dinámica a una lista de Map<String, dynamic>
      final List<Map<String, dynamic>> contacts = List<Map<String, dynamic>>.from(snapshot.data!);

      return Card(
        elevation: 2,
        child: ListTile(
          onTap: () => SalesHelper.showCustomerSelectionDialog(
            context,
            (id, name, vat) {
              setState(() {
                _selectedCustomerId = id;
                _selectedCustomerName = name;
                _selectedCustomerVat = vat;
              });
            },
            contacts, // Pasamos la lista de contactos convertida correctamente
          ),
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
    },
  );
}


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

  Widget _buildProductForm() {
    return FutureBuilder<List<dynamic>>(
      future: _productList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Text('No se pudieron cargar los productos.');
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 65,
      color: const Color.fromARGB(255, 49, 87, 105),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              final draftSale = {
                'title': 'Borrador - ${_dateController.text}',
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

              Navigator.pop(
                  context, draftSale); // Devuelve el borrador actualizado
            },
            child: const Text('Guardar Borrador'),
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

  void _removeProduct(Map<String, dynamic> product) {
    setState(() {
      _products.remove(product);
      _totalAmount -= product['total'];
    });
  }

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
