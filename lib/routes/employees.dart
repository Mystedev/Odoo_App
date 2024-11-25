import 'package:flutter/material.dart';

class MyEmployees extends StatelessWidget {
  const MyEmployees({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees List'),
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
                  title: Text('Employee $index'),
                  subtitle: Text('Details of Employee $index'),
                  trailing: const Icon(Icons.info_outline_rounded),
                ),
              ),
              const Divider(color: Colors.transparent,), // Divider entre cada ListTile
            ],
          );
        },
      ),
    );
  }
}