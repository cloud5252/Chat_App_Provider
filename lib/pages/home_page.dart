import 'package:chat_app_provider/components/userTile.dart';
import 'package:chat_app_provider/pages/chat_page.dart';
import 'package:chat_app_provider/services/auth/authentication.dart';
import 'package:chat_app_provider/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/MY_drawer.dart';

final ChatService service = ChatService();
final TextEditingController userEmailcontroller =
    TextEditingController();
final TextEditingController userNamecontroller =
    TextEditingController();
final Authentication authentication = Authentication();
FirebaseAuth firestore = FirebaseAuth.instance;
User? getuser() {
  return firestore.currentUser;
}

void addUser(BuildContext context) async {
  await service.addOrUpdateUser(
    userNamecontroller.text,
    userEmailcontroller.text,
  );

  Navigator.pop(context);
  userEmailcontroller.clear();
  userNamecontroller.clear();
}

void addNewUser(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white70,
        title: Text('Add new User'),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextField(
                controller: userNamecontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'User Name',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: userEmailcontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter email',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => addUser(context),
            child: Text(
              'Confirmed',
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  void logout() {
    final auth = Authentication();
    auth.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        centerTitle: true,
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () => logout(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: geruserbuilder(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => addNewUser(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget geruserbuilder() {
    return StreamBuilder(
      stream: service.getuserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        }
        final usersList = snapshot.data!;

        final filteredUsers = usersList
            .where((user) => user['AddedUser'] == true)
            .toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Text(
              "No User",
              style: TextStyle(
                fontSize: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        // AddUser value nikal lo

        return ListView(
          children: filteredUsers
              .map<Widget>(
                (userData) => builduserlistitem(userData, context),
              )
              .toList(),
        );
      },
    );
  }

  Widget builduserlistitem(
    Map<String, dynamic> userdata,
    BuildContext context,
  ) {
    final String currentEmail = authentication
        .getCurrentuser()!
        .email!;

    final String userEmail = userdata['email'] ?? '';
    if (currentEmail.trim().toLowerCase() ==
        userEmail.trim().toLowerCase()) {
      return SizedBox.shrink();
    }

    return Usertile(
      text: userdata['username'] ?? '',
      ontap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              recieverEmail: userdata['email'],
              userName: userdata['username'],
              recieverId: userdata['uid'],
            ),
          ),
        );
      },
    );
  }
}
