import 'package:flutter/material.dart';
import '../utils/common.dart';

class ClientDetail extends StatefulWidget {
  final String clientId;

  ClientDetail({required this.clientId});

  @override
  _ViewClientState createState() => _ViewClientState();
}

class _ViewClientState extends State<ClientDetail> {
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
        title: Text(
          'Detalles del cliente',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
      ),
      body: Center(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20.0),
                Text(
                  'Datos del cliente',
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 25.0),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: commentsController,
                  decoration: const InputDecoration(
                    labelText: 'Comentario',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: moneyController,
                  decoration: const InputDecoration(
                    labelText: 'Monedero (€)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
