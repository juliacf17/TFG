import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/common.dart';
import 'newArticle.dart';
import 'editArticle.dart';

class ArticleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantalla de Artículos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ArticleScreen(),
    );
  }
}

class ArticleScreen extends StatefulWidget {
  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? articleStream;

  @override
  void initState() {
    super.initState();
    articleStream = client.from('articulos').stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuestros Artículos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 15.0),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: articleStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final articles = snapshot.data!;
                  final searchQuery = _searchController.text.toLowerCase();

                  // Filtrar artículos según la búsqueda
                  final filteredArticles = articles.where((article) {
                    final articleName = article['nombre'].toLowerCase();
                    final matchesSearchQuery =
                        articleName.contains(searchQuery);

                    return matchesSearchQuery;
                  }).toList();

                  // Ordenar los artículos por nombre
                  filteredArticles.sort((a, b) => a['nombre']
                      .toString()
                      .toLowerCase()
                      .compareTo(b['nombre'].toString().toLowerCase()));

                  return ListView.builder(
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];
                      final articleId = article['id'].toString();
                      final articleName = article['nombre'];
                      final articleCantidad = article['cantidad'].toString();
                      final articlePrecio = article['precio'].toString();

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 2.0),
                        child: ListTile(
                          title: GestureDetector(
                            onTap: () {
                              //AÑADIR ARTICLES DETAIL
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  articleName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5.0),
                                Text('Cantidad: $articleCantidad'),
                                Text('Precio: \$ $articlePrecio'),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  /*final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditArticle(
                                        articleId: articleId,
                                      ),
                                    ),
                                  );

                                  // Actualizar el stream si se editó el artículo
                                  if (result == true) {
                                    articleStream = client
                                        .from('articulos')
                                        .stream(primaryKey: ['id']);

                                    setState(() {
                                      // Forzar la reconstrucción del widget con el nuevo stream
                                    });
                                  }*/
                                },
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () async {
                                  bool confirmarEliminacion = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Center(
                                            child: Text("Eliminar artículo")),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                                child: Text(
                                                    "¿Seguro que quieres eliminar este artículo?")),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(
                                                  child: Text("Cancelar"),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("Confirmar"),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmarEliminacion == true) {
                                    bool eliminado =
                                        await _deleteArticle(articleId);
                                    if (eliminado) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Artículo eliminado correctamente'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Error al eliminar el artículo'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /*final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewArticle()),
          );

          // Actualizar el stream si se añadió un nuevo artículo
          if (result == true) {
            articleStream = client.from('articulos').stream(primaryKey: ['id']);
            setState(() {
              // Forzar la reconstrucción del widget con el nuevo stream
            });
          }*/
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<bool> _deleteArticle(String articleId) async {
    try {
      await client.from('articulos').delete().eq('id', articleId);

      articleStream = client.from('articulos').stream(primaryKey: ['id']);
      setState(
          () {}); // Asegurar que el widget se reconstruya con el nuevo stream

      return true;
    } catch (e) {
      return false;
    }
  }
}
