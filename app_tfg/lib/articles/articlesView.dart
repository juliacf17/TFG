import 'package:flutter/material.dart';

import '../utils/common.dart';
import 'newArticle.dart';
import 'editArticle.dart';
import 'articleDetails.dart';
import 'stock.dart';

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

  String subcategoryFilter = '';
  bool actualizarDesplegable = true;

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

    setState(() {
      articleStream = Stream.value(articles as List<Map<String, dynamic>>);

      articles.forEach((article) {
        final String? subcategoria = article['subcategoria'];
        if (subcategoria != null &&
            subcategoria.isNotEmpty &&
            !uniqueSubcategories.contains(subcategoria)) {
          uniqueSubcategories.add(subcategoria);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic articles;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Nuestros artículos',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        items: [
                          DropdownMenuItem(
                            value: '',
                            child: Text('Dejar blanco'),
                          ),
                          ...uniqueSubcategories
                              .map((subcategory) => DropdownMenuItem(
                                    value: subcategory,
                                    child: Text(subcategory),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            subcategoryFilter = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Subcategoría',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: articleStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      articles = snapshot.data!;
                      final searchQuery = _searchController.text.toLowerCase();

                      final filteredArticles = articles.where((article) {
                        final articleName = article['nombre'].toLowerCase();
                        final matchesSearchQuery =
                            articleName.contains(searchQuery);

                        final articleSubcategory = article['subcategoria'];
                        final matchesSubcategory = subcategoryFilter.isEmpty ||
                            articleSubcategory == subcategoryFilter;

                        return matchesSearchQuery && matchesSubcategory;
                      }).toList();

                      filteredArticles.sort((a, b) => a['nombre']
                          .toString()
                          .toLowerCase()
                          .compareTo(b['nombre'].toString().toLowerCase()));

                      filteredArticles.forEach((article) {
                        final String? subcategoria = article['subcategoria'];
                        if (subcategoria != null &&
                            subcategoria.isNotEmpty &&
                            !uniqueSubcategories.contains(subcategoria)) {
                          uniqueSubcategories.add(subcategoria);
                        }
                      });

                      uniqueSubcategories.sort(
                          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                      return ListView.builder(
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = filteredArticles[index];
                          final articleId = article['id'].toString();
                          final articleName = article['nombre'];
                          final articlePrecio =
                              article['precio'].toStringAsFixed(2);

                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailsScreen(
                                    categoryId: widget.categoryId,
                                    existingSubcategories: uniqueSubcategories,
                                    articleId: articleId,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.blue[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            articleName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[900],
                                                ),
                                          ),
                                          SizedBox(height: 2.0),
                                          Text(
                                            'Precio: $articlePrecio €',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditArticleScreen(
                                                  categoryId: widget.categoryId,
                                                  existingSubcategories:
                                                      uniqueSubcategories,
                                                  articleId: articleId,
                                                ),
                                              ),
                                            );

                                            if (result == true) {
                                              fetchArticles();
                                            }
                                          },
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue[300]),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            bool confirmarEliminacion =
                                                await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20.0)),
                                                    side: BorderSide(
                                                      color: Colors.blue[900]!,
                                                      width: 5.0,
                                                    ),
                                                  ),
                                                  title: Center(
                                                    child: Text(
                                                      "Eliminar artículo",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          "¿Seguro que quieres eliminar este artículo?",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextButton(
                                                            child: Text(
                                                              "Cancelar",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue[900],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              "Confirmar",
                                                              style: TextStyle(
                                                                color: Colors
                                                                        .yellow[
                                                                    600],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all<
                                                                          Color>(
                                                                Colors
                                                                    .blue[900]!,
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
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
                                                  await _deleteArticle(
                                                      articleId);
                                              if (eliminado) {
                                                fetchArticles();
                                              }
                                            }
                                          },
                                          icon: Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              child: Text(
                "Renovar stock",
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue[900]!,
                ),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockRenewalScreen(
                      categoryId: widget.categoryId,
                      articles: articles,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
        backgroundColor: Colors.yellow[600],
      ),
    );
  }

  Future<bool> _deleteArticle(String articleId) async {
    try {
      await client.from('tallas').delete().eq('articuloId', articleId);

      await client.from('articulos').delete().eq('id', articleId);

      setState(() {
        fetchArticles(); // Asegurar que el widget se reconstruya con el nuevo stream
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}


/*import 'package:flutter/material.dart';
import '../utils/common.dart';
import 'newArticle.dart';
import 'editArticle.dart';
import 'articleDetails.dart';
import 'stock.dart';

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

  String subcategoryFilter = '';
  bool actualizarDesplegable = true;

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

    setState(() {
      articleStream = Stream.value(articles as List<Map<String, dynamic>>);

      articles.forEach((article) {
        final String? subcategoria = article[
            'subcategoria']; // Asegúrate de que 'subcategoria' exista en tu estructura de datos
        if (subcategoria != null &&
            subcategoria.isNotEmpty &&
            !uniqueSubcategories.contains(subcategoria)) {
          uniqueSubcategories.add(subcategoria);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic articles;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Nuestros artículos',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(width: 10), // Añadir espacio entre los widgets
                    Flexible(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        items: [
                          DropdownMenuItem(
                            value: '', // Valor vacío para deseleccionar
                            child: Text('Dejar blanco'),
                          ),
                          ...uniqueSubcategories
                              .map((subcategory) => DropdownMenuItem(
                                    value: subcategory,
                                    child: Text(subcategory),
                                  )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            subcategoryFilter = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Subcategoría',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: articleStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      articles = snapshot.data!;
                      final searchQuery = _searchController.text.toLowerCase();

                      // Filtrar artículos según la búsqueda
                      final filteredArticles = articles.where((article) {
                        final articleName = article['nombre'].toLowerCase();
                        final matchesSearchQuery =
                            articleName.contains(searchQuery);

                        final articleSubcategory = article['subcategoria'];
                        final matchesSubcategory = subcategoryFilter.isEmpty ||
                            articleSubcategory == subcategoryFilter;

                        return matchesSearchQuery && matchesSubcategory;
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

                      uniqueSubcategories.sort(
                          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                      return ListView.builder(
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = filteredArticles[index];
                          final articleId = article['id'].toString();
                          final articleName = article['nombre'];
                          final articlePrecio =
                              article['precio'].toStringAsFixed(2);

                          return GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailsScreen(
                                    categoryId: widget.categoryId,
                                    existingSubcategories: uniqueSubcategories,
                                    articleId: articleId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[50], // Fondo azul claro
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      articleName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900]),
                                    ),
                                    SizedBox(height: 1.0),
                                    Text('Precio: $articlePrecio €'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditArticleScreen(
                                              categoryId: widget.categoryId,
                                              existingSubcategories:
                                                  uniqueSubcategories,
                                              articleId: articleId,
                                            ),
                                          ),
                                        );

                                        // Actualizar el stream si se editó el artículo
                                        if (result == true) {
                                          fetchArticles();
                                        }
                                      },
                                      icon: Icon(Icons.edit,
                                          color: Colors.blue[300]),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        bool confirmarEliminacion =
                                            await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                                side: BorderSide(
                                                  color: Colors.blue[900]!,
                                                  width: 5.0,
                                                ),
                                              ),
                                              title: Center(
                                                child: Text(
                                                  "Eliminar artículo",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      "¿Seguro que quieres eliminar este artículo?",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        child: Text(
                                                          "Cancelar",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blue[900],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          "Confirmar",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .yellow[600],
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all<Color>(
                                                            Colors.blue[900]!,
                                                          ),
                                                        ),
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
                                        }
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                      ),
                                    ),
                                  ],
                                ),
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
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              child: Text(
                "Renovar stock",
                style: TextStyle(
                  color: Colors.yellow[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue[900]!,
                ),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockRenewalScreen(
                      categoryId: widget.categoryId,
                      articles: articles,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
        backgroundColor: Colors.yellow[600],
      ),
    );
  }

  Future<bool> _deleteArticle(String articleId) async {
    try {
      await client.from('tallas').delete().eq('articuloId', articleId);

      await client.from('articulos').delete().eq('id', articleId);

      setState(() {
        fetchArticles(); // Asegurar que el widget se reconstruya con el nuevo stream
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
*/