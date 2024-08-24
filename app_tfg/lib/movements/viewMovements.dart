import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/common.dart';
import 'movementDetail.dart';
import 'package:intl/intl.dart';
import '../utils/changeNotifier.dart';

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
    loadStreams();
  }

  void loadStreams() {
    movimientosStream = client
        .from('movimientos')
        .stream(primaryKey: ['id']).order('fecha', ascending: false);
    clientesStream =
        client.from('clientes').stream(primaryKey: ['id']).order('nombre');
  }

  void _filterMovimientos() {
    setState(() {});
  }

  Future<void> actualizarCarteraCliente(int clienteId, double monto) async {
    try {
      final cliente =
          await client.from('clientes').select().eq('id', clienteId).single();
      final double carteraActual = cliente['cartera'];
      final double nuevaCartera = carteraActual + monto;

      await client
          .from('clientes')
          .update({'cartera': nuevaCartera}).eq('id', clienteId);

      print('Cartera actualizada: $nuevaCartera');
    } catch (error) {
      print('Error actualizando cartera del cliente: $error');
    }
  }

  Future<bool> _deleteMovimiento(int movId) async {
    try {
      // Verificar si el movimiento tiene un valor de idMovAnterior distinto de NULL
      final response = await client
          .from('movimientos')
          .select('idMovAnterior, clienteId, isPrestamo, precioTotal')
          .eq('id', movId)
          .single();

      if (response['idMovAnterior'] != null) {
        // No se puede eliminar el movimiento si idMovAnterior es distinto de NULL
        return false;
      }

      // Si es un préstamo, actualizar la cartera del cliente
      if (response['isPrestamo'] == true) {
        await actualizarCarteraCliente(
            response['clienteId'], response['precioTotal']);
      }

      // Recuperar los artículos vinculados al movimiento
      final articulosMov = await client
          .from('articulosMov')
          .select('cantidad, tallas(id, cantidadActual)')
          .eq('movimientoId', movId);

      // Actualizar el inventario antes de eliminar los artículos del movimiento
      for (var item in articulosMov) {
        final cantidadNueva =
            (item['tallas']['cantidadActual'] ?? 0) + item['cantidad'];

        // Actualizar cantidadActual en la tabla tallas
        await client.from('tallas').update({
          'cantidadActual': cantidadNueva,
        }).eq('id', item['tallas']['id']);
      }

      // Eliminar los artículos vinculados al movimiento
      await client.from('articulosMov').delete().eq('movimientoId', movId);

      // Eliminar el movimiento
      await client.from('movimientos').delete().eq('id', movId);

      loadStreams();
      setState(() {});

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
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        // Recargar datos cuando se notifique un cambio
        loadStreams();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Nuestros movimientos',
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
                          labelText: 'Buscar cliente',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.search,
                          ),
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
                          loadStreams();
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

                      final filteredMovimientos =
                          movimientos.where((movimiento) {
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
                                margin: EdgeInsets.symmetric(vertical: 6.0),
                                color: Colors.blue[50],
                                child: ListTile(
                                  title: Text(
                                    'Fecha: ${_formatDate(movimiento['fecha'])}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900]!),
                                  ),
                                  subtitle: Text(
                                      'Tipo: ${movimiento['tipoMov']}, Cliente: $clienteNombre, Precio: ${movimiento['precioTotal']}€'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0)),
                                            side: BorderSide(
                                              color: Colors.blue[900]!,
                                              width: 5.0,
                                            ),
                                          ),
                                          title: Center(
                                            child: Text(
                                              "Eliminar movimiento",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          content: Text(
                                            "¿Estás seguro de que deseas eliminar este movimiento?",
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text(
                                                "Cancelar",
                                                style: TextStyle(
                                                  color: Colors.blue[900],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                            ),
                                            TextButton(
                                              child: Text(
                                                "Eliminar",
                                                style: TextStyle(
                                                  color: Colors.yellow[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  Colors.blue[900]!,
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (result == true) {
                                        bool eliminado =
                                            await _deleteMovimiento(
                                                movimiento['id']);

                                        if (!eliminado) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
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
                                                    "Movimiento no eliminado",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                content: Text(
                                                  "No se puede eliminar un movimiento que está vinculado a otro.",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text(
                                                      "Aceptar",
                                                      style: TextStyle(
                                                        color:
                                                            Colors.yellow[600],
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        Colors.blue[900]!,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Cierra el diálogo
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
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
      },
    );
  }
}
