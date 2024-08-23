import 'package:flutter/material.dart';
import '../utils/common.dart';

import 'newCategory.dart';
import 'editCategory.dart';
import 'articlesView.dart';

class CategoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pantalla Categorías',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[900], // Establece el color primario a blue900
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          //primaryColorDark: Colors.blue[900], // Color primario oscuro a blue900
        ).copyWith(
          primary: Colors.blue[900], // Aplica blue900 como el color primario
          secondary:
              Colors.blue[900], // Establece el color secundario a blue900
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors
              .blue[900], // Cambia el color del cursor en los campos de texto
          selectionColor: Colors.blue[900]
              ?.withOpacity(0.5), // Cambia el color de la selección de texto
          selectionHandleColor:
              Colors.blue[900], // Cambia el color del manejador de selección
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey[600]!), // Borde por defecto
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey[600]!), // Borde cuando no está en foco
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[900]!),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600]!, // Color gris cuando no está enfocado
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.blue[900], // Color azul cuando está enfocado
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blue[900]; // Color azul cuando está seleccionado
              }
              return Colors.white; // Color blanco cuando no está seleccionado
            },
          ),
          checkColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors
                    .white; // El color del checkmark dentro de la casilla
              }
              return Colors.black; // Color del checkmark cuando está vacío
            },
          ),
          side: MaterialStateBorderSide.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return BorderSide(
                    color: Colors
                        .blue[900]!); // Borde azul cuando está seleccionado
              }
              return BorderSide(
                  color: Colors.black); // Borde negro cuando está vacío
            },
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: CategoryScreen(),
    );
  }
}

class CategoryScreen extends StatefulWidget {
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
        title: Text(
          'Categorías de artículos',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        color: Colors.blue[900],
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              category,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.white),
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
                              icon: Icon(Icons.edit, color: Colors.yellow[600]),
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
                                            "Eliminar categoría",
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
                                                "¿Seguro que quieres eliminar esta categoría?",
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
                                                      color: Colors.blue[900],
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
                                                      color: Colors.yellow[600],
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
                                    });

                                if (confirmarEliminacion == true) {
                                  bool eliminado =
                                      await _deleteCategory(categoryId);
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
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
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[600],
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
