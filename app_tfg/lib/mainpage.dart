import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'movements/newMovement.dart';
import 'utils/common.dart';
import 'utils/changeNotifier.dart'; // Asegúrate de importar RefreshNotifier

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Principal',
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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double dailyEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDailyEarnings();
  }

  Future<void> fetchDailyEarnings() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime startOfDay =
          DateTime(now.year, now.month, now.day, 0, 0, 0);
      final DateTime endOfDay =
          DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await client
          .from('movimientos')
          .select()
          .gte('fecha', startOfDay.toIso8601String())
          .lte('fecha', endOfDay.toIso8601String());

      double earnings = 0.0;

      for (var movimiento in response) {
        if (movimiento['tipoMov'] == 'Venta') {
          earnings += movimiento['precioTotal'];
        } else if (movimiento['tipoMov'] == 'Devolución' &&
            movimiento['isPrestamo'] == false) {
          earnings -= movimiento['precioTotal'];
        }
      }

      setState(() {
        dailyEarnings = earnings;
      });
    } catch (error) {
      print('Error fetching daily earnings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        // Recargar datos cuando se notifique un cambio
        fetchDailyEarnings();

        return Scaffold(
          appBar: AppBar(
            title: Text('Inicio',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            foregroundColor: Colors.blue[900],
            centerTitle: false,
            //backgroundColor: Colors.blueGrey[200],
            backgroundColor: Colors.blue[200],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // Ajusta el padding según sea necesario
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 300.0,
                    height: 150.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[900]!, width: 5.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'Ganancias diarias: ${dailyEarnings.toStringAsFixed(2)} €',
                      style: TextStyle(
                        color: Colors.blue[
                            900], // Establece el color del texto a blue 900
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 100.0), // Espacio entre las celdas
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 300.0,
                        height: 150.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.green[600]!, width: 9.0),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NuevaVentaScreen(isVenta: true),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // Cambia el color de fondo según tu diseño
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                backgroundColor: Colors.blue[900],
                              ),
                              child: Text(
                                'Nueva venta',
                                style: TextStyle(
                                  color: Colors.grey[
                                      300], // Establece el color del texto a blue 900
                                  fontSize: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100.0),
                      Container(
                        width: 300.0,
                        height: 150.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.purple[400]!, width: 9.0),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NuevaVentaScreen(isVenta: false),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // Cambia el color de fondo según tu diseño
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                backgroundColor: Colors.blue[900],
                              ),
                              child: Text(
                                'Nuevo préstamo',
                                style: TextStyle(
                                  color: Colors.grey[
                                      300], // Establece el color del texto a blue 900
                                  fontSize: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'movements/newMovement.dart';
import '../utils/common.dart';
import '../utils/changeNotifier.dart'; // Asegúrate de importar RefreshNotifier

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RefreshNotifier(),
      child: MaterialApp(
        title: 'Pantalla Principal',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double dailyEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDailyEarnings();
  }

  Future<void> fetchDailyEarnings() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime startOfDay =
          DateTime(now.year, now.month, now.day, 0, 0, 0);
      final DateTime endOfDay =
          DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await client
          .from('movimientos')
          .select()
          .gte('fecha', startOfDay.toIso8601String())
          .lte('fecha', endOfDay.toIso8601String());

      double earnings = 0.0;

      for (var movimiento in response) {
        if (movimiento['tipoMov'] == 'Venta') {
          earnings += movimiento['precioTotal'];
        } else if (movimiento['tipoMov'] == 'Devolución' &&
            movimiento['isPrestamo'] == false) {
          earnings -= movimiento['precioTotal'];
        }
      }

      setState(() {
        dailyEarnings = earnings;
      });
    } catch (error) {
      print('Error fetching daily earnings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RefreshNotifier>(
      builder: (context, notifier, child) {
        // Recargar datos cuando se notifique un cambio
        fetchDailyEarnings();

        return Scaffold(
          appBar: AppBar(
            title: Text('Pantalla principal', style: TextStyle(fontSize: 24.0)),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // Ajusta el padding según sea necesario
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200.0,
                    height: 100.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Ganancias diarias: ${dailyEarnings.toStringAsFixed(2)} €',
                    ),
                  ),
                  SizedBox(width: 100.0), // Espacio entre las celdas
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 200.0,
                        height: 100.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NuevaVentaScreen(isVenta: true),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // Cambia el color de fondo según tu diseño
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text('Nueva venta'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 100.0),
                      Container(
                        width: 200.0,
                        height: 100.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NuevaVentaScreen(isVenta: false),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // Cambia el color de fondo según tu diseño
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text('Nuevo préstamo'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
*/

/*import 'package:flutter/material.dart';
import 'movements/newMovement.dart';
import '../utils/common.dart'; // Asegúrate de tener acceso al cliente de supabase

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantalla Principal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double dailyEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDailyEarnings();
  }

  Future<void> fetchDailyEarnings() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime startOfDay =
          DateTime(now.year, now.month, now.day, 0, 0, 0);
      final DateTime endOfDay =
          DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await client
          .from('movimientos')
          .select()
          .gte('fecha', startOfDay.toIso8601String())
          .lte('fecha', endOfDay.toIso8601String());

      double earnings = 0.0;

      for (var movimiento in response) {
        if (movimiento['tipoMov'] == 'Venta') {
          earnings += movimiento['precioTotal'];
        } else if (movimiento['tipoMov'] == 'Devolución' &&
            movimiento['isPrestamo'] == false) {
          earnings -= movimiento['precioTotal'];
        }
      }

      setState(() {
        dailyEarnings = earnings;
      });
    } catch (error) {
      print('Error fetching daily earnings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla principal', style: TextStyle(fontSize: 24.0)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(
              16.0), // Ajusta el padding según sea necesario
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200.0,
                height: 100.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                    'Ganancias diarias: ${dailyEarnings.toStringAsFixed(2)} €'),
              ),
              SizedBox(width: 100.0), // Espacio entre las celdas
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200.0,
                    height: 100.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NuevaVentaScreen(isVenta: true),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            // Cambia el color de fondo según tu diseño
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text('Nueva venta'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 100.0),
                  Container(
                    width: 200.0,
                    height: 100.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NuevaVentaScreen(isVenta: false),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            // Cambia el color de fondo según tu diseño
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text('Nuevo préstamo'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
