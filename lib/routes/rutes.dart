import 'package:flutter/material.dart';

class MyRoutes extends StatefulWidget {
  const MyRoutes({super.key});

  @override
  State<MyRoutes> createState() => _MyRoutesState();
}

class _MyRoutesState extends State<MyRoutes> {
  // Simulación de rutas y empresas a visitar
  final List<Map<String, dynamic>> routes = [
    {
      'routeName': 'Ruta 1',
      'stops': ['Empresa A', 'Empresa B', 'Empresa C'],
      'progress': 0.0,
    },
    {
      'routeName': 'Ruta 2',
      'stops': ['Empresa D', 'Empresa E'],
      'progress': 0.0,
    },
    {
      'routeName': 'Ruta 3',
      'stops': ['Empresa F', 'Empresa G', 'Empresa H', 'Empresa I'],
      'progress': 0.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rutas',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        actions: [
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color.fromARGB(0, 255, 255, 255))
            ),
            onPressed: (){}, 
            child: const Icon(Icons.replay)),
          const SizedBox(width: 20,)
        ],
      ),
      body: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.all(12),
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
                route['routeName'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text("Paradas: ${route['stops'].length}"),
                  const SizedBox(height: 6),
                  // Indicador de progreso simulado
                  LinearProgressIndicator(
                    value: route['progress'],
                    backgroundColor: Colors.grey.shade300,
                    color: const  Color(0xFF00344D),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
              trailing: const Icon(
                Icons.info,
                color: Color(0xFF00344D),
              ),
              onTap: () {
                // Mostrar el modal_bottom_sheet con los detalles de la ruta seleccionada
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // Permite que el modal ocupe más espacio
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
                            routeName: route['routeName'],
                            stops: route['stops'],
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
      ),
    );
  }
}

class RouteDetailsBottomSheet extends StatelessWidget {
  final String routeName;
  final List<String> stops;

  const RouteDetailsBottomSheet({
    super.key,
    required this.routeName,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            routeName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Empresas a visitar:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Lista de paradas con estilo más limpio
          for (var stop in stops)
            ListTile(
              leading: const Icon(
                Icons.business,
                color: Color(0xFF00344D),
              ),
              title: Text(stop),
            ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el BottomSheet
              },
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}
