import 'package:flutter/material.dart';
import '../utils/common.dart';
import 'movementDetail.dart';
import 'package:intl/intl.dart';

class MovimientosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantalla Movimientos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovimientosView(),
    );
  }
}

class MovimientosView extends StatefulWidget {
  @override
  _MovimientosViewState createState() => _MovimientosViewState();
}

class _MovimientosViewState extends State<MovimientosView> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? movimientosStream;
  Stream<List<Map<String, dynamic>>>? clientesStream;
  String? _selectedTipoMov;
  bool _isSearching = false;
  List<Map<String, dynamic>> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    movimientosStream = client
        .from('movimientos')
        .stream(primaryKey: ['id']).order('fecha', ascending: false);
    clientesStream =
        client.from('clientes').stream(primaryKey: ['id']).order('nombre');
  }

  void _filterMovimientos() {
    setState(() {});
  }

  Future<bool> _deleteMovimiento(int movId) async {
    try {
      // Eliminar artículos relacionados
      await client.from('articulosMov').delete().eq('movimientoId', movId);

      // Eliminar movimiento
      await client.from('movimientos').delete().eq('id', movId);

      movimientosStream = client
          .from('movimientos')
          .stream(primaryKey: ['id']).order('fecha', ascending: false);
      setState(
          () {}); // Asegurar que el widget se reconstruya con el nuevo stream

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> _getClienteNombre(int clienteId) async {
    final response = await client
        .from('clientes')
        .select('nombre')
        .eq('id', clienteId)
        .single();
    return response['nombre'];
  }

  void _fetchClients(String query) async {
    final response =
        await client.from('clientes').select().ilike('nombre', '%$query%');

    setState(() {
      _filteredClients = (response as List)
          .map((client) => {
                'id': client['id'],
                'nombre': client['nombre'],
              })
          .toList();
    });
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('HH:mm:ss dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de Movimientos'),
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
                      labelText: 'Buscar cliente',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _fetchClients(value);
                      _filterMovimientos();
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text('Tipo'),
                  value: _selectedTipoMov,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTipoMov = newValue;
                      _filterMovimientos();
                    });
                  },
                  items: ['Venta', 'Préstamo', 'Devolución'].map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedTipoMov = null;
                      movimientosStream = client.from('movimientos').stream(
                          primaryKey: ['id']).order('fecha', ascending: false);
                    });
                  },
                ),
              ],
            ),
            if (_filteredClients.isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = _filteredClients[index];
                    return ListTile(
                      title: Text(client['nombre']),
                      onTap: () {
                        setState(() {
                          _searchController.text = client['nombre'];
                          _filteredClients.clear();
                          _filterMovimientos();
                        });
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 15.0),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: movimientosStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final movimientos = snapshot.data!;
                  final searchQuery = _searchController.text.toLowerCase();

                  final filteredMovimientos = movimientos.where((movimiento) {
                    final matchesTipo = _selectedTipoMov == null ||
                        movimiento['tipoMov'] == _selectedTipoMov;
                    final matchesCliente = movimiento['clienteId'] != null;
                    return matchesTipo && matchesCliente;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredMovimientos.length,
                    itemBuilder: (context, index) {
                      final movimiento = filteredMovimientos[index];
                      return FutureBuilder<String>(
                        future: _getClienteNombre(movimiento['clienteId']),
                        builder: (context, clienteSnapshot) {
                          if (!clienteSnapshot.hasData) {
                            return ListTile(
                              title: Text('Cargando...'),
                            );
                          }

                          final clienteNombre = clienteSnapshot.data!;
                          if (!clienteNombre
                              .toLowerCase()
                              .contains(searchQuery)) {
                            return Container();
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                  'Fecha: ${_formatDate(movimiento['fecha'])}'),
                              subtitle: Text(
                                  'Tipo: ${movimiento['tipoMov']}, Cliente: $clienteNombre, Precio: \$${movimiento['precioTotal']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Eliminar movimiento"),
                                      content: Text(
                                          "¿Estás seguro de que deseas eliminar este movimiento?"),
                                      actions: [
                                        TextButton(
                                          child: Text("Cancelar"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: Text("Eliminar"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (result == true) {
                                    // Lógica para eliminar movimiento
                                    _deleteMovimiento(movimiento['id']);
                                  }
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalleMovimientoScreen(
                                      movimientoId: movimiento['id'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import '../utils/common.dart';
import 'package:intl/intl.dart';

class MovimientosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantalla Movimientos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MovimientosView(),
    );
  }
}

class MovimientosView extends StatefulWidget {
  @override
  _MovimientosViewState createState() => _MovimientosViewState();
}

class _MovimientosViewState extends State<MovimientosView> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? movimientosStream;
  Stream<List<Map<String, dynamic>>>? clientesStream;
  String? _selectedTipoMov;
  bool _isSearching = false;
  List<Map<String, dynamic>> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    movimientosStream = client
        .from('movimientos')
        .stream(primaryKey: ['id']).order('fecha', ascending: false);
    clientesStream =
        client.from('clientes').stream(primaryKey: ['id']).order('nombre');
  }

  void _filterMovimientos() {
    setState(() {});
  }

  Future<bool> _deleteMovimiento(int movId) async {
    try {
      // Eliminar artículos relacionados
      await client.from('articulosMov').delete().eq('movimientoId', movId);

      // Eliminar movimiento
      await client.from('movimientos').delete().eq('id', movId);

      movimientosStream = client
          .from('movimientos')
          .stream(primaryKey: ['id']).order('fecha', ascending: false);
      setState(
          () {}); // Asegurar que el widget se reconstruya con el nuevo stream

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> _getClienteNombre(int clienteId) async {
    final response = await client
        .from('clientes')
        .select('nombre')
        .eq('id', clienteId)
        .single();
    return response['nombre'];
  }

  void _fetchClients(String query) async {
    final response =
        await client.from('clientes').select().ilike('nombre', '%$query%');

    setState(() {
      _filteredClients = (response as List)
          .map((client) => {
                'id': client['id'],
                'nombre': client['nombre'],
              })
          .toList();
    });
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('HH:mm:ss dd-MM-yyyy');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de Movimientos'),
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
                      labelText: 'Buscar cliente',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _fetchClients(value);
                      _filterMovimientos();
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text('Tipo'),
                  value: _selectedTipoMov,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTipoMov = newValue;
                      _filterMovimientos();
                    });
                  },
                  items: ['Venta', 'Préstamo', 'Devolución'].map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _selectedTipoMov = null;
                      movimientosStream = client.from('movimientos').stream(
                          primaryKey: ['id']).order('fecha', ascending: false);
                    });
                  },
                ),
              ],
            ),
            if (_filteredClients.isNotEmpty)
              Container(
                height: 150,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = _filteredClients[index];
                    return ListTile(
                      title: Text(client['nombre']),
                      onTap: () {
                        setState(() {
                          _searchController.text = client['nombre'];
                          _filteredClients.clear();
                          _filterMovimientos();
                        });
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 15.0),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: movimientosStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final movimientos = snapshot.data!;
                  final searchQuery = _searchController.text.toLowerCase();

                  final filteredMovimientos = movimientos.where((movimiento) {
                    final matchesTipo = _selectedTipoMov == null ||
                        movimiento['tipoMov'] == _selectedTipoMov;
                    final matchesCliente = movimiento['clienteId'] != null;
                    return matchesTipo && matchesCliente;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredMovimientos.length,
                    itemBuilder: (context, index) {
                      final movimiento = filteredMovimientos[index];
                      return FutureBuilder<String>(
                        future: _getClienteNombre(movimiento['clienteId']),
                        builder: (context, clienteSnapshot) {
                          if (!clienteSnapshot.hasData) {
                            return ListTile(
                              title: Text('Cargando...'),
                            );
                          }

                          final clienteNombre = clienteSnapshot.data!;
                          if (!clienteNombre
                              .toLowerCase()
                              .contains(searchQuery)) {
                            return Container();
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                  'Fecha: ${_formatDate(movimiento['fecha'])}'),
                              subtitle: Text(
                                  'Tipo: ${movimiento['tipoMov']}, Cliente: $clienteNombre, Precio: \$${movimiento['precioTotal']}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Eliminar movimiento"),
                                      content: Text(
                                          "¿Estás seguro de que deseas eliminar este movimiento?"),
                                      actions: [
                                        TextButton(
                                          child: Text("Cancelar"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: Text("Eliminar"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (result == true) {
                                    // Lógica para eliminar movimiento
                                    await _deleteMovimiento(movimiento['id']);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

