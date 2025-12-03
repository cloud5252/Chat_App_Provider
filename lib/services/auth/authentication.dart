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

      await firestore
          .collection('Users')
          .doc(userCredential.user!.email)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'username': name,
            'AddedUser': false,
          });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      await showDialog(
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

      return null;
    }
  }

  Future<void> logOut() async {
    return await _firebaseAuth.signOut();
  }
}
