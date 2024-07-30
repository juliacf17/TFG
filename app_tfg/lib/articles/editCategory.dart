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

      try {
        await client
            .from('categorias')
            .update(categoryData)
            .eq('id', widget.categoryId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoría actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la categoría'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Categoría'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Editar categoría',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24.0),
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
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                CheckboxListTile(
                  title: Text('Descripción'),
                  value: _descripcion,
                  onChanged: (bool? value) {
                    setState(() {
                      _descripcion = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Tamaño'),
                  value: _tamano,
                  onChanged: (bool? value) {
                    setState(() {
                      _tamano = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Género'),
                  value: _genero,
                  onChanged: (bool? value) {
                    setState(() {
                      _genero = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Material'),
                  value: _material,
                  onChanged: (bool? value) {
                    setState(() {
                      _material = value ?? false;
                    });
                  },
                ),
                SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      bool success = await _updateCategory();
                      if (success) {
                        Navigator.pop(context, true);
                      }
                    },
                    child: Text('Editar categoría'),
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
