// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccess.dart';
import 'package:odooapp/routes/comandes.dart';
import 'package:odooapp/widgets/widgetsVentas/routesClientSalesDetails.dart';

class RouteDetailsBottomSheet extends StatefulWidget {
  final String routeName;
  final List<Map<String, dynamic>> contactDetails;
  final List<String> stops;

  const RouteDetailsBottomSheet({
    super.key,
    required this.routeName,
    required this.stops,
    required this.contactDetails,
  });

  @override
  _RouteDetailsBottomSheetState createState() =>
      _RouteDetailsBottomSheetState();
}

class _RouteDetailsBottomSheetState extends State<RouteDetailsBottomSheet> {
  String? expandedClient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.routeName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Clientes:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          for (var stop in widget.stops)
            Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.business,
                    color: Color.fromARGB(255, 37, 116, 152),
                  ),
                  title: Text(stop),
                  trailing: Icon(
                    expandedClient == stop
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    setState(() {
                      expandedClient = expandedClient == stop ? null : stop;
                    });
                  },
                ),
                if (expandedClient == stop)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            final Map<String, dynamic> initialSale = { 'client_name': stop, // Asigna el nombre del cliente actual
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MySalesOdoo(initialSale: initialSale), // Envia el nombre que hemos seleccionado para ver sus opciones
                              ),
                            );
                          },
                          icon: const Icon(Icons.add,color: Colors.white,),
                          label: const Text('Nueva Venta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 63, 152, 66),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Recuperar el ID del cliente basado en el nombre del cliente seleccionado
                            final client = widget.contactDetails.firstWhere(
                              (contact) => contact['name'] == stop,
                            );

                            if (client != null && client['id'] != null) {
                              final clientId = client['id'];

                              try {
                                // Llamar a la API para obtener las ventas filtradas por cliente
                                final clientSales =
                                    await ApiFetch.fetchSales(clientId);

                                // Mostrar el modal con las ventas
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (BuildContext context) {
                                    return ClientSalesModal(sales: clientSales);
                                  },
                                );
                              } catch (error) {
                                // Manejo de errores
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: Text(
                                        'No se pudieron cargar las ventas: $error'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              // Si el cliente no tiene un ID válido
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No se pudo obtener el ID del cliente.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.list,color: Colors.white,),
                          label: const Text('Ver Ventas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 31, 63, 120),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}