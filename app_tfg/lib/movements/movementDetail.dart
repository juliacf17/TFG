import 'package:flutter/material.dart';
import '../utils/common.dart';
import 'package:intl/intl.dart';
import 'viewMovements.dart'; // Importa la pantalla de Movimientos

class DetalleMovimientoScreen extends StatelessWidget {
  final int movimientoId;

  DetalleMovimientoScreen({required this.movimientoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Movimiento'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
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

  Future<void> actualizarCantidadArticulos(
      List<Map<String, dynamic>> items) async {
    for (var item in items) {
      final tallaId = item['tallas']['id'];
      final cantidadDevolver = item['cantidad'];

      final response =
          await client.from('tallas').select().eq('id', tallaId).single();

      final cantidadActual = response['cantidadActual'];

      await client
          .from('tallas')
          .update({'cantidadActual': cantidadActual + cantidadDevolver}).eq(
              'id', tallaId);
    }
  }

  Future<void> devolverTodo({required bool isPrestamo}) async {
    try {
      final movimiento = await fetchMovimiento();
      final items = await fetchItems();

      // Insertar nuevo movimiento de "Devolución"
      final DateTime now = DateTime.now();
      final String formattedDate =
          now.toIso8601String().split('.')[0]; // Truncate milliseconds

      final response = await client
          .from('movimientos')
          .insert({
            'fecha': formattedDate,
            'precioTotal': movimiento['precioTotal'],
            'clienteId': movimiento['clienteId'],
            'metodoPago': movimiento['metodoPago'],
            'tipoMov': 'Devolución',
            'idMovAnterior': movimiento['id'],
            'isPrestamo': isPrestamo,
          })
          .select()
          .single();

      final int newMovimientoId = response['id'];

      // Actualizar el movimiento original para relacionarlo con la devolución
      await client.from('movimientos').update(
          {'idMovAnterior': newMovimientoId}).eq('id', widget.movimientoId);

      // Vincular artículos al nuevo movimiento de "Devolución"
      for (var item in items) {
        await client.from('articulosMov').insert({
          'movimientoId': newMovimientoId,
          'tallasId': item['tallas']['id'],
          'cantidad': item['cantidad'],
          'precioParcial': item['precioParcial'],
        });
      }

      // Actualizar la cantidad de los artículos en la tienda
      await actualizarCantidadArticulos(items);

      // Actualizar la cartera del cliente si es un préstamo
      if (isPrestamo) {
        await actualizarCarteraCliente(
            movimiento['clienteId'], movimiento['precioTotal']);
      }

      print('Devolución completada con éxito');

      // Recargar la pantalla
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetalleMovimientoScreen(
            movimientoId: widget.movimientoId,
          ),
        ),
      );
    } catch (error) {
      print('Error devolviendo todo: $error');
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
              // Parte superior con el tipo de movimiento y los botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      'Tipo de Movimiento: ${movimiento['tipoMov']}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (movimiento['tipoMov'] == 'Préstamo' ||
                      movimiento['tipoMov'] == 'Venta')
                    if (movimiento['idMovAnterior'] == null)
                      Row(
                        children: [
                          if (movimiento['tipoMov'] == 'Venta')
                            ElevatedButton(
                              onPressed: () {
                                // Lógica para devolución parcial
                              },
                              child: Text('Devolución parcial'),
                            ),
                          if (movimiento['tipoMov'] == 'Préstamo')
                            ElevatedButton(
                              onPressed: () {
                                // Lógica para comprar el artículo
                              },
                              child: Text('Comprar'),
                            ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmar devolución'),
                                    content: Text(
                                        '¿Estás seguro de que quieres devolver todos los artículos?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Aceptar'),
                                        onPressed: () {
                                          devolverTodo(
                                              isPrestamo:
                                                  movimiento['tipoMov'] ==
                                                      'Préstamo');
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Devolver todo'),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleMovimientoScreen(
                                movimientoId: movimiento['idMovAnterior'],
                              ),
                            ),
                          );
                        },
                        child: movimiento['tipoMov'] == 'Préstamo' ||
                                movimiento['tipoMov'] == 'Venta'
                            ? Text('Devolución hecha')
                            : Text('Movimiento original'),
                      ),
                  if (movimiento['tipoMov'] == 'Devolución')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleMovimientoScreen(
                              movimientoId: movimiento['idMovAnterior'],
                            ),
                          ),
                        );
                      },
                      child: Text('Movimiento original'),
                    ),
                ],
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
                                'Método: ${movimiento['metodoPago'] ?? 'N/A'}',
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
import 'viewMovements.dart'; // Importa la pantalla de Movimientos

class DetalleMovimientoScreen extends StatelessWidget {
  final int movimientoId;

  DetalleMovimientoScreen({required this.movimientoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Movimiento'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
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

  Future<void> devolverTodo({required bool isPrestamo}) async {
    try {
      final movimiento = await fetchMovimiento();
      final items = await fetchItems();

      // Insertar nuevo movimiento de "Devolución"
      final DateTime now = DateTime.now();
      final String formattedDate =
          now.toIso8601String().split('.')[0]; // Truncate milliseconds

      final response = await client
          .from('movimientos')
          .insert({
            'fecha': formattedDate,
            'precioTotal': movimiento['precioTotal'],
            'clienteId': movimiento['clienteId'],
            'metodoPago': movimiento['metodoPago'],
            'tipoMov': 'Devolución',
            'idMovAnterior': movimiento['id'],
            'isPrestamo': isPrestamo,
          })
          .select()
          .single();

      final int newMovimientoId = response['id'];

      // Actualizar el movimiento original para relacionarlo con la devolución
      await client.from('movimientos').update(
          {'idMovAnterior': newMovimientoId}).eq('id', widget.movimientoId);

      // Vincular artículos al nuevo movimiento de "Devolución"
      for (var item in items) {
        await client.from('articulosMov').insert({
          'movimientoId': newMovimientoId,
          'tallasId': item['tallas']['id'],
          'cantidad': item['cantidad'],
          'precioParcial': item['precioParcial'],
        });
      }

      // Actualizar la cartera del cliente si es un préstamo
      if (isPrestamo) {
        await actualizarCarteraCliente(
            movimiento['clienteId'], movimiento['precioTotal']);
      }

      print('Devolución completada con éxito');

      // Recargar la pantalla
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetalleMovimientoScreen(
            movimientoId: widget.movimientoId,
          ),
        ),
      );
    } catch (error) {
      print('Error devolviendo todo: $error');
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
              // Parte superior con el tipo de movimiento y los botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      'Tipo de Movimiento: ${movimiento['tipoMov']}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (movimiento['tipoMov'] == 'Préstamo' ||
                      movimiento['tipoMov'] == 'Venta')
                    if (movimiento['idMovAnterior'] == null)
                      Row(
                        children: [
                          if (movimiento['tipoMov'] == 'Venta')
                            ElevatedButton(
                              onPressed: () {
                                // Lógica para devolución parcial
                              },
                              child: Text('Devolución parcial'),
                            ),
                          if (movimiento['tipoMov'] == 'Préstamo')
                            ElevatedButton(
                              onPressed: () {
                                // Lógica para comprar el artículo
                              },
                              child: Text('Comprar'),
                            ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmar devolución'),
                                    content: Text(
                                        '¿Estás seguro de que quieres devolver todos los artículos?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Aceptar'),
                                        onPressed: () {
                                          devolverTodo(
                                              isPrestamo:
                                                  movimiento['tipoMov'] ==
                                                      'Préstamo');
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Devolver todo'),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleMovimientoScreen(
                                movimientoId: movimiento['idMovAnterior'],
                              ),
                            ),
                          );
                        },
                        child: movimiento['tipoMov'] == 'Préstamo' ||
                                movimiento['tipoMov'] == 'Venta'
                            ? Text('Devolución hecha')
                            : Text('Movimiento original'),
                      ),
                  if (movimiento['tipoMov'] == 'Devolución')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleMovimientoScreen(
                              movimientoId: movimiento['idMovAnterior'],
                            ),
                          ),
                        );
                      },
                      child: Text('Movimiento original'),
                    ),
                ],
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
                                'Método: ${movimiento['metodoPago'] ?? 'N/A'}',
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
}*/
