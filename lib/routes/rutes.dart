// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';
import 'package:odooapp/routes/comandes.dart';
import 'package:odooapp/routes/comandesPendents.dart';

class MyRoutes extends StatefulWidget {
  final Future<List<dynamic>> routesFuture;

  const MyRoutes({super.key, required this.routesFuture});

  @override
  State<MyRoutes> createState() => _MyRoutesState();
}

class _MyRoutesState extends State<MyRoutes> {
  late Future<List<dynamic>> _routes = Future.value([]);

  @override
  void initState() {
    super.initState();
    _routes = widget.routesFuture;
  }

  // Llamada para obtener los detalles de los contactos por ID
  Future<List<Map<String, dynamic>>> fetchContactDetails(
      List<int> contactIds) async {
    // Llama a la API para obtener los detalles de los contactos usando los IDs
    // Deberás implementar esta función en tu API de Odoo (ApiFetch).
    return ApiFetch.fetchContactsByIds(contactIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rutas',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: () {
              _routes = ApiFetch.fetchRoutes();
            },
          )
        ],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _routes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron rutas.'));
          }

          final routes = snapshot.data!;

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final routeName = route['x_name']?.toString() ?? 'Sin nombre';
              final contactIds = List<int>.from(
                  route['x_studio_one2many_field_2en_1ievjou3p']);

              // Se hace la llamada para obtener los detalles de los contactos
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchContactDetails(contactIds),
                builder: (context, contactsSnapshot) {
                  if (contactsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Cargando rutas...'),
                    );
                  } else if (contactsSnapshot.hasError) {
                    return ListTile(
                      title: const Text('Error al cargar las rutas'),
                      subtitle: Text(contactsSnapshot.error.toString()),
                    );
                  }
                  final contactDetails = contactsSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 4,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF00344D),
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        routeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text("Paradas: ${contactDetails.length}"),
                          const SizedBox(height: 6),
                          // Lista de los nombres de las empresas obtenidas

                          LinearProgressIndicator(
                            value: 0.7, // Ajusta con progreso real si lo tienes
                            backgroundColor: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF00344D),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.info,
                        color: Colors.blueAccent,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return DraggableScrollableSheet(
                              expand: false,
                              builder: (context, scrollController) {
                                return SingleChildScrollView(
                                  controller: scrollController,
                                  child: RouteDetailsBottomSheet(
                                    routeName: routeName,
                                    stops: contactDetails
                                        .map<String>(
                                            (contact) => contact['name'])
                                        .toList(), contactDetails: contactDetails,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

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
                    color: Color(0xFF00344D),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            final Map<String, dynamic> initialSale = {
                              'client_name':
                                  stop, // Asigna el nombre del cliente actual
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MySalesOdoo(initialSale: initialSale),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Nueva Venta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 60, 117, 62),
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

                                // Mostrar las ventas en un ModalBottomSheet
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.8,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Ventas del Cliente',
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                            if (clientSales.isEmpty)
                                              const Text(
                                                  'Este cliente no tiene ventas registradas.'),
                                            if (clientSales.isNotEmpty)
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: clientSales.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final sale =
                                                        clientSales[index];
                                                    return Card(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: ListTile(
                                                        leading: const Icon(
                                                            Icons.receipt,
                                                            color: Colors.blue),
                                                        title: Text(sale[
                                                                'sale_name'] ??
                                                            'Venta ${index + 1}'),
                                                        subtitle: Text(
                                                            'Fecha: ${sale['date_order'] ?? 'Desconocida'}'),
                                                        trailing: Text(
                                                            'Total: \$${sale['amount_total']}'),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context); // Cerrar el Modal
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                              child: const Text('Cerrar'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
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
                          icon: const Icon(Icons.list),
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
