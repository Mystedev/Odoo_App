// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ClientSalesModal extends StatelessWidget {
  final List<Map<String, dynamic>> sales;

  const ClientSalesModal({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ventas del Cliente',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (sales.isEmpty)
              const Text('Este cliente no tiene ventas registradas.'),
            if (sales.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey),
                      ),
                      elevation: 1.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.receipt, color: Colors.blue),
                        title: Text(sale['name']),
                        subtitle: Text(
                            'Fecha: ${sale['date_order'] ?? 'Desconocida'}'),
                        trailing: Text('Total: \$${sale['amount_total']}'),
                      ),
                    );
                  },
                ),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el Modal
              },
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}
