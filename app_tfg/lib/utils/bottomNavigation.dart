import 'package:flutter/material.dart';
import '../mainpage.dart';
import '../login.dart';
import '../clients/clientView.dart';
import '../articles/categoryView.dart';
import '../movements/viewMovements.dart';
import '../graphics/graphic.dart';
import 'common.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MainPage(),
    ClientView(),
    CategoryView(),
    MovimientosView(),
    ChartScreen(),
    // Add other screens here
  ];

  void _onItemTapped(int index) async {
    if (index == 5) {
      bool? confirmLogout = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              side: BorderSide(
                color: Colors.blue[900]!,
                width: 5.0,
              ),
            ),
            title: Center(
              child: Text(
                "Cerrar sesión",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              "¿Seguro que quieres cerrar sesión?",
            ),
            actions: [
              TextButton(
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(
                  "Confirmar",
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
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmLogout == true) {
        await client.auth.signOut();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
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
        backgroundColor: Colors.blue[200], // Fondo de la barra de navegación
        selectedItemColor:
            Colors.blue[900], // Color de los iconos seleccionados
        unselectedItemColor:
            Colors.white, // Color de los iconos no seleccionados
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}



/*import 'package:flutter/material.dart';
import '../mainpage.dart';
import '../login.dart';
import '../clientView.dart';
import '../articles/categoryView.dart';
import 'common.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MainPage(),
    ClientView(),
    CategoryView(),

    //Login(),
    // Add other screens here
  ];

  void _onItemTapped(int index) async {
    if (index == 5) {
      // Ensure the index is correct for logout
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
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
*/