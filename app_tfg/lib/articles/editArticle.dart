import 'package:flutter/material.dart';
import '../utils/common.dart';

class EditArticleScreen extends StatefulWidget {
  final String categoryId;
  final List<String> existingSubcategories;
  final String articleId;

  EditArticleScreen({
    required this.categoryId,
    required this.existingSubcategories,
    required this.articleId,
  });

  @override
  _EditArticleScreenState createState() => _EditArticleScreenState();
}

class _EditArticleScreenState extends State<EditArticleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController subcategoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dimensionController = TextEditingController();
  final TextEditingController materialController = TextEditingController();

  List<TextEditingController> sizeControllers = [];
  List<TextEditingController> colorControllers = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> minQuantityControllers = [];

  bool showDescription = false;
  bool showDimension = false;
  bool showGender = false;
  bool showMaterial = false;

  String? selectedGender;
  List<Map<String, dynamic>> tallasData = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
    _fetchArticleDetails();
  }

  Future<void> _fetchCategoryDetails() async {
    final data = await client
        .from('categorias')
        .select()
        .eq('id', widget.categoryId)
        .single();

    setState(() {
      showDescription = data['tieneDescripcion'] ?? false;
      showDimension = data['tieneTamanio'] ?? false;
      showGender = data['tieneGenero'] ?? false;
      showMaterial = data['tieneMaterial'] ?? false;
    });
  }

  Future<void> _fetchArticleDetails() async {
    final articleData = await client
        .from('articulos')
        .select()
        .eq('id', widget.articleId)
        .single();

    setState(() {
      nameController.text = articleData['nombre'] ?? '';
      priceController.text = (articleData['precio'] ?? 0.0).toString();
      subcategoryController.text = articleData['subcategoria'] ?? '';
      descriptionController.text = articleData['descripcion'] ?? '';
      dimensionController.text = articleData['tamanio'] ?? '';
      materialController.text = articleData['material'] ?? '';
      selectedGender = articleData['genero'] ?? '';

      // Fetch tallas associated with the article
      _fetchTallas();
    });
  }

  Future<void> _fetchTallas() async {
    final tallas = await client
        .from('tallas')
        .select()
        .eq('articuloId', widget.articleId); //Le he quitado un toList()

    setState(() {
      tallasData = List<Map<String, dynamic>>.from(tallas);
      _initializeSizeControllers();
    });
  }

  void _initializeSizeControllers() {
    sizeControllers = [];
    colorControllers = [];
    quantityControllers = [];
    minQuantityControllers = [];

    for (int i = 0; i < tallasData.length; i++) {
      sizeControllers.add(TextEditingController(text: tallasData[i]['talla']));
      colorControllers.add(TextEditingController(text: tallasData[i]['color']));
      quantityControllers.add(TextEditingController(
          text: tallasData[i]['cantidadActual'].toString()));
      minQuantityControllers.add(TextEditingController(
          text: tallasData[i]['cantidadMinima'].toString()));
    }
  }

  void _addSizeRow() {
    setState(() {
      sizeControllers.add(TextEditingController());
      colorControllers.add(TextEditingController());
      quantityControllers.add(TextEditingController());
      minQuantityControllers.add(TextEditingController());
    });
  }

  void _removeSizeRow(int index) {
    setState(() {
      sizeControllers.removeAt(index);
      colorControllers.removeAt(index);
      quantityControllers.removeAt(index);
      minQuantityControllers.removeAt(index);
    });
  }

  Future<bool> _updateArticle() async {
    try {
      final updatedArticle = {
        'nombre': nameController.text,
        'precio': double.parse(priceController.text),
        'subcategoria': subcategoryController.text,
        'descripcion': descriptionController.text,
        'tamanio': dimensionController.text,
        'genero': selectedGender,
        'material': materialController.text,
      };

      await client
          .from('articulos')
          .update(updatedArticle)
          .eq('id', widget.articleId);

      // Update tallas
      for (int i = 0; i < sizeControllers.length; i++) {
        final updatedTalla = {
          'talla': sizeControllers[i].text.trim(),
          'color': colorControllers[i].text.trim(),
          'cantidadActual': int.parse(quantityControllers[i].text.trim()),
          'cantidadMinima': int.parse(minQuantityControllers[i].text.trim()),
        };

        if (i < tallasData.length) {
          // Existing tallas: Update
          await client
              .from('tallas')
              .update(updatedTalla)
              .eq('id', tallasData[i]['id']);
        } else {
          // New tallas: Insert
          await client.from('tallas').insert({
            ...updatedTalla,
            'articuloId': widget.articleId,
          });
        }
      }

      // Delete removed tallas
      final removedIndexes = List.generate(tallasData.length, (index) => index)
          .where((index) => index >= sizeControllers.length)
          .toList();

      for (int index in removedIndexes) {
        await client.from('tallas').delete().eq('id', tallasData[index]['id']);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Artículo', style: TextStyle(fontSize: 24.0)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 24.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 200.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'El campo de nombre no puede estar vacío';
                        }
                        return null;
                      },
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 200.0),
                    child: TextFormField(
                      controller: priceController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'El campo de precio no puede estar vacío';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, introduzca un número válido';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 200.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: subcategoryController.text.isEmpty
                                ? null
                                : subcategoryController.text,
                            items: [
                              DropdownMenuItem(
                                value: '', // Valor vacío para deseleccionar
                                child: Text('Dejar blanco'),
                              ),
                              ...widget.existingSubcategories
                                  .map((subcategory) => DropdownMenuItem(
                                        value: subcategory,
                                        child: Text(subcategory),
                                      )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                subcategoryController.text = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Subcategoría',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            enabled: subcategoryController.text.isEmpty,
                            controller: subcategoryController,
                            decoration: InputDecoration(
                              labelText: 'Nueva Subcategoría',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: subcategoryController.text.isEmpty
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: subcategoryController.text.isEmpty
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showGender,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 200.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            items: ['Femenino', 'Masculino', 'Unisex']
                                .map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedGender = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Género',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, seleccione un género';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showMaterial,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 200.0),
                          child: TextFormField(
                            controller: materialController,
                            decoration: InputDecoration(
                              labelText: 'Material',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showDimension,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 200.0),
                          child: TextFormField(
                            controller: dimensionController,
                            decoration: InputDecoration(
                              labelText: 'Dimensiones',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showDescription,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 200.0),
                          child: TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 200.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sizeControllers.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: sizeControllers[index],
                                    decoration: const InputDecoration(
                                      labelText: 'Talla',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'No puede estar vacío';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: TextFormField(
                                    controller: colorControllers[index],
                                    decoration: const InputDecoration(
                                      labelText: 'Color',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'No puede estar vacío';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: TextFormField(
                                    controller: quantityControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Cantidad Actual',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'No puede estar vacío';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Número entero válido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: TextFormField(
                                    controller: minQuantityControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Cantidad Mínima',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'No puede estar vacío';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Número entero válido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => _removeSizeRow(index),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    8.0), // Espacio de 8 unidades entre filas
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextButton(
                    onPressed: _addSizeRow,
                    child: Text('Agregar otra talla'),
                  ),
                  SizedBox(height: 32.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 200.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          double money = double.parse(priceController.text);
                          money = double.parse(money.toStringAsFixed(2));

                          bool success = await _updateArticle();

                          if (success) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Error al actualizar el artículo'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          // Limpiar los campos después de añadir el cliente
                          nameController.clear();
                          priceController.clear();
                          subcategoryController.clear();
                          descriptionController.clear();
                          dimensionController.clear();
                          materialController.clear();
                        }
                      },
                      child: Text('Editar artículo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
