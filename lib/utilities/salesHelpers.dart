import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';

class SalesHelper {
  static Future<void> selectDate(
      BuildContext context, TextEditingController dateController) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      dateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final products = await ApiFetch.fetchProducts();
      return List<Map<String, dynamic>>.from(products);
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  static void addProduct(
    BuildContext context,
    List<Map<String, dynamic>> products,
    TextEditingController productNameController,
    TextEditingController unitPriceController,
    TextEditingController quantityController,
    int? selectedProductId,
    double totalAmount,
    Function(List<Map<String, dynamic>>, double) onProductAdded,
  ) {
    if (selectedProductId == null || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos del producto')),
      );
      return;
    }

    final quantity = int.tryParse(quantityController.text);
    final unitPrice = double.tryParse(unitPriceController.text);

    if (quantity != null && unitPrice != null) {
      final newProduct = {
        "productId": selectedProductId,
        "name": productNameController.text,
        "quantity": quantity,
        "unitPrice": unitPrice,
        "total": unitPrice * quantity,
      };
      totalAmount += unitPrice * quantity;

      onProductAdded([...products, newProduct], totalAmount);

      quantityController.clear();
      productNameController.clear();
      unitPriceController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cantidad o precio inválido')),
      );
    }
  }

  static Future<void> showCustomerSelectionDialog(
    BuildContext context,
    Function(int, String, String) onCustomerSelected, List<Map<String, dynamic>> contacts,
  ) async {
    try {
      final customers = await ApiFetch.fetchContacts();
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
                      final vat = customer['vat'] != null &&
                              customer['vat'] != 'false'
                          ? customer['vat'].toString()
                          : '';
                      onCustomerSelected(customer['id'], customer['name'], vat);
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
}
