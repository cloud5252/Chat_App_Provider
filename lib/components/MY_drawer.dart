import 'package:flutter/material.dart';

import '../services/auth/authentication.dart';
import '../pages/setting_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  void logout() {
    final auth = Authentication();
    auth.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.message,
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary,
                    size: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary,
                  ),
                  title: Text(
                    'H O M E',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.inversePrimary,
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary,
                  ),
                  title: Text(
                    'S E T T I N G',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.inversePrimary,
                      fontSize: 20,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 30),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: Text(
                'L O G O U T',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 20,
                ),
              ),
              onTap: () {
                logout();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
