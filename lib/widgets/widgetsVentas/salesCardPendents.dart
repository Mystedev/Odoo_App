// Pantalla para mostrar los detalles de una venta
import 'package:flutter/material.dart';

class SaleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> sale;

  const SaleDetailsPage({required this.sale, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sale['title'] ?? 'Detalles de la Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${sale['customerName'] ?? 'Sin cliente'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'VAT: ${sale['vat'] ?? 'Sin VAT'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha: ${sale['date'] ?? 'Sin fecha'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Productos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...sale['products'].map<Widget>((product) {
              return ListTile(
                title: Text(product['name']),
                subtitle: Text(
                    'Cantidad: ${product['quantity']} - Precio unitario: \$${product['unitPrice']}'),
                trailing: Text('Total: \$${product['total']}'),
              );
            }).toList(),
            const Divider(),
            Text(
              'Total de la venta: \$${sale['totalAmount']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
