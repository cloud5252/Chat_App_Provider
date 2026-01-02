import 'package:chat_app_provider/models/UserModel.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authentication {
  final currentUsers = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  User? getCurrentuser() {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential? userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          );

      // firestore.collection('Users').doc(userCredential.user!.uid).set(
      //   {'uid': userCredential.user!.uid, 'email': email},
      // );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential?> createdAccount(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      final user = UserModel()
        ..uid = userCredential.user!.uid
        ..name = name
        ..email = email
        ..timestamp = DateTime.now();

      // Firestore mein save karein
      await firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'username': name,
          });

      if (context.mounted) {
        await IsarService.addUser(context, user);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(e.message ?? 'Something went wrong'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
      return null;
    }
  }

  Future<void> logOut() async {
    return await _firebaseAuth.signOut();
  }
}
