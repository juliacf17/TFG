import 'package:flutter/material.dart';
import '../utils/common.dart';
import '../utils/changeNotifier.dart';
import 'package:provider/provider.dart';

class NuevaVentaScreen extends StatefulWidget {
  final bool isVenta; // Variable para determinar si es una venta o un préstamo

  NuevaVentaScreen({required this.isVenta});

  @override
  _NuevaVentaScreenState createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _clientSearchController = TextEditingController();
  final List<Map<String, dynamic>> _items = [];

  String? _selectedArticle;
  int _selectedArticleId = 0;
  String? _selectedColor;
  String? _selectedSize;
  String? _selectedClient;
  int _selectedClientId = 0;
  String? _selectedPaymentMethod;
  double _price = 0.0;
  double _partialPrice = 0.0;
  List<Map<String, dynamic>> _filteredArticles = [];
  List<Map<String, dynamic>> _filteredClients = [];
  List<String> _availableSizes = [];
  List<String> _availableColors = [];
  int _currentQuantity = 0;
  bool _isSearching = false;
  bool _isClientSearching = false;

  Future<void> fetchArticles(String query) async {
    setState(() {
      _isSearching = true;
    });

    final response =
        await client.from('articulos').select().ilike('nombre', '%$query%');

    setState(() {
      _filteredArticles = (response as List)
          .map((article) => {
                'id': article['id'],
                'nombre': article['nombre'],
                'precio': article['precio'],
              })
          .toList();
      _isSearching = false;
    });
  }

  Future<void> fetchClients(String query) async {
    setState(() {
      _isClientSearching = true;
    });

    final response =
        await client.from('clientes').select().ilike('nombre', '%$query%');

    setState(() {
      _filteredClients = (response as List)
          .map((client) => {
                'id': client['id'],
                'nombre': client['nombre'],
              })
          .toList();
      _isClientSearching = false;
    });
  }

  Future<void> updateQuantity(int articleId, String size, String color,
      int newQuantity, int currentQuantity) async {
    await client
        .from('tallas')
        .update({'cantidadActual': currentQuantity - newQuantity})
        .eq('articuloId', articleId)
        .eq('talla', size)
        .eq('color', color);
  }

  Future<void> fetchSizesAndColors(int articleId) async {
    final response =
        await client.from('tallas').select().eq('articuloId', articleId);

    setState(() {
      _availableSizes =
          response.map((talla) => talla['talla'].toString()).toSet().toList();
      _availableColors =
          response.map((talla) => talla['color'].toString()).toSet().toList();
    });
  }

  Future<void> fetchCurrentQuantity(
      int articleId, String size, String color) async {
    final response = await client
        .from('tallas')
        .select()
        .eq('articuloId', articleId)
        .eq('talla', size)
        .eq('color', color)
        .single();

    setState(() {
      _currentQuantity = response['cantidadActual'];
    });
  }

  Future<void> insertArticulosMov(int movimientoId) async {
    for (var item in _items) {
      final response = await client
          .from('tallas')
          .select()
          .eq('articuloId', item['id'])
          .eq('talla', item['size'])
          .eq('color', item['color'])
          .single();

      final tallaId = response['id'];
      final cantidad = item['quantity'];
      final precioParcial = item['price'] * item['quantity'];

      await client.from('articulosMov').insert({
        'movimientoId': movimientoId,
        'tallasId': tallaId,
        'cantidad': cantidad,
        'precioParcial': precioParcial,
      });
    }
  }

  Future<void> insertVenta() async {
    final DateTime now = DateTime.now();
    final String formattedDate =
        now.toIso8601String().split('.')[0]; // Truncate milliseconds
    final response = await client
        .from('movimientos')
        .insert({
          'fecha': formattedDate,
          'precioTotal': _calculateTotal(),
          'clienteId': _selectedClientId,
          'metodoPago': _selectedPaymentMethod,
          'tipoMov': 'Venta',
          'idMovAnterior': null,
        })
        .select()
        .single();

    final int movimientoId = response['id'];
    await insertArticulosMov(movimientoId);

    // Notificar a todas las pantallas activas que se ha creado un nuevo movimiento
    Provider.of<RefreshNotifier>(context, listen: false).notifyRefresh();
  }

  Future<void> updateClientCartera(int clienteId, double amount) async {
    try {
      final response = await client
          .from('clientes')
          .select('cartera')
          .eq('id', clienteId)
          .single();

      final double currentCartera = response['cartera'];
      final double updatedCartera = currentCartera - amount;

      await client
          .from('clientes')
          .update({'cartera': updatedCartera}).eq('id', clienteId);

      print('Cartera updated successfully for client $clienteId');
    } catch (error) {
      print('Error updating cartera: $error');
    }
  }

  Future<void> insertPrestamo() async {
    final DateTime now = DateTime.now();
    final String formattedDate =
        now.toIso8601String().split('.')[0]; // Truncate milliseconds
    final response = await client
        .from('movimientos')
        .insert({
          'fecha': formattedDate,
          'precioTotal': _calculateTotal(),
          'clienteId': _selectedClientId,
          'metodoPago': null,
          'tipoMov': 'Préstamo',
          'idMovAnterior': null,
          'isPrestamo': true,
        })
        .select()
        .single();
    final movimientoId = response['id'];
    await insertArticulosMov(movimientoId);

    // Update client's cartera
    await updateClientCartera(_selectedClientId, _calculateTotal());

    // Notificar a todas las pantallas activas que se ha creado un nuevo movimiento
    Provider.of<RefreshNotifier>(context, listen: false).notifyRefresh();
  }

  void _addItem() async {
    if (_selectedArticle != null &&
        _selectedColor != null &&
        _selectedSize != null) {
      await fetchCurrentQuantity(
          _selectedArticleId, _selectedSize!, _selectedColor!);

      if (int.parse(_quantityController.text) <= _currentQuantity) {
        setState(() {
          _items.add({
            'id': _selectedArticleId,
            'article': _selectedArticle,
            'color': _selectedColor,
            'size': _selectedSize,
            'quantity': int.parse(_quantityController.text),
            'price': _price,
          });

          updateQuantity(_selectedArticleId, _selectedSize!, _selectedColor!,
              int.parse(_quantityController.text), _currentQuantity);

          // Reset all fields
          _selectedArticle = null;
          _selectedArticleId = 0;
          _selectedColor = null;
          _selectedSize = null;
          _price = 0.0;
          _partialPrice = 0.0;
          _quantityController.text = '1';
          _availableSizes.clear();
          _availableColors.clear();
        });
      } else {
        // Show an alert if the quantity exceeds the available quantity
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                side: BorderSide(
                    color: Colors.blue[900]!, width: 5.0), // Borde azul 900
              ),
              title: Text(
                "Cantidad no disponible",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                  "La cantidad seleccionada excede la cantidad disponible. Disponible: $_currentQuantity."),
              actions: [
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.yellow[600], // Texto en amarillo
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue[900]!), // Fondo azul 900
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Show an alert if the article, color, or size is not selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              side: BorderSide(
                  color: Colors.blue[900]!, width: 5.0), // Borde azul 900
            ),
            title: Text(
              "Información incompleta",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text("Debes rellenar todos los campos"),
            actions: [
              TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.yellow[600], // Texto en azul 900
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue[900]!), // Fondo azul 900
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double _calculateTotal() {
    return _items.fold(
        0, (total, item) => total + item['price'] * item['quantity']);
  }

  void _calculatePartialPrice() {
    setState(() {
      _partialPrice = _price * int.parse(_quantityController.text);
    });
  }

  void _incrementQuantity() {
    setState(() {
      int currentQuantity = int.parse(_quantityController.text);
      _quantityController.text = (currentQuantity + 1).toString();
      _calculatePartialPrice();
    });
  }

  void _decrementQuantity() {
    setState(() {
      int currentQuantity = int.parse(_quantityController.text);
      if (currentQuantity > 1) {
        _quantityController.text = (currentQuantity - 1).toString();
        _calculatePartialPrice();
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_items.isNotEmpty) {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                side: BorderSide(
                    color: Colors.blue[800]!, width: 5), // Borde azul 900
              ),
              title: Text(
                widget.isVenta
                    ? 'El proceso de venta se finalizará'
                    : 'El proceso de préstamo se finalizará',
                style: TextStyle(
                  fontWeight: FontWeight.bold, // Texto en negrita
                ),
              ),
              content: Text(widget.isVenta
                  ? '¿Estás seguro de que deseas finalizar la venta?'
                  : '¿Estás seguro de que deseas finalizar el préstamo?'),
              actions: [
                TextButton(
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold), // Botón azul 700
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    "Aceptar",
                    style: TextStyle(
                        color: Colors.yellow[600],
                        fontWeight: FontWeight.bold), // Botón azul 900
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue[900]!), // Fondo azul 900
                  ),
                  onPressed: () async {
                    for (var item in List.from(_items)) {
                      await fetchCurrentQuantity(
                          item['id'], item['size']!, item['color']!);

                      updateQuantity(item['id'], item['size'], item['color'],
                          -item['quantity'], _currentQuantity);
                    }

                    setState(() {
                      _items.clear();
                    });

                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          )) ??
          false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isVenta
                ? 'Nueva venta'
                : 'Nuevo préstamo', // Cambia el texto según isVenta
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          foregroundColor: Colors.blue[900],
          backgroundColor: Colors.blue[200],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Buscar artículo',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            fetchArticles(value);
                          },
                        ),
                        if (_isSearching)
                          CircularProgressIndicator()
                        else if (_filteredArticles.isNotEmpty)
                          Container(
                            height: 150,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredArticles.length,
                              itemBuilder: (context, index) {
                                final article = _filteredArticles[index];
                                return ListTile(
                                  title: Text(article['nombre']),
                                  onTap: () {
                                    setState(() {
                                      _selectedArticle = article['nombre'];
                                      _selectedArticleId = article['id'];
                                      _price = article['precio'];
                                      _searchController.text = article[
                                          'nombre']; // Actualiza el texto del buscador
                                      _filteredArticles.clear();
                                      _calculatePartialPrice();
                                      fetchSizesAndColors(article['id']);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    hint: Text('Talla'),
                    value: _selectedSize,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSize = newValue;
                      });
                    },
                    items: _availableSizes.map((size) {
                      return DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    hint: Text('Color'),
                    value: _selectedColor,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedColor = newValue;
                      });
                    },
                    items: _availableColors.map((color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cantidad',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Text('Precio: $_partialPrice€'),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addItem,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.blue[50],
                      child: ListTile(
                        title: Text(
                          item['article'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900]),
                        ),
                        subtitle: Text(
                            'Color: ${item['color']}, Talla: ${item['size']}, Cantidad: ${item['quantity']}'),
                        trailing: Text('${item['price'] * item['quantity']}€'),
                        leading: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await fetchCurrentQuantity(
                                item['id'], item['size']!, item['color']!);

                            updateQuantity(
                                item['id'],
                                item['size'],
                                item['color'],
                                -item['quantity'],
                                _currentQuantity);
                            _removeItem(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        TextField(
                          controller: _clientSearchController,
                          decoration: InputDecoration(
                            labelText: 'Asignar cliente',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            fetchClients(value);
                          },
                        ),
                        if (_isClientSearching)
                          CircularProgressIndicator()
                        else if (_filteredClients.isNotEmpty)
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
                                      _selectedClient = client['nombre'];
                                      _selectedClientId = client['id'];
                                      _clientSearchController.text =
                                          client['nombre'];
                                      _filteredClients.clear();
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Text('Precio total: ${_calculateTotal()}€'),
                  SizedBox(width: 10),
                  Visibility(
                    visible: widget.isVenta,
                    child: DropdownButton<String>(
                      hint: Text('Método'),
                      value: _selectedPaymentMethod,
                      items: <String>['Efectivo', 'Tarjeta'].map((method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (widget.isVenta) {
                        if (_selectedPaymentMethod != null) {
                          await insertVenta();
                          Navigator.of(context).pop(true);
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  side: BorderSide(
                                      color: Colors.blue[900]!,
                                      width: 5.0), // Borde azul 900
                                ),
                                title: Text(
                                  "Método de pago requerido",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                    "Por favor, seleccione un método de pago."),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      "OK",
                                      style: TextStyle(
                                        color: Colors
                                            .yellow[600], // Texto en amarillo
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .blue[900]!), // Fondo azul 900
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        if (_selectedClient != null) {
                          await insertPrestamo();
                          Navigator.of(context).pop(true);
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  side: BorderSide(
                                      color: Colors.blue[900]!,
                                      width: 5.0), // Borde azul 900
                                ),
                                title: Text(
                                  "Cliente requerido",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text("Por favor, asigne un cliente."),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      "OK",
                                      style: TextStyle(
                                        color: Colors
                                            .yellow[600], // Texto en amarillo
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .blue[900]!), // Fondo azul 900
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: Text(
                      'Aceptar',
                      style: TextStyle(
                        color: Colors.yellow[600], // Texto en amarillo
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue[900]!, // Fondo azul
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
