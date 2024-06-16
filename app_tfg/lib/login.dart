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
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Inicio de sesión',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
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
                    child: const Text('Iniciar sesión'),
                  )
          ],
        ),
      ),
    );
  }
}


/*
void main() {
  runApp(Login());
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/main': (context) => MainPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    /*final response = await supabase.auth.signInWithPassword(email: _usernameController.text.trim(), password: _passwordController.text.trim());

    response.

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrectos')));
      return;
    }
    else{
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sesión iniciada con éxito')));
      Navigator.pushReplacementNamed(context, '/main');
    }

*/
/*

    supabase.auth.signInWithPassword(password: _passwordController.text, email: _usernameController.text)

    final username = _usernameController.text;
    final password = _passwordController.text;

    // Aquí puedes agregar tu lógica de autenticación
    if (username == 'user' && password == 'password') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sesión iniciada con éxito')));

      // Navega a la pantalla principal
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrectos')));
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Inicio de sesión',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
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
              Container(
                width: 200.0, // Ajusta el ancho del botón
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Bordes redondeados
                  )),
                  child: Text('Iniciar sesión'),
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