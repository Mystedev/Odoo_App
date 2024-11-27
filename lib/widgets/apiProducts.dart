// ignore_for_file: unused_local_variable, avoid_print, unused_import

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiFetch {
  static String? sessionId;

  // Autenticación en Odoo
  static Future<void> authenticate() async {
    final url = Uri.parse('http://10.0.2.2:8069/web/session/authenticate');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "db": "odoo_dennys",
          "login": "jnegredo@andorsoft.ad",
          "password": "odoo",
        },
        "id": 1
      }),
    );

    if (response.statusCode == 200) {
      String? rawCookie = response.headers['set-cookie'];
      int index = rawCookie!.indexOf('session_id=');
      if (index != -1) {
        sessionId =
            rawCookie.substring(index + 11, rawCookie.indexOf(';', index));
        print('Sesión obtenida: $sessionId');
      }
      if (sessionId == null) {
        throw Exception('No se pudo obtener session_id');
      }
    } else {
      throw Exception('Error al autenticar: ${response.statusCode}');
    }
  }

  // Obtener datos del módulo Contacts
  static Future<List<dynamic>> fetchContacts() async {
    final url = Uri.parse('http://10.0.2.2:8069/web/dataset/call_kw');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId', // Encabezado para la API key
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "res.partner", // Modelo de contactos en Odoo
          "method": "search_read",
          "args": [],
          "kwargs": {
            "fields": ["id", "name", "email", "phone"], // Campos que necesitas
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] != null) {
        print('Datos obtenidos: ${data['result']}');
        return List<dynamic>.from(data['result']);
      } else {
        throw Exception('No se pudo obtener los contactos');
      }
    } else {
      throw Exception('Error al obtener contactos: ${response.statusCode}');
    }
  }

  static Future<void> addContact(
      String name, String email, String phone) async {
    final url = Uri.parse('http://10.0.2.2:8069/web/dataset/call_kw');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId', // Usar la sesión autenticada
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "res.partner", // Modelo de contactos en Odoo
          "method": "create", // Método para crear registros
          "args": [
            {
              "name": name, // Nombre del contacto
              "email": email, // Correo electrónico
              "phone": phone, // Teléfono
            }
          ], // Aquí es importante que args sea una lista
          "kwargs": {

          }, // Vacío si no hay argumentos adicionales
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] != null) {
        print('Contacto añadido con éxito, ID: ${data['result']}');
      } else {
        print('Error al añadir contacto: ${response.body}');
        throw Exception('No se pudo añadir el contacto');
      }
    } else {
      print('Error en la respuesta: ${response.body}');
      throw Exception('Error al añadir contacto: ${response.statusCode}');
    }
  }

  // Obtener datos del módulo Inventory (Productos)
  static Future<List<dynamic>> fetchProducts() async {
    final url = Uri.parse('http://10.0.2.2:8069/web/dataset/call_kw');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId', // Encabezado para la API key
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "product.product", // Modelo de productos en Odoo
          "method": "search_read",
          "args": [],
          "kwargs": {
            "fields": [
              "id",
              "name",
              "list_price", // Precio de venta
              "standard_price", // Costo del producto
            ],
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] != null) {
        // Modificamos para obtener el nombre de la categoría
        var products = List<dynamic>.from(data['result']);
        products = await Future.wait(products.map((product) async {
          var categoryName =
              await fetchProductCategoryName(product['categ_id']);
          product['categ_name'] = categoryName;
          return product;
        }));
        print('Productos obtenidos: $products');
        return products;
      } else {
        throw Exception('No se pudieron obtener los productos');
      }
    } else {
      throw Exception('Error al obtener productos: ${response.statusCode}');
    }
  }

  static Future<void> addProduct(String name, double listPrice,
    double standardPrice) async {
  final url = Uri.parse('http://10.0.2.2:8069/web/dataset/call_kw');

  // Validar si los IDs son válidos antes de enviar
  final validUomIds = await fetchUnitsOfMeasure();

  final defaultUomId =
      validUomIds.isNotEmpty ? validUomIds.first['id'] : null;
  if (defaultUomId == null) {
    throw Exception('No valid unit of measure found');
  }

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Cookie': 'session_id=$sessionId',
    },
    body: jsonEncode({
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "model": "product.product",
        "method": "create",
        "args": [
          {
            "name": name,
            "list_price": listPrice,
            "standard_price": standardPrice,
            "uom_id": defaultUomId,
            "uom_po_id": defaultUomId, // Asignar la misma unidad para compras
          }
        ],
        "kwargs": {
          
        },
      },
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['result'] != null) {
      print('Producto añadido con éxito, ID: ${data['result']}');
    } else {
      print('Error al añadir producto: ${response.body}');
      throw Exception('No se pudo añadir el producto');
    }
  } else {
    print('Error en la respuesta: ${response.body}');
    throw Exception('Error al añadir producto: ${response.statusCode}');
  }
}


  static Future<List<dynamic>> fetchCategories() async {
    final url = Uri.parse('http://10.0.2.2:8069/web/dataset/call_kw');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "product.category",
          "method": "search_read",
          "args": [],
          "kwargs": {
            "fields": ["id", "name"], // Campos necesarios
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] ?? [];
    } else {
      throw Exception('Error al obtener categorías: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> fetchUnitsOfMeasure() async {
    final url = Uri.parse('http://10.0.2.2:8069/web/dataset/call_kw');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId',
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "uom.uom",
          "method": "search_read",
          "args": [],
          "kwargs": {
            "fields": ["id", "name"], // Campos necesarios
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['result'] ?? [];
    } else {
      throw Exception(
          'Error al obtener unidades de medida: ${response.statusCode}');
    }
  }

// Obtener el nombre de la categoría del producto
  static Future<String> fetchProductCategoryName(dynamic categId) async {
    final url = Uri.parse('http://10.0.2.2:8069/web/dataset/call_kw');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'session_id=$sessionId', // Encabezado para la API key
      },
      body: jsonEncode({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
          "model": "product.category", // Modelo de categorías
          "method": "search_read",
          "args": [
            ['id', '=', categId] // Buscar por ID de la categoría
          ],
          "kwargs": {
            "fields": ["name"], // Nombre de la categoría
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] != null && data['result'].isNotEmpty) {
        return data['result'][0]['name']; // Devuelve el nombre de la categoría
      } else {
        return 'Unknown Category'; // Si no se encuentra la categoría
      }
    } else {
      throw Exception('Error al obtener categoría: ${response.statusCode}');
    }
  }
}
