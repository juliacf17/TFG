import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/common.dart';
import 'newArticle.dart';
import 'editArticle.dart';

class ArticleView extends StatelessWidget {
  final String categoryId;

  ArticleView({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return ArticleScreen(categoryId: categoryId);
  }
}

class ArticleScreen extends StatefulWidget {
  final String categoryId;

  ArticleScreen({required this.categoryId});

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>>? articleStream;
  List<String> uniqueSubcategories = [];

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final articles = await client
        .from('articulos')
        .select()
        .eq('categoriaId', widget.categoryId);

    articleStream = Stream.value(articles);
    setState(() {}); // Actualizar el estado para mostrar los artículos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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

                  // Obtener subcategorías únicas

                  filteredArticles.forEach((article) {
                    final String? subcategoria = article[
                        'subcategoria']; // Asegúrate de que 'subcategoria' exista en tu estructura de datos
                    if (subcategoria != null &&
                        subcategoria.isNotEmpty &&
                        !uniqueSubcategories.contains(subcategoria)) {
                      uniqueSubcategories.add(subcategoria);
                    }
                  });

                  return ListView.builder(
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];
                      final articleId = article['id'].toString();
                      final articleName = article['nombre'];
                      final articleCantidad =
                          article['cantidad_actual'].toString();
                      final articlePrecio =
                          article['precio'].toStringAsFixed(2);

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
                                Text('Precio: $articlePrecio €'),
                                Text('Cantidad: $articleCantidad'),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewArticle(
                      categoryId: widget.categoryId,
                      existingSubcategories: uniqueSubcategories,
                    )),
          );

          if (result == true) {
            fetchArticles(); // Actualiza la lista de artículos después de añadir uno nuevo
          }
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
