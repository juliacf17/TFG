import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';
import 'utils/common.dart';
import 'utils/bottomNavigation.dart'; // Importa el archivo bottom_navigation.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: "https://fkludqzakcuakxqzjdnl.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZrbHVkcXpha2N1YWt4cXpqZG5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg1NTE3MDIsImV4cCI6MjAzNDEyNzcwMn0.jNYcPrfjdGu8RvTJJxHfz9CiHYnzSi58zaAlDCGJKOk");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  User? _user;

  @override
  void initState() {
    _getAuth();
    super.initState();
  }

  Future<void> _getAuth() async {
    setState(() {
      _user = client.auth.currentUser;
    });

    client.auth.onAuthStateChange.listen((event) {
      setState(() {
        _user = event.session?.user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user == null ? const Login() : BottomNav(), // Usa BottomNav aquí
    );
  }
}
