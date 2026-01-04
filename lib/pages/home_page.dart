import 'package:chat_app_provider/Themes/theme_provider.dart';
import 'package:chat_app_provider/components/userTile.dart';
import 'package:chat_app_provider/pages/chat_page.dart';
import 'package:chat_app_provider/pages/set_languag.dart';

import 'package:chat_app_provider/services/Isar_services/local_service.dart';
import 'package:chat_app_provider/services/auth/authentication.dart';
import 'package:chat_app_provider/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalService authService = LocalService();

  void logout() {
    final auth = Authentication();
    auth.logOut();
  }

  @override
  void initState() {
    super.initState();

    ChatService().listenForDeliveryStatus();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        centerTitle: true,
        title: const Text('Home'),
        actions: [
          PopupMenuButton<String>(
            color: isDarkMode
                ? Colors.grey.shade600
                : Colors.grey.shade300,

            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: isDarkMode
                    ? Colors.white24
                    : Colors.grey.shade300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'Setting') {}
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Setting',
                onTap: () {
                  Future.delayed(
                    const Duration(seconds: 0),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SetLanguag(),
                      ),
                    ),
                  );
                },
                child: const Text('Setting'),
              ),
            ],
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
    final user = getUser();
    if (user == null) {
      return const Center(child: Text("No User Logged In"));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.getCurrentUserAddedUsers(user.email!, user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final usersList = snapshot.data ?? [];

        if (usersList.isEmpty &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (usersList.isEmpty) {
          return const Center(child: Text("No User Found"));
        }

        return ListView.builder(
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            return builduserlistitem(usersList[index], context);
          },
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
        final myId = FirebaseAuth.instance.currentUser?.uid ?? '';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              recieverEmail: userdata['Email'],
              userName: userdata['Name'],
              recieverId: userdata['uid'],
              myId: myId,
            ),
          ),
        );
      },
    );
  }
}
