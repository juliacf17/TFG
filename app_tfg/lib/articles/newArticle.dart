import 'package:flutter/material.dart';
import '../utils/common.dart';

class NewArticle extends StatefulWidget {
  final String categoryId;
  List<String> existingSubcategories;

  NewArticle({required this.categoryId, required this.existingSubcategories});

  @override
  _NewArticleState createState() => _NewArticleState();
}

class _NewArticleState extends State<NewArticle> {
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

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
    _addSizeRow();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Añadir un artículo',
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
                    'Nuevo artículo',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 25.0),
                  TextFormField(
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
                  SizedBox(height: 16.0),
                  TextFormField(
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
                      labelText: 'Precio (€)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: showGender,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
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
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ListView.builder(
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
                              height: 8.0), // Espacio de 8 unidades entre filas
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: TextButton(
                      onPressed: _addSizeRow,
                      child: Text('Agregar otra talla'),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Center(
                    child: SizedBox(
                      width: 200, // Establece el ancho del botón
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            double money = double.parse(priceController.text);
                            money = double.parse(money.toStringAsFixed(2));

                            bool success = await _addTallasToDatabase();

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Artículo añadido exitosamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al añadir el artículo'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          "Añadir Artículo",
                          style: TextStyle(
                            color: Colors.yellow[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blue[900]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _addTallasToDatabase() async {
    try {
      final articleId = await _addArticleToDatabase();

      for (int i = 0; i < sizeControllers.length; i++) {
        await client.from('tallas').insert({
          'articuloId': articleId,
          'talla': sizeControllers[i].text.trim(),
          'color': colorControllers[i].text.trim(),
          'cantidadActual': int.parse(quantityControllers[i].text.trim()),
          'cantidadMinima': int.parse(minQuantityControllers[i].text.trim()),
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> _addArticleToDatabase() async {
    double money = double.parse(priceController.text);
    money = double.parse(money.toStringAsFixed(2));

    final newArticle = {
      'nombre': nameController.text,
      'precio': money,
      'categoriaId': widget.categoryId,
      'subcategoria': subcategoryController.text,
    };

    if (showDescription) {
      newArticle['descripcion'] = descriptionController.text;
    }
    if (showDimension) {
      newArticle['tamanio'] = dimensionController.text;
    }
    if (showGender) {
      newArticle['genero'] = selectedGender!;
    }
    if (showMaterial) {
      newArticle['material'] = materialController.text;
    }

    await client.from('articulos').insert(newArticle);

    final response = await client
        .from('articulos')
        .select('*')
        .order('id', ascending: false)
        .limit(1)
        .single();

    final int articleId = response['id'];

    return articleId;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    subcategoryController.dispose();
    descriptionController.dispose();
    dimensionController.dispose();
    materialController.dispose();
    for (var controller in sizeControllers) {
      controller.dispose();
    }
    for (var controller in colorControllers) {
      controller.dispose();
    }
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var controller in minQuantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}


/*import 'package:flutter/material.dart';
import '../utils/common.dart';

class NewArticle extends StatefulWidget {
  final String categoryId;
  List<String> existingSubcategories;

  NewArticle({required this.categoryId, required this.existingSubcategories});

  @override
  _NewArticleState createState() => _NewArticleState();
}

class _NewArticleState extends State<NewArticle> {
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

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
    _addSizeRow();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Añadir artículo',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.blue[900],
        backgroundColor: Colors.blue[200],
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
            padding: const EdgeInsets.symmetric(horizontal: 200.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Añadir Nuevo Artículo',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 48.0),
                  TextFormField(
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
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
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
                  ),
                  SizedBox(height: 16.0),
                  Row(
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
                  Visibility(
                    visible: showGender,
                    child: Column(
                      children: [
                        SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
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
                              if (subcategoryController.text != '' &&
                                  subcategoryController.text != null &&
                                  !widget.existingSubcategories
                                      .contains(subcategoryController.text)) {
                                widget.existingSubcategories
                                    .add(subcategoryController.text);
                              }

                              selectedGender = newValue;
                            });
                          },
                          decoration: const InputDecoration(
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
                          decoration: const InputDecoration(
                            labelText: 'Material',
                            border: OutlineInputBorder(),
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
                        TextFormField(
                          controller: dimensionController,
                          decoration: const InputDecoration(
                            labelText: 'Dimensiones',
                            border: OutlineInputBorder(),
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
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ListView.builder(
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
                              height: 8.0), // Espacio de 8 unidades entre filas
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextButton(
                    onPressed: _addSizeRow,
                    child: Text('Agregar otra talla'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        bool success = await _addTallasToDatabase();

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Artículo añadido exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al añadir el artículo'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Añadir Artículo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _addTallasToDatabase() async {
    try {
      final articleId = await _addArticleToDatabase();

      for (int i = 0; i < sizeControllers.length; i++) {
        await client.from('tallas').insert({
          'articuloId': articleId,
          'talla': sizeControllers[i].text.trim(),
          'color': colorControllers[i].text.trim(),
          'cantidadActual': int.parse(quantityControllers[i].text.trim()),
          'cantidadMinima': int.parse(minQuantityControllers[i].text.trim()),
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> _addArticleToDatabase() async {
    double money = double.parse(priceController.text);
    money = double.parse(money.toStringAsFixed(2));

    final newArticle = {
      'nombre': nameController.text,
      'precio': money,
      'categoriaId': widget.categoryId,
      'subcategoria': subcategoryController.text,
    };

    if (showDescription) {
      newArticle['descripcion'] = descriptionController.text;
    }
    if (showDimension) {
      newArticle['tamanio'] = dimensionController.text;
    }
    if (showGender) {
      newArticle['genero'] = selectedGender!;
    }
    if (showMaterial) {
      newArticle['material'] = materialController.text;
    }

    await client.from('articulos').insert(newArticle);

    final response = await client
        .from('articulos')
        .select('*')
        .order('id', ascending: false)
        .limit(1)
        .single();

    final int articleId = response['id'];

    return articleId;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    subcategoryController.dispose();
    descriptionController.dispose();
    dimensionController.dispose();
    materialController.dispose();
    for (var controller in sizeControllers) {
      controller.dispose();
    }
    for (var controller in colorControllers) {
      controller.dispose();
    }
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var controller in minQuantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

*/