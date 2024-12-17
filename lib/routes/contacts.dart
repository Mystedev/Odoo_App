// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccess.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:odooapp/utilities/dialogContacts.dart';

class MyEmployees extends StatefulWidget {
  final Future<List<dynamic>> contactsFuture; // Declarar propiedad

  const MyEmployees({super.key, required this.contactsFuture}); // Inicializar propiedad

  @override
  _MyEmployeesState createState() => _MyEmployeesState();
}

class _MyEmployeesState extends State<MyEmployees> {
  late Future<List<dynamic>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = widget.contactsFuture; // Asignar el valor recibido al Future local
  }

  Future<void> fetchApi() async {
    setState(() {
      _contactsFuture = ApiFetch.fetchContacts(); // Recargar contactos directamente desde la API
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts List'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_outlined,
                color: Colors.white, size: 30),
            onPressed: () => fetchApi(), // Recargar lista de contactos
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No employees found'),
            );
          }

          final contacts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            shrinkWrap: true,
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          final isDarkMode =
                              Theme.of(context).brightness == Brightness.dark;

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact['name'] ?? 'No Name',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Email: ${contact['email'] ?? 'No Email'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Phone: ${contact['phone'] ?? 'No Phone'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'VAT: ${contact['vat'] ?? 'No VAT'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Close'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: ListTile(
                      title: Text(contact['name'] ?? 'No Name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${contact['email'] ?? 'No Email'}'),
                          Text('VAT: ${contact['vat'] ?? 'No VAT'}'),
                        ],
                      ),
                      trailing: const Icon(Icons.info_sharp,color:  Color.fromARGB(255, 15, 132, 186)),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            label: 'Add',
            onTap: () =>
                DialogHelpersContacts.showAddContactDialog(context, fetchApi),
          ),
          SpeedDialChild(
            child: const Icon(Icons.no_accounts_sharp),
            label: 'Delete',
            onTap: () => DialogHelpersContacts.showDeleteContactDialog(
                context, ApiFetch.fetchContacts, _contactsFuture,fetchApi),
          ),
          SpeedDialChild(
            child: const Icon(Icons.manage_accounts),
            label: 'Update contact',
            onTap: () => DialogHelpersContacts.showUpdateContactDialog(context, _contactsFuture, fetchApi)
          ),
        ],
      ),
    );
  }
}
