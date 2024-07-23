import 'package:flutter/material.dart';
import '../utils/common.dart';
import 'package:intl/intl.dart';

class DetalleMovimientoScreen extends StatelessWidget {
  final int movimientoId;

  DetalleMovimientoScreen({required this.movimientoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Movimiento'),
      ),
      body: DetalleMovimientoView(movimientoId: movimientoId),
    );
  }
}

class DetalleMovimientoView extends StatefulWidget {
  final int movimientoId;

  DetalleMovimientoView({required this.movimientoId});

  @override
  _DetalleMovimientoViewState createState() => _DetalleMovimientoViewState();
}

class _DetalleMovimientoViewState extends State<DetalleMovimientoView> {
  Future<Map<String, dynamic>> fetchMovimiento() async {
    try {
      final response = await client
          .from('movimientos')
          .select()
          .eq('id', widget.movimientoId)
          .single();
      print('Movimiento fetched: $response');
      return response;
    } catch (error) {
      print('Error fetching movimiento: $error');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final itemsResponse = await client
          .from('articulosMov')
          .select('*, tallas(id, articuloId, talla, color)')
          .eq('movimientoId', widget.movimientoId);
      print('Items fetched: $itemsResponse');
      return itemsResponse as List<Map<String, dynamic>>;
    } catch (error) {
      print('Error fetching items: $error');
      return [];
    }
  }

  Future<String> getClienteNombre(int clienteId) async {
    try {
      final response = await client
          .from('clientes')
          .select('nombre')
          .eq('id', clienteId)
          .single();
      print('Cliente nombre fetched: $response');
      return response['nombre'];
    } catch (error) {
      print('Error fetching cliente nombre: $error');
      return 'Cliente desconocido';
    }
  }

  Future<String> getArticuloNombre(int articuloId) async {
    try {
      final response = await client
          .from('articulos')
          .select('nombre')
          .eq('id', articuloId)
          .single();
      print('Articulo nombre fetched: $response');
      return response['nombre'];
    } catch (error) {
      print('Error fetching articulo nombre: $error');
      return 'Articulo desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchMovimiento(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('FutureBuilder waiting for data...');
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('FutureBuilder error: ${snapshot.error}');
          return Center(child: Text('Error al cargar los datos'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('FutureBuilder has no data');
          return Center(child: Text('No se encontró el movimiento'));
        }

        final movimiento = snapshot.data!;
        print('Movimiento data: $movimiento');

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parte superior con el tipo de movimiento
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  'Tipo de Movimiento: ${movimiento['tipoMov']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),

              // Parte central con la lista de artículos
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchItems(),
                  builder: (context, itemsSnapshot) {
                    if (itemsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      print('FutureBuilder waiting for items data...');
                      return Center(child: CircularProgressIndicator());
                    }

                    if (itemsSnapshot.hasError) {
                      print(
                          'FutureBuilder error fetching items: ${itemsSnapshot.error}');
                      return Center(
                          child: Text(
                              'Error al cargar los datos de los artículos'));
                    }

                    final items = itemsSnapshot.data ?? [];
                    print('Items data: $items');

                    return SingleChildScrollView(
                      child: Column(
                        children: items.map((item) {
                          final talla = item['tallas'];
                          return FutureBuilder<String>(
                            future: getArticuloNombre(talla['articuloId']),
                            builder: (context, articuloSnapshot) {
                              if (articuloSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (articuloSnapshot.hasError) {
                                print(
                                    'FutureBuilder error fetching articulo: ${articuloSnapshot.error}');
                                return Center(
                                    child: Text(
                                        'Error al cargar el nombre del artículo'));
                              }

                              final articuloNombre = articuloSnapshot.data ??
                                  'Artículo desconocido';
                              print('Artículo data: $articuloNombre');

                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text('Artículo: $articuloNombre'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Talla: ${talla['talla']}'),
                                      Text('Color: ${talla['color']}'),
                                      Text('Cantidad: ${item['cantidad']}'),
                                    ],
                                  ),
                                  trailing: Text('\$${item['precioParcial']}'),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),

              // Parte inferior con la información del cliente, fecha, método y precio total
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: FutureBuilder<String>(
                  future: getClienteNombre(movimiento['clienteId']),
                  builder: (context, clienteSnapshot) {
                    if (clienteSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      print('FutureBuilder waiting for cliente data...');
                      return Center(child: CircularProgressIndicator());
                    }

                    if (clienteSnapshot.hasError) {
                      print(
                          'FutureBuilder error fetching cliente: ${clienteSnapshot.error}');
                      return Center(
                          child: Text('Error al cargar el nombre del cliente'));
                    }

                    final clienteNombre =
                        clienteSnapshot.data ?? 'Cliente desconocido';
                    print('Cliente data: $clienteNombre');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Cliente: $clienteNombre',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Fecha: ${_formatDate(movimiento['fecha'])}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Método: ${movimiento['metodoPago'] ?? 'No pagado'}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Precio Total: \$${movimiento['precioTotal']}',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('HH:mm:ss dd/MM/yyyy');
    return formatter.format(parsedDate);
  }
}

/*import 'package:flutter/material.dart';
import '../utils/common.dart';
import 'package:intl/intl.dart';

class DetalleMovimientoScreen extends StatelessWidget {
  final int movimientoId;

  DetalleMovimientoScreen({required this.movimientoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Movimiento'),
      ),
      body: DetalleMovimientoView(movimientoId: movimientoId),
    );
  }
}

class DetalleMovimientoView extends StatefulWidget {
  final int movimientoId;

  DetalleMovimientoView({required this.movimientoId});

  @override
  _DetalleMovimientoViewState createState() => _DetalleMovimientoViewState();
}

class _DetalleMovimientoViewState extends State<DetalleMovimientoView> {
  Future<Map<String, dynamic>> fetchMovimiento() async {
    try {
      final response = await client
          .from('movimientos')
          .select()
          .eq('id', widget.movimientoId)
          .single();
      print('Movimiento fetched: $response');
      return response;
    } catch (error) {
      print('Error fetching movimiento: $error');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final itemsResponse = await client
          .from('articulosMov')
          .select('*, tallas(id, articuloId, talla, color)')
          .eq('movimientoId', widget.movimientoId);
      print('Items fetched: $itemsResponse');
      return itemsResponse as List<Map<String, dynamic>>;
    } catch (error) {
      print('Error fetching items: $error');
      return [];
    }
  }

  Future<String> getClienteNombre(int clienteId) async {
    try {
      final response = await client
          .from('clientes')
          .select('nombre')
          .eq('id', clienteId)
          .single();
      print('Cliente nombre fetched: $response');
      return response['nombre'];
    } catch (error) {
      print('Error fetching cliente nombre: $error');
      return 'Cliente desconocido';
    }
  }

  Future<String> getArticuloNombre(int articuloId) async {
    try {
      final response = await client
          .from('articulos')
          .select('nombre')
          .eq('id', articuloId)
          .single();
      print('Articulo nombre fetched: $response');
      return response['nombre'];
    } catch (error) {
      print('Error fetching articulo nombre: $error');
      return 'Articulo desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchMovimiento(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('FutureBuilder waiting for data...');
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('FutureBuilder error: ${snapshot.error}');
          return Center(child: Text('Error al cargar los datos'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('FutureBuilder has no data');
          return Center(child: Text('No se encontró el movimiento'));
        }

        final movimiento = snapshot.data!;
        print('Movimiento data: $movimiento');

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo de Movimiento: ${movimiento['tipoMov']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<String>(
                future: getClienteNombre(movimiento['clienteId']),
                builder: (context, clienteSnapshot) {
                  if (clienteSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    print('FutureBuilder waiting for cliente data...');
                    return Center(child: CircularProgressIndicator());
                  }

                  if (clienteSnapshot.hasError) {
                    print(
                        'FutureBuilder error fetching cliente: ${clienteSnapshot.error}');
                    return Center(
                        child: Text('Error al cargar el nombre del cliente'));
                  }

                  final clienteNombre =
                      clienteSnapshot.data ?? 'Cliente desconocido';
                  print('Cliente data: $clienteNombre');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente: $clienteNombre',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Fecha: ${_formatDate(movimiento['fecha'])}',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Método: ${movimiento['metodoPago'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Precio Total: \$${movimiento['precioTotal']}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchItems(),
                  builder: (context, itemsSnapshot) {
                    if (itemsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      print('FutureBuilder waiting for items data...');
                      return Center(child: CircularProgressIndicator());
                    }

                    if (itemsSnapshot.hasError) {
                      print(
                          'FutureBuilder error fetching items: ${itemsSnapshot.error}');
                      return Center(
                          child: Text(
                              'Error al cargar los datos de los artículos'));
                    }

                    final items = itemsSnapshot.data ?? [];
                    print('Items data: $items');

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final talla = item['tallas'];
                        return FutureBuilder<String>(
                          future: getArticuloNombre(talla['articuloId']),
                          builder: (context, articuloSnapshot) {
                            if (articuloSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (articuloSnapshot.hasError) {
                              print(
                                  'FutureBuilder error fetching articulo: ${articuloSnapshot.error}');
                              return Center(
                                  child: Text(
                                      'Error al cargar el nombre del artículo'));
                            }

                            final articuloNombre =
                                articuloSnapshot.data ?? 'Artículo desconocido';
                            print('Artículo data: $articuloNombre');

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text('Artículo: $articuloNombre'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Talla: ${talla['talla']}'),
                                    Text('Color: ${talla['color']}'),
                                    Text('Cantidad: ${item['cantidad']}'),
                                  ],
                                ),
                                trailing: Text('\$${item['precioParcial']}'),
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
        );
      },
    );
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('HH:mm:ss dd/MM/yyyy');
    return formatter.format(parsedDate);
  }
}
*/
