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
            const Text(
              'Inicio de sesión',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48.0),
            SizedBox(
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
            const SizedBox(height: 16.0),
            SizedBox(
              width: 400.0, // Ajusta el ancho del TextField
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'El campo de contraseña no puede estar vacío';
                  }
                  return null;
                },
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 32.0),
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
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
