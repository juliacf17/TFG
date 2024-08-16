import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar provider
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/common.dart';
import '../utils/changeNotifier.dart'; // Importar el RefreshNotifier
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

  Color _getBackgroundColor(double cartera) {
    if (cartera < 0) {
      return Color.fromARGB(242, 219, 88, 88); // Deuda
    } else if (cartera > 0) {
      return Color.fromARGB(255, 78, 201, 105); // Positivo
    } else {
      return Colors.white; // Igual a 0
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        // Recargar el stream cuando se notifique un cambio
        loadStream();

        return Scaffold(
          appBar: AppBar(
            title: Text('Nuestros clientes'),
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
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_money,
                        color: showDebts ? Colors.red : Colors.black,
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

                          return Container(
                            decoration: BoxDecoration(
                              color: _getBackgroundColor(cartera),
                              border:
                                  Border.all(color: Colors.black, width: 1.2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 2.0),
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
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      bool confirmarEliminacion =
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Center(
                                                      child: Text(
                                                          "Eliminar cliente")),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Center(
                                                          child: Text(
                                                              "¿Seguro que quieres eliminar este cliente?")),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          TextButton(
                                                            child: Text(
                                                                "Cancelar"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                                "Confirmar"),
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
                                        if (eliminado) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Cliente eliminado correctamente'),
                                            backgroundColor: Colors.green,
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Error al eliminar el cliente'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
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
            backgroundColor: Colors.blue,
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

import '../utils/common.dart';
import '../utils/changeNotifier.dart'; // Importar el RefreshNotifier
import 'clientRegister.dart';
import 'clientEdit.dart';
import 'clientDetail.dart';

class ClientView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RefreshNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pantalla Clientes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ClienteScreen(),
      ),
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

  Color _getBackgroundColor(double cartera) {
    if (cartera < 0) {
      return Color.fromARGB(242, 219, 88, 88); // Deuda
    } else if (cartera > 0) {
      return Color.fromARGB(255, 78, 201, 105); // Positivo
    } else {
      return Colors.white; // Igual a 0
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        // Recargar el stream cuando se notifique un cambio
        loadStream();

        return Scaffold(
          appBar: AppBar(
            title: Text('Nuestros clientes'),
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
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_money,
                        color: showDebts ? Colors.red : Colors.black,
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

                          return Container(
                            decoration: BoxDecoration(
                              color: _getBackgroundColor(cartera),
                              border:
                                  Border.all(color: Colors.black, width: 1.2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 2.0),
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
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      bool confirmarEliminacion =
                                          await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Center(
                                                      child: Text(
                                                          "Eliminar cliente")),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Center(
                                                          child: Text(
                                                              "¿Seguro que quieres eliminar este cliente?")),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          TextButton(
                                                            child: Text(
                                                                "Cancelar"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                                "Confirmar"),
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
                                        if (eliminado) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Cliente eliminado correctamente'),
                                            backgroundColor: Colors.green,
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text(
                                                'Error al eliminar el cliente'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
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
            backgroundColor: Colors.blue,
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