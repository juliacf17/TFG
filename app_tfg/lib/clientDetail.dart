import 'package:flutter/material.dart';
import 'utils/common.dart';

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
        title: Text('Visualizar datos'),
      ),
      body: Center(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Visualizar cliente',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 48.0),
              Container(
                width: 400.0, // Ajusta el ancho del TextField
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
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
                  readOnly: true,
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
                  readOnly: true,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 400.0, // Ajusta el ancho del TextField
                child: TextFormField(
                  controller: moneyController,
                  decoration: const InputDecoration(
                    labelText: 'Monedero (€)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
