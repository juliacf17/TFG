import 'package:flutter/material.dart';
import '../utils/common.dart';

class StockRenewalScreen extends StatelessWidget {
  final String categoryId;
  final List<Map<String, dynamic>> articles;

  const StockRenewalScreen(
      {super.key, required this.categoryId, required this.articles});

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
        title: const Text('Lista renovación stock'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getLowStockArticles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lowStockArticles = snapshot.data!;

          return ListView.builder(
            itemCount: lowStockArticles.length,
            itemBuilder: (context, index) {
              final article = lowStockArticles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: article['nombre'],
                        decoration: const InputDecoration(
                          labelText: 'Nombre artículo',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['talla'],
                        decoration: const InputDecoration(
                          labelText: 'Talla',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['color'],
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['cantidad_actual'].toString(),
                        decoration: const InputDecoration(
                          labelText: 'Cantidad actual',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: article['cantidad_minima'].toString(),
                        decoration: const InputDecoration(
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
