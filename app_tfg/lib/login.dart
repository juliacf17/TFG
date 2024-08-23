import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/common.dart';

final supabase = Supabase.instance.client;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Establece el fondo en blue[50]
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Inicio de sesión',
                style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900]),
              ),
              SizedBox(height: 48.0),
              Container(
                width: 400.0, // Ajusta el ancho del TextField
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El campo de email no puede estar vacío';
                    }
                    return null;
                  },
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 400.0, // Ajusta el ancho del TextField
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El campo de contraseña no puede estar vacío';
                    }
                    return null;
                  },
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 32.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton(
                      onPressed: () async {
                        final isValid = _formKey.currentState?.validate();
                        if (isValid != true) {
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await client.auth.signInWithPassword(
                              email: _usernameController.text,
                              password: _passwordController.text);
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                          });
                          // Mostrar el diálogo de error
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                  side: BorderSide(
                                    color: Colors.blue[900]!,
                                    width: 5.0,
                                  ),
                                ),
                                title: Center(
                                  child: Text(
                                    "Credenciales incorrectas",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                content: Text(
                                  "Usuario o contraseña incorrectos. Intente de nuevo.",
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      "Aceptar",
                                      style: TextStyle(
                                        color: Colors.yellow[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.blue[900]!),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text(
                        "Iniciar sesión",
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
            ],
          ),
        ),
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/common.dart';

final supabase = Supabase.instance.client;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Inicio de sesión',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            ),
            SizedBox(height: 48.0),
            Container(
              width: 400.0, // Ajusta el ancho del TextField
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El campo de email no puede estar vacío';
                  }
                  return null;
                },
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              width: 400.0, // Ajusta el ancho del TextField
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El campo de contraseña no puede estar vacío';
                  }
                  return null;
                },
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 32.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(
                    onPressed: () async {
                      final isValid = _formKey.currentState?.validate();
                      if (isValid != true) {
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        await client.auth.signInWithPassword(
                            email: _usernameController.text,
                            password: _passwordController.text);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Usuario o contraseña incorrectos'),
                          backgroundColor: Colors.redAccent,
                        ));
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: Text(
                      "Iniciar sesión",
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
                  )
          ],
        ),
      ),
    );
  }
}
*/