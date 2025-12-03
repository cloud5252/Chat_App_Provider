import 'package:chat_app_provider/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendMessages(String recieverId, message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentuseremail =
        _firebaseAuth.currentUser!.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    Messages messages = Messages(
      massage: message,
      receiverID: recieverId,
      senderEmail: currentuseremail,
      senderId: currentUserId,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, recieverId];
    ids.sort();
    String chatroomId = ids.join('_');

    await firestore
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .add(messages.toMap());
        
  }

  Stream<QuerySnapshot> getMessages(String senderId, receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatroomId = ids.join('_');

    return firestore
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> getuserStream() {
    return firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return data;
      }).toList();
    });
  }

  Future addOrUpdateUser(String name, String email) async {
    final usersCollection = FirebaseFirestore.instance.collection(
      'Users',
    );

    final query = await usersCollection
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isNotEmpty) {
      // Ab safe hai first use karna
      // final docData = query.docs.first.data();
      // final String userEmail = docData['email'];
      final docId = query.docs.first.id;

      await usersCollection.doc(docId).update({'AddedUser': true});
      print("Existing user updated");
    } else {
      Get.snackbar(
        "Not Logged In",
        "User is not logged in, so action cannot be performed.",
        titleText: Text(
          "Not Logged In",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          "User is not logged in, so action cannot be performed.",
          style: TextStyle(color: Colors.black),
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
    }
  }
}
