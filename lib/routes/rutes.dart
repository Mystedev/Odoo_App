import 'package:flutter/material.dart';

class MyRoutes extends StatefulWidget {
  const MyRoutes({super.key});

  @override
  State<MyRoutes> createState() => _MyRoutesState();
}

class _MyRoutesState extends State<MyRoutes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 230, 244, 246),
          title: const Text(
            'Rutas',
            style: TextStyle(color: Colors.black),
          ),
          foregroundColor: Colors.black,
        ),
        body: Container(
          padding: const EdgeInsets.all(18),
          child: const Column(
            children: [
              Text('Lista de rutas',style: TextStyle(
                fontSize: 20
              ),),
            ],
          ),
        ));
  }
}
