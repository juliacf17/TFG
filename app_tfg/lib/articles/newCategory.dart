import 'package:flutter/material.dart';
import '../utils/common.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _talla = true;
  bool _color = true;
  bool _descripcion = true;
  bool _subcategoria = true;
  bool _tamano = true;
  bool _genero = true;
  bool _material = true;

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      final categoryName = _categoryNameController.text;

      final Map<String, dynamic> categoryData = {
        'nombre': categoryName,
        'tieneTalla': _talla,
        'tieneColor': _color,
        'tieneDescripcion': _descripcion,
        'tieneSubcategoria': _subcategoria,
        'tieneTamanio': _tamano,
        'tieneGenero': _genero,
        'tieneMaterial': _material,
      };

      try {
        await client.from('categorias').insert(categoryData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoría añadida exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al añadir la categoría'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _categoryNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el nombre de la categoría';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Información adicional',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: Text('Talla'),
                value: _talla,
                onChanged: (bool? value) {
                  setState(() {
                    _talla = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Color'),
                value: _color,
                onChanged: (bool? value) {
                  setState(() {
                    _color = value ?? false;
                  });
                },
              ),
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
                title: Text('Subcategoría'),
                value: _subcategoria,
                onChanged: (bool? value) {
                  setState(() {
                    _subcategoria = value ?? false;
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
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  onPressed: _addCategory,
                  child: Text('Registrar Categoría'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
