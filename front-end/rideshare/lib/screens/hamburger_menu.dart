import 'package:flutter/material.dart';
import 'signin_screen.dart'; // Import SignInScreen
import 'user_screen.dart'; // Import ProfileScreen
import 'pastrides_screen.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        );
      },
    );
  }
}

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Past Rides'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PastRidesScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigate to ProfileScreen
              );
            },
          ),
          ListTile(
            title: Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()), // Navigate to SignInScreen and remove all routes below it
              );
            },
          ),
          ListTile(
            title: Text('Help'),
            onTap: () {
              // Add your logic for help
            },
          ),
        ],
      ),
    );
  }
}
