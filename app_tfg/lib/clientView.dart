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
            /*Expanded(
              child: FutureBuilder(
                future: _fetchClientes(),
                builder: (context, AsyncSnapshot<List<Cliente>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final clientes = snapshot.data!;
                  return ListView.builder(
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      return Card(
                        child: ListTile(
                          title: Text('${cliente.nombre} ${cliente.apellidos}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  // Acción para editar
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteCliente(cliente.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),*/
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

  Future<void> _deleteCliente(int id) async {
    final response =
        await client.from('clientes').delete().eq('id', id).execute();

    if (response.error != null) {
      throw Exception('Error deleting cliente: ${response.error!.message}');
    }

    setState(() {});
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
