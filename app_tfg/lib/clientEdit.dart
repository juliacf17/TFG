import 'package:flutter/material.dart';
import 'utils/common.dart';

class EditClient extends StatefulWidget {
  final String clientId;

  const EditClient({super.key, required this.clientId});

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
        title: const Text('Editar datos'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Editar cliente',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48.0),
              SizedBox(
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
              const SizedBox(height: 16.0),
              SizedBox(
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
              const SizedBox(height: 16.0),
              SizedBox(
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
              const SizedBox(height: 16.0),
              SizedBox(
                width: 400.0, // Ajusta el ancho del TextField
                child: TextFormField(
                  controller: moneyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 32.0),
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
                        const SnackBar(
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
                child: const Text('Editar cliente'),
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
