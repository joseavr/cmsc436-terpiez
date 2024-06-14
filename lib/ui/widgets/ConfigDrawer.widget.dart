import 'package:flutter/material.dart';
import 'package:terpiez/ui/views/preferences_view.dart';

class ConfigDrawer extends StatelessWidget {
  const ConfigDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text(
              'Options',
              style: TextStyle(
                color: Colors.black,
                fontSize: 36,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferences'),
            onTap: () {
              // Navigate to settings page or perform action
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreferencesView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
