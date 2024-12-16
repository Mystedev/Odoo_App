// ignore_for_file: use_build_context_synchronously, unused_local_variable, no_leading_underscores_for_local_identifiers, unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:odooapp/api/apiAccessOdoo.dart';

class DialogHelpersContacts {
  // Función para mostrar el cuadro de diálogo de agregar contacto
  static void showAddContactDialog(
      BuildContext context, VoidCallback refreshContacts) {
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
                  refreshContacts(); // Refrescar contactos
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

  // Función para mostrar el cuadro de diálogo de eliminar contacto
  static void showDeleteContactDialog(
      BuildContext context,
      Future<List<dynamic>> Function() fetchContacts,
      Future<List<dynamic>> _contactsFuture,
      VoidCallback refreshContacts) async {
    try {
      final contacts = await _contactsFuture;

      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No contacts found to delete.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String? selectedContactName;
      int? selectedContactId;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Select Contact to Delete'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        title: Text(contact['name'] ?? 'No Name'),
                        onTap: () {
                          setState(() {
                            selectedContactName = contact['name'];
                            selectedContactId = contact['id'];
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
                      Navigator.pop(context); // Cerrar el diálogo
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedContactId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a contact to delete.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        await ApiFetch.deleteContacts([selectedContactId!]);
                        Navigator.pop(context); // Cerrar el diálogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Contact "$selectedContactName" deleted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        refreshContacts(); // Refrescar contactos
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete contact: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Delete'),
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

  static void showUpdateContactDialog(BuildContext context,
      Future<List<dynamic>> _contactsFuture, VoidCallback fetchApi) async {
    try {
      final contacts = await _contactsFuture; // Obtener contactos desde _contactsFuture

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
                        fetchApi,
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

  static void _showEditContactDialog(
      BuildContext context,
      int contactId,
      String initialName,
      String initialEmail,
      String initialPhone,
      String initialVat,
      VoidCallback fetchApi) {
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
}
