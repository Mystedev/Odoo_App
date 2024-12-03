import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:odooapp/utilities/dialog_helpers.dart';

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
    _contactsFuture = ApiFetch.fetchContacts(); // Obtener contactos
  }

  Future<void> fetchApi() async {
    setState(() {
      _contactsFuture = ApiFetch.fetchContacts(); // Recargar contactos
    });
  }

  void _showUpdateContactDialog(BuildContext context) async {
    try {
      final contacts = await ApiFetch.fetchContacts(); // Obtener contactos

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No contacts found to update.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? selectedContactName;
      int? selectedContactId;
      String? initialEmail;
      String? initialPhone;
      String? initialVat;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Contact to Update'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        title: Text(
                          contact['name'] ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            selectedContactName = contact['name'];
                            selectedContactId = contact['id'];
                            initialEmail = contact['email'];
                            initialPhone = contact['phone'];
                            initialVat = contact['vat'];
                          });
                        },
                        selected: selectedContactId == contact['id'],
                        selectedTileColor: Colors.deepPurple.withOpacity(0.1),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar diálogo
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedContactId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a contact to update.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context); // Cierra selección de contacto
                      _showEditContactDialog(
                        context,
                        selectedContactId!,
                        selectedContactName!,
                        initialEmail ?? '',
                        initialPhone ?? '',
                        initialVat ?? '',
                      );
                    },
                    child: const Text('Next'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching contacts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditContactDialog(BuildContext context, int contactId,
      String initialName, String initialEmail, String initialPhone, String initialVat) {
    final nameController = TextEditingController(text: initialName);
    final emailController = TextEditingController(text: initialEmail);
    final phoneController = TextEditingController(text: initialPhone);
    final vatController = TextEditingController(text: initialVat);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Contact Details'),
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
                TextField(
                  controller: vatController,
                  enabled: false, // Solo lectura
                  decoration: const InputDecoration(labelText: 'VAT'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar cuadro de diálogo
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
                  await ApiFetch.updateContact(contactId, {
                    "name": name,
                    "email": email,
                    "phone": phone,
                  });
                  Navigator.pop(context); // Cerrar cuadro de diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  fetchApi(); // Recargar lista después de actualizar
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update contact: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Update'),
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
        title: const Text('Contacts List'),
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
        icon: Icons.more_horiz,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            label: 'Add',
            onTap: () =>
                DialogHelpers.showAddContactDialog(context, fetchApi),
          ),
          SpeedDialChild(
            child: const Icon(Icons.no_accounts_sharp),
            label: 'Delete',
            onTap: () => DialogHelpers.showDeleteContactDialog(
                context, ApiFetch.fetchContacts, fetchApi),
          ),
          SpeedDialChild(
            child: const Icon(Icons.manage_accounts),
            label: 'Update contact',
            onTap: () => _showUpdateContactDialog(context),
          ),
        ],
      ),
    );
  }
}
