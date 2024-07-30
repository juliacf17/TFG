import 'package:flutter/material.dart';
import '../utils/common.dart';

import 'newCategory.dart';
import 'editCategory.dart';
import 'articlesView.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantalla Categorías',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoryScreen(),
    );
  }
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Stream<List<Map<String, dynamic>>>? categoryStream;

  @override
  void initState() {
    super.initState();
    categoryStream = client.from('categorias').stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías de Artículos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: categoryStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Obtener la lista de categorías y ordenarla alfabéticamente
            List<Map<String, dynamic>> categories = snapshot.data!;
            categories.sort((a, b) => (a['nombre'] as String)
                .toLowerCase()
                .compareTo((b['nombre'] as String).toLowerCase()));

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.5,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index]['nombre'];
                final categoryId = categories[index]['id'].toString();

                return GestureDetector(
                  onTap: () {
                    // Navegar a la pantalla de artículos de la categoría
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleView(categoryId: categoryId),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              category,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8.0,
                        right: 8.0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditCategoryScreen(
                                            categoryId: categoryId,
                                          )),
                                );

                                // Actualizar el stream si se registró una nueva categoría
                                if (result == true) {
                                  categoryStream = client
                                      .from('categorias')
                                      .stream(primaryKey: ['id']);
                                  setState(() {
                                    // Forzar la reconstrucción del widget con el nuevo stream
                                  });
                                }
                              },
                            ),
                            IconButton(
                              onPressed: () async {
                                bool confirmarEliminacion = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Center(
                                            child: Text("Eliminar categoría")),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                                child: Text(
                                                    "¿Seguro que quieres eliminar esta categoría?")),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(
                                                  child: const Text("Cancelar"),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child:
                                                      const Text("Confirmar"),
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
                                    });

                                if (confirmarEliminacion == true) {
                                  bool eliminado =
                                      await _deleteCategory(categoryId);
                                  if (eliminado) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Categoría eliminada correctamente'),
                                      backgroundColor: Colors.green,
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Error al eliminar la categoría'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCategoryScreen()),
          );

          // Actualizar el stream si se registró una nueva categoría
          if (result == true) {
            categoryStream =
                client.from('categorias').stream(primaryKey: ['id']);
            setState(() {
              // Forzar la reconstrucción del widget con el nuevo stream
            });
          }
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<bool> _deleteCategory(String categoryId) async {
    try {
      await client.from('categorias').delete().eq('id', categoryId);

      categoryStream = client.from('categorias').stream(primaryKey: ['id']);
      setState(
          () {}); // Asegurar que el widget se reconstruya con el nuevo stream

      return true;
    } catch (e) {
      return false;
    }
  }
}
