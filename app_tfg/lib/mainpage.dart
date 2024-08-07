import 'package:flutter/material.dart';
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


/*import 'package:flutter/material.dart';
import 'movements/newMovement.dart';

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
                child: Text('Ganancias diarias'),
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
}*/
