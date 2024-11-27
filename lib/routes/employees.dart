// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:odooapp/widgets/apiProducts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MyEmployees extends StatefulWidget {
  const MyEmployees({super.key});

  @override
  _MyEmployeesState createState() => _MyEmployeesState();
}

class _MyEmployeesState extends State<MyEmployees> {
  late Future<List<dynamic>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = fetchContacts(); // Inicializa la lista de contactos
  }

  Future<List<dynamic>> fetchContacts() async {
    await ApiFetch.authenticate(); // Autenticación
    return await ApiFetch.fetchContacts(); // Obtener contactos
  }

  Future<void> fetchApi() async {
    await ApiFetch.authenticate(); // Autenticación
    setState(() {
      _contactsFuture = fetchContacts(); // Recargar la lista de contactos
    });
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All fields are required!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await ApiFetch.addContact(name, email, phone);
                  Navigator.pop(context); // Cerrar el cuadro de diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  fetchApi(); // Recargar la lista después de agregar un nuevo contacto
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add contact: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_outlined, color: Colors.white, size: 30),
            onPressed: () => fetchApi(), // Recargar la lista de contactos
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _contactsFuture, // Utiliza el future actual
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Indicador de carga
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'), // Mostrar errores
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No employees found'), // Sin datos
            );
          }

          // Mostrar la lista de contactos
          final contacts = snapshot.data!;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Mostrar el BottomSheet
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
                                        : Colors.black, // Cambia según el tema
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
                                const SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: const ButtonStyle(
                                      foregroundColor: WidgetStatePropertyAll(
                                          Colors.white),
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.black),
                                    ),
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
                      subtitle: Text(contact['email'] ?? 'No Email'),
                      trailing: const Icon(Icons.info_outline_rounded),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.lens_blur,
        activeIcon: Icons.close,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        buttonSize: const Size(20, 60),
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add,color: Colors.deepPurple,),
            backgroundColor: Colors.white,
            label: 'Add',
            onTap: () => _showAddContactDialog(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.delete,color: Colors.deepPurple,),
            backgroundColor: Colors.white,
            label: 'Delete',
            onTap: (){

            }
          ),
          SpeedDialChild(
            child: const Icon(Icons.manage_accounts,color: Colors.deepPurple,),
            backgroundColor: Colors.white,
            label: 'Update contact',
            onTap: () {
              
            },
          ),
        ],
      ),
    );
  }
}
