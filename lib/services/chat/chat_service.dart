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

  Stream<List<Map<String, dynamic>>> getCurrentUserAddedUsers(
    String currentUserEmail,
  ) async* {
    try {
      final query = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (query.docs.isEmpty) {
        print("User not found!");
        yield [];
        return;
      }

      final userDocId = query.docs.first.id;

      yield* FirebaseFirestore.instance
          .collection('Users')
          .doc(userDocId)
          .collection('AddedUser')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => doc.data()).toList(),
          );
    } catch (e) {
      print("Error: $e");
      yield [];
    }
  }

  Future addOrUpdateUser(
    String name,
    String email,
    String currentUserEmail,
  ) async {
    try {
      final currentUserQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (currentUserQuery.docs.isEmpty) {
        return;
      }

      final currentUserDocId = currentUserQuery.docs.first.id;

      final addedUsersSubcollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserDocId)
          .collection('AddedUser');

      final newDocRef = addedUsersSubcollection.doc();

      Map<String, dynamic> addedUserData = {
        'Name': name,
        'Email': email,
        'uid': newDocRef.id,
        'addedAt': FieldValue.serverTimestamp(),
      };

      // await newDocRef.set(addedUserData);

      await addedUsersSubcollection.add(addedUserData);
    } catch (e) {}
  }

  Future<void> editMessage(
    String newMessage,
    String chatRoomId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
            'message': newMessage,
            'isEdited': true,
            'editedAt': Timestamp.now(),
          });

      print('Message updated successfully');
    } catch (e) {
      print('Error updating message: $e');
    }
  }

  Future<void> deleteMessage(
    String chatRoomId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}
