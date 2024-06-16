import 'package:flutter/material.dart';

import 'utils/common.dart';

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
  int _selectedIndex = 0;

  /*void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }*/

  void _onItemTapped(int index) async {
    if (index == 5) {
      // Asegúrate de que el índice sea correcto para logout
      bool? confirmLogout = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text("Cerrar sesión")),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Text("¿Seguro que quieres cerrar sesión?")),
              ],
            ),
            actions: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text("Cancelar"),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text("Confirmar"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (confirmLogout == true) {
        await client.auth.signOut();
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
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
                            // Dirigir a la pantalla de nueva venta
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
                            // Dirigir a la pantalla de nueva venta
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
