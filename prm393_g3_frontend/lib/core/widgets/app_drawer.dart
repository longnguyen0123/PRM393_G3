import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Retail Chain Manager',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),

          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Branches'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/branches');
            },
          ),
        ],
      ),
    );
  }
}