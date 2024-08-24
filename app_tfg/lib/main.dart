import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';
import 'utils/common.dart';
import 'utils/bottomNavigation.dart';
import 'utils/changeNotifier.dart'; // Importa el RefreshNotifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://fkludqzakcuakxqzjdnl.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZrbHVkcXpha2N1YWt4cXpqZG5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg1NTE3MDIsImV4cCI6MjAzNDEyNzcwMn0.jNYcPrfjdGu8RvTJJxHfz9CiHYnzSi58zaAlDCGJKOk",
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RefreshNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[900], // Establece el color primario a blue900
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          //primaryColorDark: Colors.blue[900], // Color primario oscuro a blue900
        ).copyWith(
          primary: Colors.blue[900], // Aplica blue900 como el color primario
          secondary:
              Colors.blue[900], // Establece el color secundario a blue900
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors
              .blue[900], // Cambia el color del cursor en los campos de texto
          selectionColor: Colors.blue[900]
              ?.withOpacity(0.5), // Cambia el color de la selección de texto
          selectionHandleColor:
              Colors.blue[900], // Cambia el color del manejador de selección
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey[600]!), // Borde por defecto
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey[600]!), // Borde cuando no está en foco
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[900]!),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600]!, // Color gris cuando no está enfocado
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.blue[900], // Color azul cuando está enfocado
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.blue[900]; // Color azul cuando está seleccionado
              }
              return Colors.white; // Color blanco cuando no está seleccionado
            },
          ),
          checkColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return Colors
                    .white; // El color del checkmark dentro de la casilla
              }
              return Colors.black; // Color del checkmark cuando está vacío
            },
          ),
          side: MaterialStateBorderSide.resolveWith(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return BorderSide(
                    color: Colors
                        .blue[900]!); // Borde azul cuando está seleccionado
              }
              return BorderSide(
                  color: Colors.black); // Borde negro cuando está vacío
            },
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
        ),
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
