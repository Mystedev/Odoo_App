// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, unnecessary_null_comparison, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccess.dart';
import 'package:odooapp/routes/comandes.dart';
import 'package:odooapp/routes/comandesPendents.dart';
import 'package:odooapp/widgets/widgetsVentas/routesDetails.dart';

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
                            backgroundColor: Colors.white,
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
                                        .toList(),
                                    contactDetails: contactDetails,
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



