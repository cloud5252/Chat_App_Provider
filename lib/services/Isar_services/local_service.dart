import 'dart:async';

import 'package:chat_app_provider/models/UserModel.dart';
import 'package:chat_app_provider/pages/home_page.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_chat_service.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class LocalService extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  StreamSubscription<List<Contact>>? _contactSubscription;
  List<Contact> myContacts = [];
  List<Contact> users = [];
  bool isLoading = true;
  void listenToContacts(String myId) {
    _contactSubscription?.cancel();
    _contactSubscription = IsarService.watchMyContacts(myId).listen((
      contactList,
    ) {
      myContacts = contactList;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> syncContactsFromFirestore(String myId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Firestore se data fetch karna
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(myId)
          .collection('AddedUser')
          .get();

      final db = IsarService.isar;

      // Isar mein save karna
      await db.writeTxn(() async {
        for (var doc in snapshot.docs) {
          final contact = Contact()
            ..ownerId = myId
            ..contactId = doc['uid']
            ..contactName = doc['Name']
            ..contactEmail = doc['Email'];

          // Isar mein save (overwrite agar pehle se ho)
          await db.contacts.put(contact);
        }
      });
    } catch (e) {
      debugPrint("Sync Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  final IsarChatService _service = IsarChatService();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? getUser() {
    return firebaseAuth.currentUser;
  }

  void addUser(BuildContext context) async {
    final String email = userEmailcontroller.text.trim();
    final String myId = getUser()?.uid ?? "";

    final myData = await IsarService.isar.userModels
        .filter()
        .uidEqualTo(myId)
        .findFirst();

    if (email.isEmpty || myData == null) return;

    final UserModel? registeredUser =
        await IsarChatService.findUserByEmail(email);

    if (registeredUser != null) {
      if (registeredUser.uid == myId) return;

      await _service.addContact(
        registeredUser,
        myId,
        myData.name,
        myData.email,
      );

      Navigator.pop(context);
      userEmailcontroller.clear();
      notifyListeners();
    } else {}
  }
}
