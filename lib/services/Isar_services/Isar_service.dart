import 'package:chat_app_provider/models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
 import 'package:path_provider/path_provider.dart';

Isar? _globalIsar;

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  // static Isar? _isar;

  static Isar get isar {
    if (_globalIsar == null) {
      print("❌ ERROR: Isar instance dastiab nahi hai!");
      throw Exception("Isar not initialized");
    }
    return _globalIsar!;
  }

  static Future<void> init() async {
    if (_globalIsar != null && _globalIsar!.isOpen) return;

    final dir = await getApplicationDocumentsDirectory();
    _globalIsar = await Isar.open(
      [
        UserModelSchema,
        ChatRoomSchema,
        ChatMessageSchema,
        ContactSchema
      ],
      directory: dir.path,
    );
    print("🔥 Isar Engine Started and Assigned!");
  }
  // ==================== USER OPERATIONS ====================

  static Future<List<UserModel>> getUser() async {
    return await isar.userModels.where().findAll();
  }

// Isar Service mein
// IsarService.dart
  static Stream<List<UserModel>> watchAllUsers(String currentUserId) {
    return isar.userModels
        .where()
        .filter()
        .not()
        .uidEqualTo(currentUserId, caseSensitive: true)
        .watch(fireImmediately: true);
  }

  static Stream<List<Contact>> watchMyContacts(String myId) {
    return isar.contacts
        .filter()
        .ownerIdEqualTo(myId)  
        .watch(fireImmediately: true);
  }

  static Future<bool> deleteUser(int id) async {
    return await isar.writeTxn(() async {
      return await isar.userModels.delete(id);
    });
  }

  static Future<void> updateUser(UserModel user) async {
    await isar.writeTxn(() async {
      await isar.userModels.put(user);
    });
  }

  static Future<void> addUser(
      BuildContext context, UserModel user) async {
    await isar.writeTxn(() async {
      await isar.userModels.put(user);
    });
  }

  Widget deleteExpancesButton(BuildContext context, int id) {
    return MaterialButton(
      onPressed: () async {
        await deleteUser(id);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: const Text('Delete'),
    );
  }
}
