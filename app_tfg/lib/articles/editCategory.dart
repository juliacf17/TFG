import 'package:flutter/material.dart';
import '../utils/common.dart';

class EditCategoryScreen extends StatefulWidget {
  final String categoryId;

  EditCategoryScreen({required this.categoryId});

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  bool _descripcion = false;
  bool _tamano = false;
  bool _genero = false;
  bool _material = false;

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategoryDetails() async {
    final category = await client
        .from('categorias')
        .select()
        .eq('id', widget.categoryId)
        .single();

    setState(() {
      _categoryNameController.text = category['nombre'] ?? '';
      _descripcion = category['tieneDescripcion'] ?? true;
      _tamano = category['tieneTamanio'] ?? true;
      _genero = category['tieneGenero'] ?? true;
      _material = category['tieneMaterial'] ?? true;
    });
  }

  Future<bool> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      final categoryName = _categoryNameController.text;
      final Map<String, dynamic> categoryData = {
        'nombre': categoryName,
        'tieneDescripcion': _descripcion,
        'tieneTamanio': _tamano,
        'tieneGenero': _genero,
        'tieneMaterial': _material,
      };

      await client
          .from('categorias')
          .update(categoryData)
          .eq('id', widget.categoryId);

      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar datos de la categoría',
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    'Editar categoría',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 25.0),
                  TextFormField(
                    controller: _categoryNameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'El nombre de la categoría no puede estar vacío';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nombre de la categoría',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Información adicional',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Descripción',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _descripcion,
                    onChanged: (bool? value) {
                      setState(() {
                        _descripcion = value ?? false;
                      });
                    },
                    activeColor: Colors.blue[900],
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Tamaño',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _tamano,
                    onChanged: (bool? value) {
                      setState(() {
                        _tamano = value ?? false;
                      });
                    },
                    activeColor: Colors.blue[900],
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Género',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _genero,
                    onChanged: (bool? value) {
                      setState(() {
                        _genero = value ?? false;
                      });
                    },
                    activeColor: Colors.blue[900],
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Material',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _material,
                    onChanged: (bool? value) {
                      setState(() {
                        _material = value ?? false;
                      });
                    },
                    activeColor: Colors.blue[900],
                  ),
                  SizedBox(height: 40.0),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success = await _updateCategory();
                          if (success) {
                            Navigator.pop(context, true);
                          }
                        },
                        child: Text(
                          'Editar categoría',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
