import 'package:flutter/material.dart';
import '../utils/common.dart';

class NewArticle extends StatefulWidget {
  final String categoryId;
  List<String> existingSubcategories; // Puede ser final, no la quiero cambiar.

  NewArticle({required this.categoryId, required this.existingSubcategories});

  @override
  _NewArticleState createState() => _NewArticleState();
}

class _NewArticleState extends State<NewArticle> {
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

  bool showSubcategory = false;
  bool showSize = false;
  bool showColor = false;
  bool showDescription = false;
  bool showDimension = false;
  bool showGender = false;
  bool showMaterial = false;

  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Nuevo Artículo', style: TextStyle(fontSize: 24.0)),
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
                  'Añadir Nuevo Artículo',
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
                  ),
                ),
                Visibility(
                  visible: showSubcategory,
                  child: Column(
                    children: [
                      SizedBox(height: 16.0),
                      Container(
                        width: 400.0,
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
                                        color:
                                            subcategoryController.text.isEmpty
                                                ? Colors.black
                                                : Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            subcategoryController.text.isEmpty
                                                ? Colors.black
                                                : Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                              if (!widget.existingSubcategories
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
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await _addArticleToDatabase();

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
    );
  }

  Future<bool> _addArticleToDatabase() async {
    try {
      double money = double.parse(priceController.text);
      money = double.parse(money.toStringAsFixed(2));

      final newArticle = {
        'nombre': nameController.text,
        'precio': money,
        'cantidad_actual': quantityController.text,
        'cantidad_minima': minQuantityController.text,
        'categoriaId': widget.categoryId,
      };

      if (showSubcategory) {
        newArticle['subcategoria'] = subcategoryController.text;
      }
      if (showSize) {
        newArticle['talla'] = sizeController.text;
      }
      if (showColor) {
        newArticle['color'] = colorController.text;
      }
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
      return true;
    } catch (e) {
      return false;
    }
  }
}


/*import 'package:flutter/material.dart';
import '../utils/common.dart';

class NewArticle extends StatefulWidget {
  final String categoryId;

  NewArticle({required this.categoryId});

  @override
  _NewArticleState createState() => _NewArticleState();
}

class _NewArticleState extends State<NewArticle> {
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

  bool showSubcategory = false;
  bool showSize = false;
  bool showColor = false;
  bool showDescription = false;
  bool showDimension = false;
  bool showGender = false;
  bool showMaterial = false;

  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Nuevo Artículo', style: TextStyle(fontSize: 24.0)),
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
                  'Añadir Nuevo Artículo',
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
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await _addArticleToDatabase();

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
    );
  }

  Future<bool> _addArticleToDatabase() async {
    try {
      double money = double.parse(priceController.text);
      money = double.parse(money.toStringAsFixed(2));

      final newArticle = {
        'nombre': nameController.text,
        'precio': money,
        'cantidad_actual': quantityController.text,
        'cantidad_minima': minQuantityController.text,
        'categoriaId': widget.categoryId,
      };

      if (showSubcategory) {
        newArticle['subcategoria'] = subcategoryController.text;
      }
      if (showSize) {
        newArticle['talla'] = sizeController.text;
      }
      if (showColor) {
        newArticle['color'] = colorController.text;
      }
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
      return true;
    } catch (e) {
      return false;
    }
  }
}
*/