import 'package:chat_app_provider/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}
