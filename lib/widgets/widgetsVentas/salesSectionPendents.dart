import 'package:flutter/material.dart';

// Pantalla para mostrar las ventas en tarjetas
class SalesSection extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final List<Map<String, dynamic>> sales;
  final Function(Map<String, dynamic>) onSaleTap;
  final Function(Map<String, dynamic>)? onSaleLongPress; // Parámetro opcional

  const SalesSection({
    super.key,
    required this.title,
    required this.titleStyle,
    required this.sales,
    required this.onSaleTap,
    this.onSaleLongPress, // Acepta una función opcional
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,// Alinea los elementos desde la izquierda
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
          ...sales.map((sale) { // Itera sobre la lista de ventas para encontrar el elemento requerido
            return GestureDetector(
              onTap: () => onSaleTap(sale), // Accede a la pantalla de detalles y muestra los datos de la venta seleccionada
              onLongPress: onSaleLongPress != null
                ? () => onSaleLongPress!(sale)
                : null, // Maneja mantener presionado
              child: Card(
                color: const Color.fromARGB(255, 119, 179, 201),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column( // Tarjeta con la informacion de la venta en la pantalla de ventas
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
          })
      ],
    );
  }

  List<Widget> _buildProductSummary(List<dynamic> products) { // Crea un resumen con los datos obtenidos para referir a la venta añadida a la lista
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
    if (products.length > maxProducts) { // Se muestran inicialmente 2 ventas y si hay mas , se añade la opcion de ver el resto al pulsar encima
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
