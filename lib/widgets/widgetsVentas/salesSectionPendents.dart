import 'package:flutter/material.dart';

// Pantalla para mostrar las ventas en tarjetas
class SalesSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> sales;
  final Function(Map<String, dynamic>) onSaleTap;

  const SalesSection({
    required this.title,
    required this.sales,
    required this.onSaleTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        if (sales.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'No hay ventas en esta sección.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else
          ...sales.map((sale) {
            return GestureDetector(
              onTap: () => onSaleTap(sale), // Accede a la pantalla de detalles
              child: Card(
                color: const Color.fromARGB(255, 157, 202, 218),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(
                            sale['customerName'] ?? 'Cliente no especificado',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Productos (${sale['products'].length}):',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Muestra los primeros 2 productos
                      ..._buildProductSummary(sale['products']),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  List<Widget> _buildProductSummary(List<dynamic> products) {
    // Mostrar solo los primeros 2 productos y indicar si hay más
    const maxProducts = 2;
    final List<Widget> productWidgets = [];
    for (var i = 0; i < products.length && i < maxProducts; i++) {
      final product = products[i];
      productWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Color.fromARGB(255, 67, 230, 154), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product['name']} (x${product['quantity']})',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (products.length > maxProducts) {
      productWidgets.add(
        const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 4),
          child: Text(
            '... y más',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }
    return productWidgets;
  }
}
