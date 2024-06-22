import 'package:flutter/material.dart';
import '../utils/common.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final String categoryId;
  final List<String> existingSubcategories; // List of existing subcategories
  final String articleId;

  ArticleDetailsScreen({
    required this.categoryId,
    required this.existingSubcategories,
    required this.articleId,
  });

  @override
  _ArticleDetailsScreenState createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minQuantityController = TextEditingController();
  final TextEditingController subcategoryController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dimensionController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  bool showSubcategory = false;
  bool showSize = false;
  bool showColor = false;
  bool showDescription = false;
  bool showDimension = false;
  bool showGender = false;
  bool showMaterial = false;

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
      showSubcategory = data['tieneSubcategoria'] ?? false;
      showSize = data['tieneTalla'] ?? false;
      showColor = data['tieneColor'] ?? false;
      showDescription = data['tieneDescripcion'] ?? false;
      showDimension = data['tieneTamanio'] ?? false;
      showGender = data['tieneGenero'] ?? false;
      showMaterial = data['tieneMaterial'] ?? false;
    });
  }

  Future<void> _fetchArticleDetails() async {
    final data = await client
        .from('articulos')
        .select()
        .eq('id', widget.articleId)
        .single();

    setState(() {
      nameController.text = data['nombre'] ?? '';
      priceController.text = (data['precio'] ?? 0.00).toStringAsFixed(2);
      quantityController.text = (data['cantidad_actual'] ?? 0).toString();
      minQuantityController.text = (data['cantidad_minima'] ?? 0).toString();
      subcategoryController.text = data['subcategoria'] ?? '';
      sizeController.text = data['talla'] ?? '';
      colorController.text = data['color'] ?? '';
      descriptionController.text = data['descripcion'] ?? '';
      dimensionController.text = data['tamanio'] ?? '';
      materialController.text = data['material'] ?? '';
      genderController.text = data['genero'] ?? '';
    });
  }

  Future<bool> _updateArticle() async {
    try {
      double money = double.parse(priceController.text);
      money = double.parse(money.toStringAsFixed(2));

      final updateArticle = {
        'nombre': nameController.text,
        'precio': money,
        'cantidad_actual': quantityController.text,
        'cantidad_minima': minQuantityController.text,
      };

      if (showSubcategory) {
        updateArticle['subcategoria'] = subcategoryController.text;
      }
      if (showSize) {
        updateArticle['talla'] = sizeController.text;
      }
      if (showColor) {
        updateArticle['color'] = colorController.text;
      }
      if (showDescription) {
        updateArticle['descripcion'] = descriptionController.text;
      }
      if (showDimension) {
        updateArticle['tamanio'] = dimensionController.text;
      }
      if (showGender) {
        updateArticle['genero'] = genderController.text;
      }
      if (showMaterial) {
        updateArticle['material'] = materialController.text;
      }

      await client
          .from('articulos')
          .update(updateArticle)
          .eq('id', widget.articleId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizar Artículo', style: TextStyle(fontSize: 24.0)),
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Visualizar Artículo',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 48.0),
                Container(
                  width: 400.0,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'El campo de nombre no puede estar vacío';
                      }
                      return null;
                    },
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
                  width: 400.0,
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
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: 400.0,
                  child: TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'El campo de cantidad actual no puede estar vacío';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Por favor, introduzca un número entero válido';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Actual',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  width: 400.0,
                  child: TextFormField(
                    controller: minQuantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'El campo de cantidad mínima no puede estar vacío';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Por favor, introduzca un número entero válido';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Mínima',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                Visibility(
                  visible: showSubcategory,
                  child: Column(
                    children: [
                      SizedBox(height: 16.0),
                      Container(
                        width: 400.0,
                        child: TextFormField(
                          controller: subcategoryController,
                          decoration: const InputDecoration(
                            labelText: 'Subcategoría',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
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
                      Container(
                        width: 400.0,
                        child: TextFormField(
                          controller: genderController,
                          decoration: const InputDecoration(
                            labelText: 'Género',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: showSize,
                  child: Column(
                    children: [
                      SizedBox(height: 16.0),
                      Container(
                        width: 400.0,
                        child: TextFormField(
                          controller: sizeController,
                          decoration: const InputDecoration(
                            labelText: 'Talla',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: showColor,
                  child: Column(
                    children: [
                      SizedBox(height: 16.0),
                      Container(
                        width: 400.0,
                        child: TextFormField(
                          controller: colorController,
                          decoration: const InputDecoration(
                            labelText: 'Color',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
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
                      Container(
                        width: 400.0,
                        child: TextFormField(
                          controller: materialController,
                          decoration: const InputDecoration(
                            labelText: 'Material',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
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
                      Container(
                        width: 400.0,
                        child: TextFormField(
                          controller: dimensionController,
                          decoration: const InputDecoration(
                            labelText: 'Tamaño',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
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
                      Container(
                        width: 400.0,
                        child: TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
