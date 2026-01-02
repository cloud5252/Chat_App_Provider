import 'dart:async';

import 'package:chat_app_provider/models/UserModel.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';

class IsarChatService {
  static Isar get isar => IsarService.isar;

  // ==================== USER OPERATIONS ====================

  static Stream<List<UserModel>> watchUsers() {
    return isar.userModels.where().watch(fireImmediately: true);
  }

  static Future<void> saveUser(UserModel user) async {
    await isar.writeTxn(() => isar.userModels.put(user));
  }

  // IsarChatService.dart mein add karein
  static Future<UserModel?> findUserByEmail(String email) async {
    return await isar.userModels
        .filter()
        .emailEqualTo(email, caseSensitive: false)
        .findFirst();
  }

  // ======= ======== CHAT ROOM OPERATIONS ========= =======

  static Future<ChatRoom> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final ids = [currentUserId, otherUserId]..sort();

    // Check if exists
    final existingRoom = await isar.chatRooms
        .where()
        .filter()
        .participant1IdEqualTo(ids[0])
        .and()
        .participant2IdEqualTo(ids[1])
        .findFirst();

    if (existingRoom != null) return existingRoom;

    final newRoom = ChatRoom()
      ..participant1Id = ids[0]
      ..participant2Id = ids[1]
      ..lastMessageTime = DateTime.now();

    await isar.writeTxn(() => isar.chatRooms.put(newRoom));
    return newRoom;
  }

  // ================  MESSAGE OPERATIONS ===============

  static Future<void> sendMessage({
    required String senderEmail,
    required String senderId,
    required String receiverId,
    required String messageText,
  }) async {
    try {
      // 1. Pehle instance check karein
      final db = IsarService.isar;

      List<String> ids = [senderId, receiverId]..sort();
      String generatedRoomId = ids.join('_');

      final message = ChatMessage()
        ..chatRoomId = generatedRoomId
        ..senderId = senderId
        ..senderEmail = senderEmail
        ..receiverId = receiverId
        ..messageText = messageText
        ..timestamp = DateTime.now();

      await db.writeTxn(() async {
        await db.chatMessages.put(message);

        final chatRoom = await db.chatRooms
            .filter()
            .participant1IdEqualTo(ids[0])
            .and()
            .participant2IdEqualTo(ids[1])
            .findFirst();

        if (chatRoom != null) {
          chatRoom.lastMessage = messageText;
          chatRoom.lastMessageTime = DateTime.now();
          await db.chatRooms.put(chatRoom);
        }
      });

      debugPrint("✅ Message Sent Successfully!");
    } catch (e) {
      debugPrint("❌ Send Message Failed: $e");
    }
  }

  static Stream<List<ChatMessage>> watchChatMessages(
    String chatRoomId,
  ) {
    return isar.chatMessages
        .filter()
        .chatRoomIdEqualTo(chatRoomId)
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  Future<void> addContact(
    UserModel otherUser,
    String myId,
    String myName,
    String myEmail,
  ) async {
    final db = IsarService.isar;

    final contactForMe = Contact()
      ..ownerId = myId
      ..contactId = otherUser.uid
      ..contactName = otherUser.name
      ..contactEmail = otherUser.email;

    final contactForOther = Contact()
      ..ownerId = otherUser.uid
      ..contactId = myId
      ..contactName = myName
      ..contactEmail = myEmail;

    await db.writeTxn(() async {
      final existing = await db.contacts
          .filter()
          .ownerIdEqualTo(myId)
          .and()
          .contactIdEqualTo(otherUser.uid)
          .findFirst();

      if (existing == null) {
        await db.contacts.put(contactForMe);
        await db.contacts.put(contactForOther);
        debugPrint("✅ Both users linked in Isar!");
      }
    });
  }

  // IsarChatService.dart mein
  Future<void> addContacts(
    UserModel otherUser,
    String myId,
    String myName,
    String myEmail,
  ) async {
    final db = IsarService.isar;

    // 1. ISAR (LOCAL) SAVE
    final contactForMe = Contact()
      ..ownerId = myId
      ..contactId = otherUser.uid
      ..contactName = otherUser.name
      ..contactEmail = otherUser.email;
    final contactForOther = Contact()
      ..ownerId = otherUser.uid
      ..contactId = myId
      ..contactName = myName
      ..contactEmail = myEmail;

    await db.writeTxn(() async {
      await db.contacts.put(contactForMe);
      await db.contacts.put(contactForOther);
      debugPrint("✅ Both users linked in Isar!");
    });

    // 2. FIRESTORE (CLOUD) SAVE
    // Mere 'AddedUser' collection mein dost ko add karna
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(myId)
        .collection('AddedUser')
        .doc(otherUser.uid)
        .set({
          'uid': otherUser.uid,
          'Name': otherUser.name,
          'Email': otherUser.email,
          'addedAt': FieldValue.serverTimestamp(),
        });

    // Dost ke 'AddedUser' collection mein mujhe add karna (Mutual)
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(otherUser.uid)
        .collection('AddedUser')
        .doc(myId)
        .set({
          'uid': myId,
          'Name': myName,
          'Email': myEmail,
          'addedAt': FieldValue.serverTimestamp(),
        });
  }

  // HomeViewModel.dart mein ye function add karein
}
