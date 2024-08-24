import 'package:flutter/material.dart';
import '../utils/common.dart';

class StockRenewalScreen extends StatelessWidget {
  final String categoryId;
  final List<Map<String, dynamic>> articles;

  StockRenewalScreen({required this.categoryId, required this.articles});

  Future<List<Map<String, dynamic>>> getLowStockArticles() async {
    List<Map<String, dynamic>> lowStockArticles = [];

    for (var article in articles) {
      final articleId = article['id'];

      final responseData =
          await client.from('tallas').select().eq('articuloId', articleId);

      //final response = responseData.data as List<Map<String, dynamic>>;

      if (responseData.isNotEmpty) {
        for (var talla in responseData) {
          if (talla['cantidadActual'] <= talla['cantidadMinima']) {
            lowStockArticles.add({
              'nombre': article['nombre'],
              'talla': talla['talla'],
              'color': talla['color'],
              'cantidad_actual': talla['cantidadActual'],
              'cantidad_minima': talla['cantidadMinima'],
            });
          }
        }
      }
    }

    return lowStockArticles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de renovación de stock',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getLowStockArticles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final lowStockArticles = snapshot.data!;

          return ListView.builder(
            itemCount: lowStockArticles.length,
            itemBuilder: (context, index) {
              final article = lowStockArticles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: article['nombre'],
                        decoration: InputDecoration(
                          labelText: 'Nombre artículo',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['talla'],
                        decoration: InputDecoration(
                          labelText: 'Talla',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['color'],
                        decoration: InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['cantidad_actual'].toString(),
                        decoration: InputDecoration(
                          labelText: 'Cantidad actual',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['cantidad_minima'].toString(),
                        decoration: InputDecoration(
                          labelText: 'Cantidad mínima',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
