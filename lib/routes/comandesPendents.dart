// ignore_for_file: file_names

import 'package:flutter/material.dart';

class MyWaitingSales extends StatefulWidget {
  const MyWaitingSales({super.key});

  @override
  State<MyWaitingSales> createState() => _MyWaitingSalesState();
}

class _MyWaitingSalesState extends State<MyWaitingSales> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color(0xFF00344D),
              title: const Text(
                'Pendientes',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: 'Cascadia Code',
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: const TabBarView(children: [
              Center(
                child: Text('Borrador'),
              ),
              Center(
                child: Text('Pendientes de enviar'),
              ),
              Center(
                child: Text('Guardados'),
              )
            ]),
          )),
    );
  }
}
