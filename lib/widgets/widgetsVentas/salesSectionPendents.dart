import 'package:flutter/material.dart';

class SalesSection extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final List<Map<String, dynamic>> sales;
  final Function(Map<String, dynamic>) onSaleTap;
  final Function(Map<String, dynamic>)? onSaleLongPress;

  const SalesSection({
    super.key,
    required this.title,
    required this.titleStyle,
    required this.sales,
    required this.onSaleTap,
    this.onSaleLongPress,
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
              onTap: () => onSaleTap(sale),
              onLongPress: onSaleLongPress != null
                  ? () => onSaleLongPress!(sale)
                  : null,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono principal (puede ser una imagen en lugar de un icono)
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.store,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Información principal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale['customerName'] ?? 'Cliente no especificado',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${sale['date'] ?? 'No especificada'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._buildProductSummary(sale['products']),
                          ],
                        ),
                      ),
                      // Total
                      Column(
                        children: [
                          Text(
                            '\$${sale['totalAmount'] ?? '0.0'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sale['products'].length > 1
                                ? '${sale['products'].length} productos'
                                : '${sale['products'].length} producto',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  List<Widget> _buildProductSummary(List<dynamic> products) {
    const maxProducts = 2;
    final List<Widget> productWidgets = [];
    for (var i = 0; i < products.length && i < maxProducts; i++) {
      final product = products[i];
      productWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              ),
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
