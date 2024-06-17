import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/common.dart';
import 'clientRegister.dart';

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

  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualiza el stream cuando se muestra la pantalla
    clientStream = client.from('clientes').stream(primaryKey: ['id']);
  }*/

  @override
  void initState() {
    super.initState();
    clientStream = client.from('clientes').stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
    //final clientStream = client.from('clientes').stream(primaryKey: ['id']);

    //clientStream = client.from('clientes').stream(primaryKey: ['id']);

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
                  icon: Icon(Icons.attach_money),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              // Es necesario envolver el ListView.builder con Expanded para que no de error
              child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: clientStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final clients = snapshot.data!;

                    return ListView.builder(
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          final clientId = client['id'].toString();

                          return ListTile(
                            title: Text(client['nombre']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // DIRIGIR A PÁGINA DE EDITAR CLIENTE
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
                                                          child:
                                                              Text("Cancelar"),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child:
                                                              Text("Confirmar"),
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
                          );
                        });
                  }),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterClient()),
                );

                // Actualizar el stream si se registró un nuevo cliente
                if (result == true) {
                  clientStream =
                      client.from('clientes').stream(primaryKey: ['id']);
                  setState(() {
                    // Forzar la reconstrucción del widget con el nuevo stream
                  });
                }
              },
              child: Text('Nuevo cliente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _editClient(String clientId, String name, String phone,
      String comments, String money) async {
    try {
      await Supabase.instance.client.from('clientes').update({
        'nombre': name,
        'telefono': phone,
        'comentario': comments,
        'cartera': money
      }).eq('id', clientId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteClient(String clientId) async {
    try {
      await Supabase.instance.client
          .from('clientes')
          .delete()
          .eq('id', clientId);

      clientStream = client.from('clientes').stream(primaryKey: ['id']);
      setState(
          () {}); // Asegurar que el widget se reconstruya con el nuevo stream

      return true;
    } catch (e) {
      return false;
    }
  }
}



/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/common.dart';
import 'clientRegister.dart';

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

  @override
  Widget build(BuildContext context) {
    final clientStream = client.from('clientes').stream(primaryKey: ['id']);

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
                  icon: Icon(Icons.attach_money),
                  onPressed: () {},
                ),
              ],
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
                stream: clientStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final clients = snapshot.data!;

                  return ListView.builder(
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        final clientId =
                            client['id'].toString(); //FALTA UN TOSTRING

                        return ListTile(
                          title: Text(client['nombre']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  //DIRIGIR A PÁGINA DE EDITAR CLIENTE
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  bool confirmarEliminacion = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Center(
                                              child: Text("Eliminar cliente")),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
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
                                                    child: Text("Cancelar"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text("Confirmar"),
                                                    onPressed: () {
                                                      Navigator.of(context)
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
                                              backgroundColor: Colors.green));
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
                        );
                      });
                }),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterClient()),
                );
              },
              child: Text('Nuevo cliente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _editClient(int clientId, String name, String phone,
      String comments, String money) async {
    try {
      await client.from('clientes').update({
        'nombre': name,
        'telefono': phone,
        'comentario': comments
      }).eq('id', clientId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteClient(String clientId) async {
    try {
      await client.from('clientes').delete().eq('id', clientId);
      return true;
    } catch (e) {
      return false;
    }
  }

/*
  Future<List<Cliente>> _fetchClientes() async {
    final response = await client
        .from('clientes')
        .select()
        .ilike('nombre', '%${_searchController.text}%')
        .execute();

    if (response.error != null) {
      throw Exception('Error fetching clientes: ${response.error!.message}');
    }

    final List data = response.data as List;
    return data.map((json) => Cliente.fromJson(json)).toList();
  }


}
*/
/*class Cliente {
  final int id;
  final String nombre;
  final String apellidos;

  Cliente({required this.id, required this.nombre, required this.apellidos});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
    );
  }
}*/
}
*/