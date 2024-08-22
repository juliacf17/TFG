import 'package:flutter/material.dart';
import '../utils/common.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final String categoryId;
  final List<String> existingSubcategories;
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
  final TextEditingController subcategoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dimensionController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  List<TextEditingController> sizeControllers = [];
  List<TextEditingController> colorControllers = [];
  List<TextEditingController> quantityControllers = [];
  List<TextEditingController> minQuantityControllers = [];

  bool showDescription = false;
  bool showDimension = false;
  bool showGender = false;
  bool showMaterial = false;

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
      genderController.text = articleData['genero'] ?? '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visualizar datos del artículo',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
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
                  SizedBox(height: 20.0),
                  Text(
                    'Datos del artículo',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 25.0),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: subcategoryController,
                    decoration: InputDecoration(
                      labelText: 'Subcategoría',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                  Visibility(
                    visible: showGender,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: genderController,
                          decoration: InputDecoration(
                            labelText: 'Género',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showMaterial,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: materialController,
                          decoration: InputDecoration(
                            labelText: 'Material',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showDimension,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: dimensionController,
                          decoration: InputDecoration(
                            labelText: 'Dimensiones',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showDescription,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  sizeControllers.isEmpty
                      ? Text(
                          "No hay tallas registradas",
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: sizeControllers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 200.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: sizeControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Talla',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: colorControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Color',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: quantityControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Cantidad Actual',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: minQuantityControllers[index],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Cantidad Mínima',
                                        border: OutlineInputBorder(),
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
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
*/