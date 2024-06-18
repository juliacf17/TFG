import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/common.dart';
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

  @override
  void initState() {
    super.initState();
    clientStream = client.from('clientes').stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
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
              child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: clientStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final clients = snapshot.data!;
                    final searchQuery = _searchController.text.toLowerCase();

                    // Filtrar clientes si el campo de búsqueda no está vacío
                    final filteredClients = searchQuery.isNotEmpty
                        ? clients.where((client) {
                            final clientName = client['nombre'].toLowerCase();
                            return clientName.contains(searchQuery);
                          }).toList()
                        : clients;

                    return ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, index) {
                          final client = filteredClients[index];
                          final clientId = client['id'].toString();

                          return ListTile(
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
                              child: Text(client['nombre']),
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

                                    // Actualizar el stream si se registró un nuevo cliente
                                    if (result == true) {
                                      clientStream = Supabase.instance.client
                                          .from('clientes')
                                          .stream(primaryKey: ['id']);

                                      setState(() {
                                        // Forzar la reconstrucción del widget con el nuevo stream
                                      });
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

  /* Future<bool> _editClient(String clientId, String name, String phone,
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
  }*/

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
