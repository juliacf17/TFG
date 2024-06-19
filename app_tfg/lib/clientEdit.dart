import 'package:flutter/material.dart';
import 'utils/common.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar datos'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Editar cliente',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 48.0),
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
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono',
                    border: OutlineInputBorder(),
                  ),
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              ElevatedButton(
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

                    if (success) {
                      Navigator.pop(context, true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar el cliente'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    // Limpiar los campos después de añadir el cliente
                    nameController.clear();
                    phoneController.clear();
                    commentsController.clear();
                    moneyController.clear();
                  }
                },
                child: Text('Editar cliente'),
              ),
            ],
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
