import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/common.dart';

class RegisterClient extends StatefulWidget {
  @override
  _RegisterClientState createState() => _RegisterClientState();
}

class _RegisterClientState extends State<RegisterClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar cliente', style: TextStyle(fontSize: 24.0)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Registrar cliente',
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
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Validación pasada, proceder con la lógica de añadir cliente
                    final String name = nameController.text;
                    final String phone = phoneController.text;
                    final String comments = commentsController.text;

                    bool success =
                        await _addClientToDatabase(name, phone, comments);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cliente añadido exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al añadir el cliente'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    // Limpiar los campos después de añadir el cliente
                    nameController.clear();
                    phoneController.clear();
                    commentsController.clear();

                    Navigator.pop(
                        context, success); // Volver a la pantalla anterior)
                  }
                },
                child: Text('Añadir cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _addClientToDatabase(
      String name, String phone, String comments) async {
    try {
      await client
          .from('clientes')
          .insert({'nombre': name, 'telefono': phone, 'comentario': comments});
      return true;
    } catch (e) {
      return false;
    }
  }
}
