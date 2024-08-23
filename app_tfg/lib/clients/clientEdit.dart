import 'package:flutter/material.dart';
import '../utils/common.dart';

class EditClient extends StatefulWidget {
  final String clientId;

  EditClient({required this.clientId});

  @override
  _EditarDatosScreenState createState() => _EditarDatosScreenState();
}

class _EditarDatosScreenState extends State<EditClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController moneyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClientData(widget.clientId);
  }

  Future<void> _loadClientData(String clientId) async {
    final clientData =
        await client.from('clientes').select().eq('id', clientId).single();

    setState(() {
      nameController.text = clientData['nombre'] ?? '';
      phoneController.text = clientData['telefono'] ?? '';
      commentsController.text = clientData['comentario'] ?? '';
      moneyController.text =
          (clientData['cartera'] ?? '0.00').toStringAsFixed(2);
    });
  }

  // Regex para validar el formato del número de teléfono
  static final RegExp phoneRegex = RegExp(
    r'^(\+[0-9]{2})?(\s?[0-9]{3}\s?){3}$',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar datos del cliente',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20.0),
                Text(
                  'Editar cliente',
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 25.0),
                Container(
                  width: 400.0, // Ajusta el ancho del TextField
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'El campo de nombre no puede estar vacío';
                      }
                      return null;
                    },
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: 400.0, // Ajusta el ancho del TextField
                  child: TextFormField(
                    controller: phoneController,
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Formato de teléfono inválido';
                        }
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Número de teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: 400.0, // Ajusta el ancho del TextField
                  child: TextFormField(
                    controller: commentsController,
                    decoration: const InputDecoration(
                      labelText: 'Comentario',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: 400.0, // Ajusta el ancho del TextField
                  child: TextFormField(
                    controller: moneyController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monedero (€)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'El campo de monedero no puede estar vacío';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor, introduzca un número válido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 32.0),
                Center(
                  child: SizedBox(
                    width: 200, // Establece el ancho del botón
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Validación pasada, proceder con la lógica de añadir cliente

                          double money = double.parse(moneyController.text);
                          money = double.parse(money.toStringAsFixed(2));

                          bool success = await _editClient(
                            widget.clientId,
                            nameController.text,
                            phoneController.text,
                            commentsController.text,
                            money,
                          );

                          Navigator.pop(context, true);

                          // Limpiar los campos después de añadir el cliente
                          nameController.clear();
                          phoneController.clear();
                          commentsController.clear();
                          moneyController.clear();
                        }
                      },
                      child: Text(
                        "Editar cliente",
                        style: TextStyle(
                          color: Colors.yellow[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue[900]!,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _editClient(String clientId, String name, String phone,
    String comments, double money) async {
  try {
    await client.from('clientes').update({
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
