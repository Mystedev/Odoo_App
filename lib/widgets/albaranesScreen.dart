// ignore_for_file: prefer_final_fields, avoid_print

import 'package:flutter/material.dart';
import 'package:odooapp/routes/comandes.dart';

class AlbaranesScreen extends StatefulWidget {
  const AlbaranesScreen({super.key});

  @override
  State<AlbaranesScreen> createState() => _AlbaranesScreenState();
}

class _AlbaranesScreenState extends State<AlbaranesScreen> {
  List<Map<String, dynamic>> _albaranes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albaranes y Ventas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _albaranes.isEmpty
              ? const Center(child: Text('No se han guardado albaranes.'))
              : ListView.builder(
                  itemCount: _albaranes.length,
                  itemBuilder: (context, index) {
                    final albaran = _albaranes[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Albarán: ${albaran['contact']}'),
                        subtitle: Text(
                            'Fecha: ${albaran['date']}, Total: \$${albaran['total']}'),
                        trailing: const Icon(Icons.arrow_forward),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAlbaran = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MySalesOdoo(),
            ),
          );
          print('Nou albarà retornat: $newAlbaran');
          if (newAlbaran != null) {
            setState(() {
              _albaranes.add(newAlbaran);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

