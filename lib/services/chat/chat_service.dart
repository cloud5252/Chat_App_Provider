import 'package:chat_app_provider/models/UserModel.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class ChatService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> sendMessages(
    String receiverId,
    String messageText,
  ) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail =
        _firebaseAuth.currentUser!.email ?? '';
    final DateTime now = DateTime.now();

    List<String> ids = [currentUserId, receiverId]..sort();
    String chatroomId = ids.join('_');

    final messageRef = firestore
        .collection('chat_rooms')
        .doc(chatroomId)
        .collection('messages')
        .doc();

    String generatedFirebaseId = messageRef.id;

    // 1. ISAR SAVE (Status 0 = Clock)
    try {
      final db = IsarService.isar;
      final localMessage = ChatMessage()
        ..firebaseId = generatedFirebaseId
        ..chatRoomId = chatroomId
        ..senderId = currentUserId
        ..senderEmail = currentUserEmail
        ..receiverId = receiverId
        ..messageText = messageText
        ..timestamp = now
        ..isRead = 0;

      await db.writeTxn(() => db.chatMessages.put(localMessage));
      debugPrint("🕒 Isar: Clock Icon set");
    } catch (e) {
      debugPrint("❌ Isar Error: $e");
      return;
    }

    // 2. FIRESTORE SEND (Status 1 = Single Tick)
    try {
      await messageRef.set({
        'receiverID': receiverId,
        'senderEmail': currentUserEmail,
        'senderId': currentUserId,
        'timestamp': Timestamp.fromDate(now),
        'message': messageText,
        'messageId': generatedFirebaseId,
        'isRead': 1,
      });

      final db = IsarService.isar;
      final savedMessage = await db.chatMessages
          .filter()
          .firebaseIdEqualTo(generatedFirebaseId)
          .findFirst();

      if (savedMessage != null) {
        await db.writeTxn(() async {
          await db.chatMessages.put(savedMessage);
        });
      }
      debugPrint("✅ Firebase: Single Tick set");
    } catch (e) {
      debugPrint("📡 Offline: Status remains 0 (Clock)");
    }
  }

  Stream<List<ChatMessage>> getHybridMessages(
    String senderId,
    String receiverId,
  ) async* {
    List<String> ids = [senderId, receiverId]..sort();
    String chatRoomId = ids.join('_');
    final isar = IsarService.isar;

    // STEP 1: Pehle local messages ka stream dein (Ye instant hoga)
    yield* isar.chatMessages
        .filter()
        .chatRoomIdEqualTo(chatRoomId)
        .sortByTimestamp()
        .watch(fireImmediately: true)
        .handleError((e) => debugPrint("Stream Error: $e"))
        .asyncMap((localMsgs) async {
          // STEP 2: Background mein Firebase se sync karein (Lekin yield ko block na karein)
          _syncMessagesFromFirebase(chatRoomId);

          return localMsgs;
        });
  }

  // Ek alag function sync ke liye taake stream delay na ho
  Future<void> _syncMessagesFromFirebase(String chatRoomId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final firebaseId = doc.id;
          final int firestoreStatus =
              data['isRead'] ?? 1; // Firebase se status lo

          final existing = await isar.chatMessages
              .filter()
              .firebaseIdEqualTo(firebaseId)
              .findFirst();

          if (existing == null) {
            // Naya message save karein
            final msg = ChatMessage()
              ..firebaseId = firebaseId
              ..chatRoomId = chatRoomId
              ..senderId = data['senderId']
              ..messageText = data['message']
              ..isRead =
                  firestoreStatus // Firebase wala status
              ..timestamp = (data['timestamp'] as Timestamp).toDate();
            await isar.chatMessages.put(msg);
          } else if (existing.isRead != firestoreStatus) {
            existing.isRead = firestoreStatus;
            await isar.chatMessages.put(existing);
          }
        }
      });
    } catch (e) {
      debugPrint("Firebase Sync Error: $e");
    }
  }

  Future<void> updateMessageStatus(
    String chatRoomId,
    String messageId,
    int status,
  ) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': status});
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getCurrentUserAddedUsers(
    String currentUserEmail,
    String currentUserId,
  ) async* {
    final isar = IsarService.isar;

    yield* isar.contacts
        .filter()
        .ownerIdEqualTo(currentUserId)
        .watch(fireImmediately: true)
        .asyncMap((contacts) async {
          try {
            final snapshot = await FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUserId)
                .collection('AddedUser')
                .get(const GetOptions(source: Source.serverAndCache));
            // Ye internet hone par server se, warna cache se layega

            if (snapshot.docs.isNotEmpty) {
              await isar.writeTxn(() async {
                for (var doc in snapshot.docs) {
                  final data = doc.data();
                  final String fUid = data['uid'];

                  // Duplicate check
                  final existing = await isar.contacts
                      .filter()
                      .contactIdEqualTo(fUid)
                      .and()
                      .ownerIdEqualTo(currentUserId)
                      .findFirst();

                  final contact = Contact()
                    ..contactId = fUid
                    ..ownerId = currentUserId
                    ..contactName = data['Name']
                    ..contactEmail = data['Email'];

                  if (existing != null) contact.id = existing.id;

                  await isar.contacts.put(contact);
                }
              });
            }
          } catch (e) {
            debugPrint("Firestore Sync Error: $e");
          }

          return contacts
              .map(
                (c) => {
                  'uid': c.contactId,
                  'Name': c.contactName,
                  'Email': c.contactEmail,
                },
              )
              .toList();
        });
  }

  void listenForDeliveryStatus() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final String myId = user.uid;

    try {
      firestore
          .collectionGroup('messages')
          .where('receiverID', isEqualTo: myId)
          .where('isRead', isEqualTo: 1)
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isNotEmpty) {
                WriteBatch batch = firestore.batch();

                for (var doc in snapshot.docs) {
                  batch.update(doc.reference, {'isRead': 2});
                }

                batch.commit().catchError((e) {
                  debugPrint(" Batch Update Error: $e");
                });
              }
            },
            onError: (error) {
              debugPrint(" Firestore Index Error: $error");
            },
          );
    } catch (e) {
      debugPrint(" Listener Exception: $e");
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

      if (currentUserQuery.docs.isEmpty) return;
      final currentUserDoc = currentUserQuery.docs.first;
      final currentUserId = currentUserDoc.id;

      final addUserQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      if (addUserQuery.docs.isEmpty) {
        print("User not found in Firebase");
        return;
      }

      final addedUserDoc = addUserQuery.docs.first;
      final addedUserId = addedUserDoc.id;
      final addedUserName = addedUserDoc['username'];
      final addedUserEmail = addedUserDoc['email'];

      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        final existing = await isar.contacts
            .filter()
            .contactIdEqualTo(addedUserId)
            .and()
            .ownerIdEqualTo(currentUserId)
            .findFirst();

        final newLocalContact = Contact()
          ..contactId = addedUserId
          ..ownerId = currentUserId
          ..contactName = addedUserName
          ..contactEmail = addedUserEmail;

        if (existing != null) {
          newLocalContact.id = existing.id;
        }

        await isar.contacts.put(newLocalContact);
      });
      print("✅ Local Isar contact added!");

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .collection('AddedUser')
          .doc(addedUserId)
          .set({
            'Name': addedUserName,
            'Email': addedUserEmail,
            'uid': addedUserId,
            'addedAt': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(addedUserId)
          .collection('AddedUser')
          .doc(currentUserId)
          .set({
            'Name': currentUserDoc['username'],
            'Email': currentUserDoc['email'],
            'uid': currentUserId,
            'addedAt': FieldValue.serverTimestamp(),
          });

      print("✅ Cloud Firebase linked successfully!");
    } catch (e) {
      print("❌ Error in addOrUpdateUser: $e");
    }
  }

  Future<void> editMessage(
    String newMessage,
    String roomId,
    String messageId,
  ) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId)
          .update({'message': newMessage, 'isEdited': true});

      final isar = IsarService.isar;
      final localMsg = await isar.chatMessages
          .filter()
          .firebaseIdEqualTo(messageId)
          .findFirst();

      if (localMsg != null) {
        await isar.writeTxn(() async {
          localMsg.messageText = newMessage;
          await isar.chatMessages.put(localMsg);
        });
        debugPrint("✅ Firestore and Isar updated!");
      }
    } catch (e) {
      debugPrint("❌ Update Error: $e");
    }
  }

  Future<void> deleteMessage(
    String chatRoomId,
    String fId,
    String isarId,
  ) async {
    try {
      int? localId = int.tryParse(isarId);

      if (localId == null) {
        return;
      }

      final db = IsarService.isar;
      await db.writeTxn(() => db.chatMessages.delete(localId));

      if (fId.isNotEmpty) {
        await firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc(fId)
            .delete();
      }
    } catch (e) {
      debugPrint("❌ Delete error: $e");
    }
  }

  Future<void> reSyncMessage(ChatMessage msg) async {
    try {
      final docSnapshot = await firestore
          .collection('chat_rooms')
          .doc(msg.chatRoomId)
          .collection('messages')
          .doc(msg.firebaseId)
          .get();

      if (docSnapshot.exists) {
        debugPrint(
          " Message pehle se Firestore par hai. Sirf Isar update kar rahe hain.",
        );
      } else {
        await firestore
            .collection('chat_rooms')
            .doc(msg.chatRoomId)
            .collection('messages')
            .doc(msg.firebaseId)
            .set({
              'receiverID': msg.receiverId,
              'senderEmail': msg.senderEmail,
              'senderId': msg.senderId,
              'timestamp': Timestamp.fromDate(msg.timestamp),
              'message': msg.messageText,
              'messageId': msg.firebaseId,
            });
      }

      final db = IsarService.isar;
      await db.writeTxn(() async {
        await db.chatMessages.put(msg);
      });
      debugPrint("✅ Background Sync Success: ${msg.firebaseId}");
    } catch (e) {
      debugPrint("❌ Background Sync Retry Failed: $e");
    }
  }
}
