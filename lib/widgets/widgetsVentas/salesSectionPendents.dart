// ignore_for_file: deprecated_member_use

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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: titleStyle,
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
                color: Colors.grey[100],
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2, // Sombras suaves para minimalismo
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.store,
                          size: 24,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sale['customerName'] ?? 'Cliente no especificado',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${sale['date'] ?? 'No especificada'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 139, 139, 139),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              color: Color.fromARGB(255, 135, 135, 135),
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
}

