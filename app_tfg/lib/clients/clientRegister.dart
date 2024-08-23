import 'package:flutter/material.dart';
import '../utils/common.dart';

class RegisterClient extends StatefulWidget {
  @override
  _RegisterClientState createState() => _RegisterClientState();
}

class _RegisterClientState extends State<RegisterClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  // Regex para validar el formato del número de teléfono
  static final RegExp phoneRegex = RegExp(
    r'^(\+[0-9]{2})?(\s?[0-9]{3}\s?){3}$',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Añadir un cliente',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  'Nuevo cliente',
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
                      labelText: 'Nombre y apellidos',
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
                SizedBox(height: 32.0),
                Center(
                  child: SizedBox(
                    width: 200, // Establece el ancho del botón
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Validación pasada, proceder con la lógica de añadir cliente
                          final String name = nameController.text;
                          final String phone = phoneController.text;
                          final String comments = commentsController.text;

                          bool success =
                              await _addClientToDatabase(name, phone, comments);

                          // Limpiar los campos después de añadir el cliente
                          nameController.clear();
                          phoneController.clear();
                          commentsController.clear();

                          Navigator.pop(context,
                              success); // Volver a la pantalla anterior)
                        }
                      },
                      child: Text(
                        "Añadir cliente",
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

  Future<bool> _addClientToDatabase(
      String name, String phone, String comments) async {
    try {
      await client.from('clientes').insert({
        'nombre': name,
        'telefono': phone,
        'comentario': comments,
        'cartera': 0.00
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
