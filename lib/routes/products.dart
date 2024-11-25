import 'package:flutter/material.dart';

class MyProducts extends StatelessWidget {
  const MyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
      ),
      body: ListView.builder(
        itemCount: 30,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  // Acción al hacer clic en el ListTile
                },
                child: ListTile(
                  title: Text('Product $index'),
                  subtitle: Text('Details of Product $index'),
                  trailing: const Icon(Icons.production_quantity_limits),
                ),
              ),
              const Divider(), // Divider entre cada ListTile
            ],
          );
        },
      ),
    );
  }
}
