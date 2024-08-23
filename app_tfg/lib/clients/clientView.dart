import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/common.dart';
import '../../utils/changeNotifier.dart';
import 'clientRegister.dart';
import 'clientEdit.dart';
import 'clientDetail.dart';

class ClientView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantalla Clientes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[900],
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: Colors.blue[900],
          secondary: Colors.blue[900],
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.blue[900],
          selectionColor: Colors.blue[900]?.withOpacity(0.5),
          selectionHandleColor: Colors.blue[900],
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[900]!),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600]!,
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.blue[900],
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blue[900];
              }
              return Colors.white;
            },
          ),
          checkColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.white;
              }
              return Colors.black;
            },
          ),
          side: MaterialStateBorderSide.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return BorderSide(color: Colors.blue[900]!);
              }
              return BorderSide(color: Colors.black);
            },
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: ClienteScreen(),
    );
  }
}

class ClienteScreen extends StatefulWidget {
  @override
  _ClienteScreenState createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? clientStream;
  bool showDebts = false;

  @override
  void initState() {
    super.initState();
    loadStream();
  }

  void loadStream() {
    clientStream = client.from('clientes').stream(primaryKey: ['id']);
  }

  void _toggleDebts() {
    setState(() {
      showDebts = !showDebts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        loadStream();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Nuestros clientes',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            foregroundColor: Colors.blue[900],
            backgroundColor: Colors.blue[200],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_money,
                        color: showDebts ? Colors.blue[900] : Colors.black,
                      ),
                      onPressed: () {
                        _toggleDebts();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: clientStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final clients = snapshot.data!;
                      final searchQuery = _searchController.text.toLowerCase();

                      final filteredClients = clients.where((client) {
                        final clientName = client['nombre'].toLowerCase();
                        final matchesSearchQuery =
                            clientName.contains(searchQuery);
                        final matchesNegativeBalance =
                            !showDebts || client['cartera'] < 0;

                        return matchesSearchQuery && matchesNegativeBalance;
                      }).toList();

                      filteredClients.sort((a, b) => a['nombre']
                          .toString()
                          .toLowerCase()
                          .compareTo(b['nombre'].toString().toLowerCase()));

                      return ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          final clientId = client['id'].toString();
                          final cartera = client['cartera'];
                          final clientName = client['nombre'];

                          final Widget? arrowIcon;
                          if (cartera > 0) {
                            arrowIcon =
                                Icon(Icons.arrow_upward, color: Colors.green);
                          } else if (cartera < 0) {
                            arrowIcon =
                                Icon(Icons.arrow_downward, color: Colors.red);
                          } else {
                            arrowIcon = null;
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 3.0, // Añade una sombra a la card
                            color: Colors.blue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 16.0),
                              title: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ClientDetail(clientId: clientId),
                                    ),
                                  );
                                },
                                child: Text(
                                  clientName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900]),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (arrowIcon != null)
                                    arrowIcon, // Mostrar si no es nulo
                                  if (arrowIcon != null) SizedBox(width: 8.0),
                                  IconButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditClient(clientId: clientId)),
                                      );

                                      if (result == true) {
                                        loadStream();
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      bool confirmarEliminacion =
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20.0)),
                                                    side: BorderSide(
                                                      color: Colors.blue[900]!,
                                                      width: 5.0,
                                                    ),
                                                  ),
                                                  title: Center(
                                                    child: Text(
                                                      "Eliminar cliente",
                                                      style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue[900],
                                                      ),
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          "¿Seguro que quieres eliminar este cliente?",
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextButton(
                                                            child: Text(
                                                              "Cancelar",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue[900],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              "Confirmar",
                                                              style: TextStyle(
                                                                color: Colors
                                                                        .yellow[
                                                                    600],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all<
                                                                          Color>(
                                                                Colors
                                                                    .blue[900]!,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });

                                      if (confirmarEliminacion == true) {
                                        bool eliminado =
                                            await _deleteClient(clientId);
                                      }
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterClient()),
              );

              if (result == true) {
                loadStream();
                setState(() {});
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.yellow[600],
          ),
        );
      },
    );
  }

  Future<bool> _deleteClient(String clientId) async {
    try {
      await Supabase.instance.client
          .from('clientes')
          .delete()
          .eq('id', clientId);

      loadStream();
      setState(() {});

      return true;
    } catch (e) {
      return false;
    }
  }
}


/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar provider
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/common.dart';
import '../../utils/changeNotifier.dart'; // Importar el RefreshNotifier
import 'clientRegister.dart';
import 'clientEdit.dart';
import 'clientDetail.dart';

class ClientView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantalla Clientes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[900], // Establece el color primario a blue900
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: Colors.blue[900], // Aplica blue900 como el color primario
          secondary:
              Colors.blue[900], // Establece el color secundario a blue900
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors
              .blue[900], // Cambia el color del cursor en los campos de texto
          selectionColor: Colors.blue[900]
              ?.withOpacity(0.5), // Cambia el color de la selección de texto
          selectionHandleColor:
              Colors.blue[900], // Cambia el color del manejador de selección
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey[600]!), // Borde por defecto
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey[600]!), // Borde cuando no está en foco
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[900]!),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600]!, // Color gris cuando no está enfocado
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.blue[900], // Color azul cuando está enfocado
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blue[900]; // Color azul cuando está seleccionado
              }
              return Colors.white; // Color blanco cuando no está seleccionado
            },
          ),
          checkColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors
                    .white; // El color del checkmark dentro de la casilla
              }
              return Colors.black; // Color del checkmark cuando está vacío
            },
          ),
          side: MaterialStateBorderSide.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return BorderSide(
                    color: Colors
                        .blue[900]!); // Borde azul cuando está seleccionado
              }
              return BorderSide(
                  color: Colors.black); // Borde negro cuando está vacío
            },
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: ClienteScreen(),
    );
  }
}

class ClienteScreen extends StatefulWidget {
  @override
  _ClienteScreenState createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? clientStream;
  bool showDebts = false;

  @override
  void initState() {
    super.initState();
    loadStream();
  }

  void loadStream() {
    clientStream = client.from('clientes').stream(primaryKey: ['id']);
  }

  void _toggleDebts() {
    setState(() {
      showDebts = !showDebts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        // Recargar el stream cuando se notifique un cambio
        loadStream();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Nuestros clientes',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            foregroundColor: Colors.blue[900],
            backgroundColor: Colors.blue[200],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_money,
                        color: showDebts ? Colors.blue[900] : Colors.black,
                      ),
                      onPressed: () {
                        _toggleDebts();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: clientStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final clients = snapshot.data!;
                      final searchQuery = _searchController.text.toLowerCase();

                      // Filtrar clientes según la búsqueda y el estado del balance negativo
                      final filteredClients = clients.where((client) {
                        final clientName = client['nombre'].toLowerCase();
                        final matchesSearchQuery =
                            clientName.contains(searchQuery);
                        final matchesNegativeBalance =
                            !showDebts || client['cartera'] < 0;

                        return matchesSearchQuery && matchesNegativeBalance;
                      }).toList();

                      // Ordenar los clientes por nombre
                      filteredClients.sort((a, b) => a['nombre']
                          .toString()
                          .toLowerCase()
                          .compareTo(b['nombre'].toString().toLowerCase()));

                      return ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          final clientId = client['id'].toString();
                          final cartera = client['cartera'];
                          final clientName = client['nombre'];

                          // Determinar el ícono de flecha según el valor de la cartera
                          final Widget? arrowIcon;
                          if (cartera > 0) {
                            arrowIcon =
                                Icon(Icons.arrow_upward, color: Colors.green);
                          } else if (cartera < 0) {
                            arrowIcon =
                                Icon(Icons.arrow_downward, color: Colors.red);
                          } else {
                            arrowIcon = null;
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              title: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ClientDetail(clientId: clientId),
                                    ),
                                  );
                                },
                                child: Text(
                                  clientName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (arrowIcon != null)
                                    arrowIcon, // Solo mostrar si no es nulo
                                  if (arrowIcon != null) SizedBox(width: 8.0),
                                  IconButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditClient(clientId: clientId)),
                                      );

                                      if (result == true) {
                                        loadStream();
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      bool confirmarEliminacion =
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20.0)),
                                                    side: BorderSide(
                                                      color: Colors.blue[900]!,
                                                      width: 5.0,
                                                    ),
                                                  ),
                                                  title: Center(
                                                    child: Text(
                                                      "Eliminar cliente",
                                                      style: TextStyle(
                                                        fontSize:
                                                            20.0, // Ajusta el tamaño según sea necesario
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue[900],
                                                      ),
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          "¿Seguro que quieres eliminar este cliente?",
                                                          style: TextStyle(
                                                            fontSize:
                                                                16.0, // Ajusta el tamaño según sea necesario
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextButton(
                                                            child: Text(
                                                              "Cancelar",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue[900],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              "Confirmar",
                                                              style: TextStyle(
                                                                color: Colors
                                                                        .yellow[
                                                                    600],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all<
                                                                          Color>(
                                                                Colors
                                                                    .blue[900]!,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });

                                      if (confirmarEliminacion == true) {
                                        bool eliminado =
                                            await _deleteClient(clientId);
                                      }
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterClient()),
              );

              if (result == true) {
                loadStream();
                setState(() {});
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.yellow[600],
          ),
        );
      },
    );
  }

  Future<bool> _deleteClient(String clientId) async {
    try {
      await Supabase.instance.client
          .from('clientes')
          .delete()
          .eq('id', clientId);

      loadStream();
      setState(() {});

      return true;
    } catch (e) {
      return false;
    }
  }
}
*/