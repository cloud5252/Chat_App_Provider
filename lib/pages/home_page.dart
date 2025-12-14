import 'package:chat_app_provider/components/userTile.dart';
import 'package:chat_app_provider/pages/chat_page.dart';
import 'package:chat_app_provider/services/auth/authentication.dart';
import 'package:chat_app_provider/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/MY_drawer.dart';

final ChatService service = ChatService();
final TextEditingController userEmailcontroller =
    TextEditingController();
final TextEditingController userNamecontroller =
    TextEditingController();
final Authentication authentication = Authentication();
FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? getUser() {
  return firebaseAuth.currentUser;
}

void addUser(BuildContext context) async {
  User? currentUser = getUser();

  if (currentUser == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('User not logged in!')));
    return;
  }

  if (userEmailcontroller.text.isEmpty ||
      userNamecontroller.text.isEmpty) {
    Get.snackbar(
      'Required',
      'Please fill all fields.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
    );
    return;
  }

  await service.addOrUpdateUser(
    userNamecontroller.text.trim(),
    userEmailcontroller.text.trim(),
    currentUser.email!,
  );

  Navigator.pop(context);

  userEmailcontroller.clear();
  userNamecontroller.clear();
}

void addNewUser(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text('Add new User'),
        content: Column(
          children: [
            SizedBox(height: 10),
            CupertinoTextField(
              controller: userNamecontroller,
              placeholder: 'User Name',
              padding: EdgeInsets.all(12),
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: userEmailcontroller,
              placeholder: 'User Email',
              padding: EdgeInsets.all(12),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () => addUser(context),
            isDefaultAction: true,
            child: Text(
              'Confirm',
              style: TextStyle(
                fontSize: 18,
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
      stream: service.getCurrentUserAddedUsers(getUser()!.email!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        }
        final usersList = snapshot.data!;

        final filteredUsers = usersList;

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
    return Usertile(
      text: userdata['Name'] ?? '',
      ontap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              recieverEmail: userdata['Email'],
              userName: userdata['Name'],
              recieverId: userdata['uid'],
            ),
          ),
        );
      },
    );
  }
}
