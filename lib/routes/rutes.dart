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
      ),
      body: ListView.builder(
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            shadowColor: Colors.black,
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF00344D),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.info,
                color: Colors.blueAccent,
              ),
              onTap: () {
                // Mostrar el modal_bottom_sheet con los detalles de la ruta seleccionada
                showModalBottomSheet(
                  context: context,
                  isScrollControlled:
                      true, // Permite que el modal ocupe más espacio
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

class RouteDetailsBottomSheet extends StatefulWidget {
  final String routeName;
  final List<String> stops;

  const RouteDetailsBottomSheet({
    super.key,
    required this.routeName,
    required this.stops,
  });

  @override
  _RouteDetailsBottomSheetState createState() =>
      _RouteDetailsBottomSheetState();
}

class _RouteDetailsBottomSheetState extends State<RouteDetailsBottomSheet> {
  // Track de qué cliente está expandido
  String? expandedClient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.routeName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Clientes:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Lista de paradas con estilo más limpio
          for (var stop in widget.stops)
            Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.business,
                    color: Color(0xFF00344D),
                  ),
                  title: Text(stop),
                  trailing: Icon(
                    expandedClient == stop
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    setState(() {
                      // Expande o contrae la sección de botones
                      if (expandedClient == stop) {
                        expandedClient = null;
                      } else {
                        expandedClient = stop;
                      }
                    });
                  },
                ),
                if (expandedClient == stop)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Acción para crear una nueva venta
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Nueva Venta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 60, 117, 62),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Acción para consultar ventas del cliente
                          },
                          icon: const Icon(Icons.list),
                          label: const Text('Ver Ventas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 31, 63, 120),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(), // Línea separadora entre cada cliente
              ],
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
