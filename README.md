# odooapp

Flutter Odoo Manager es una aplicación móvil que permite gestionar y visualizar datos de diferentes módulos dentro de una base de datos de Odoo. La aplicación se conecta a un servidor Odoo mediante una API y facilita la interacción con datos como productos, contactos y pedidos, todo desde una interfaz moderna y fácil de usar.

## Características

- **Autenticación**: Se conecta a la base de datos de Odoo a través de un sistema de autenticación seguro.
- **Gestión de productos**: Visualiza, busca y gestiona los productos almacenados en el módulo de productos de Odoo.
- **Gestión de contactos**: Administra contactos de clientes, empleados o proveedores desde el módulo de contactos de Odoo.
- **Gestión de pedidos**: Acceso a pedidos pendientes y su estado, con posibilidad de filtrado y búsqueda.
- **Modo oscuro**: La aplicación soporta modo claro y oscuro, con un cambio de tema fluido.
- **Caché de datos**: Los datos de productos y contactos se almacenan en caché localmente para un acceso rápido y eficiente, reduciendo las llamadas a la API.

## Instalación

### Prerrequisitos

- **Flutter**: Asegúrate de tener instalado Flutter en tu entorno de desarrollo. Puedes seguir la guía de instalación oficial [aquí](https://flutter.dev/docs/get-started/install).
- **Odoo**: Debes tener acceso a una instancia de Odoo con los módulos de `productos`, `contactos` y `pedidos` habilitados.
- **API de Odoo**: Configura la API para poder conectar la aplicación Flutter con tu servidor Odoo.

### Instrucciones

1. Clona este repositorio:

    ```bash
    git clone https://github.com/tu-usuario/flutter-odoo-manager.git
    ```

2. Instala las dependencias:

    ```bash
    flutter pub get
    ```

3. Configura la URL de tu servidor Odoo en el archivo de configuración de la API:

    Abre `lib/api/apiAccessOdoo.dart` y modifica la variable `baseUrl` para que apunte a tu servidor Odoo:

    ```dart
    const String baseUrl = 'https://tu-servidor-odoo.com';
    ```

4. Ejecuta la aplicación:

    ```bash
    flutter run
    ```

## Uso

1. **Pantalla de autenticación**: Ingresa tus credenciales de Odoo para acceder a la aplicación. La autenticación se realiza mediante la API del servidor Odoo.
2. **Pantalla principal**: Una vez autenticado, accede a las diferentes funcionalidades de la aplicación mediante un menú lateral (drawer):
   - **Productos**: Ver, buscar y gestionar los productos disponibles en Odoo.
   - **Contactos**: Administrar los contactos registrados en la base de datos de Odoo.
   - **Pedidos pendientes**: Visualizar y gestionar pedidos que están en proceso o pendientes.

## Arquitectura

La aplicación sigue el patrón `FutureBuilder` para gestionar las llamadas a la API y mostrar datos de manera eficiente, además de usar `shared_preferences` para almacenar en caché los datos de productos y contactos, optimizando la experiencia de usuario.

### Estructura de directorios

- `lib/`
  - `api/`: Contiene los archivos que gestionan la conexión y las peticiones a la API de Odoo.
  - `routes/`: Contiene las diferentes pantallas que se muestran en la aplicación (Productos, Contactos, Pedidos).
  - `themes/`: Define los temas claros y oscuros para la interfaz de la aplicación.
  - `widgets/`: Componentes reutilizables de la UI.
  - `main.dart`: Punto de entrada principal de la aplicación.

## Dependencias

La aplicación utiliza las siguientes dependencias de Flutter:

- `http`: Para realizar peticiones HTTP a la API de Odoo.
- `shared_preferences`: Para almacenar en caché datos localmente.
- `flutter/material.dart`: Para el diseño de la interfaz de usuario.

Puedes ver todas las dependencias en el archivo `pubspec.yaml`.

## Personalización

Puedes personalizar esta aplicación para otros módulos de Odoo según las necesidades de tu negocio. Simplemente adapta las llamadas API dentro de `apiAccessOdoo.dart` para interactuar con otros módulos como `facturación`, `inventario` o `proyectos`.
