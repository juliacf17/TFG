import 'package:flutter/material.dart';
import '../utils/common.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _descripcion = true;
  bool _tamano = true;
  bool _genero = true;
  bool _material = true;

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      final categoryName = _categoryNameController.text;

      final Map<String, dynamic> categoryData = {
        'nombre': categoryName,
        'tieneDescripcion': _descripcion,
        'tieneTamanio': _tamano,
        'tieneGenero': _genero,
        'tieneMaterial': _material,
      };

      await client.from('categorias').insert(categoryData);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Añadir una categoría',
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
                  //Center(
                  Text(
                    'Nueva categoría',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  //),
                  SizedBox(height: 25.0),
                  TextFormField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la categoría',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900]),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Descripción',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold, // Poner el texto en negrita
                      ),
                    ),
                    value: _descripcion,
                    onChanged: (bool? value) {
                      setState(() {
                        _descripcion = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Tamaño',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold, // Poner el texto en negrita
                      ),
                    ),
                    value: _tamano,
                    onChanged: (bool? value) {
                      setState(() {
                        _tamano = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Género',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold, // Poner el texto en negrita
                      ),
                    ),
                    value: _genero,
                    onChanged: (bool? value) {
                      setState(() {
                        _genero = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Material',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold, // Poner el texto en negrita
                      ),
                    ),
                    value: _material,
                    onChanged: (bool? value) {
                      setState(() {
                        _material = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _addCategory,
              child: Text(
                'Registrar Categoría',
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
        ],
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import '../utils/common.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _categoryNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _descripcion = true;
  bool _tamano = true;
  bool _genero = true;
  bool _material = true;

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      final categoryName = _categoryNameController.text;

      final Map<String, dynamic> categoryData = {
        'nombre': categoryName,
        'tieneDescripcion': _descripcion,
        'tieneTamanio': _tamano,
        'tieneGenero': _genero,
        'tieneMaterial': _material,
      };

      await client.from('categorias').insert(categoryData);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Añadir cateogoría',
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
                title: Text('Descripción'),
                value: _descripcion,
                onChanged: (bool? value) {
                  setState(() {
                    _descripcion = value ?? false;
                  });
                },
                activeColor: Colors.blue[900],
              ),
              CheckboxListTile(
                title: Text('Tamaño'),
                value: _tamano,
                onChanged: (bool? value) {
                  setState(() {
                    _tamano = value ?? false;
                  });
                },
                activeColor: Colors.blue[900],
              ),
              CheckboxListTile(
                title: Text('Género'),
                value: _genero,
                onChanged: (bool? value) {
                  setState(() {
                    _genero = value ?? false;
                  });
                },
                activeColor: Colors.blue[900],
              ),
              CheckboxListTile(
                title: Text('Material'),
                value: _material,
                onChanged: (bool? value) {
                  setState(() {
                    _material = value ?? false;
                  });
                },
                activeColor: Colors.blue[900],
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
*/