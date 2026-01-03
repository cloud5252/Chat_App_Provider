import 'package:chat_app_provider/models/UserModel.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

void showNoInternetDialog(context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        "No Internet Connection",
        style: TextStyle(fontSize: 20),
      ),
      content: const Text(
        "Please check your internet connection and try again.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

Future<int?> getIsarIdFromFirebaseId(String fId) async {
  final isar = IsarService.isar;

  // Isar se message dhoondein jiski firebaseId match karti ho
  final message = await isar.chatMessages
      .filter()
      .firebaseIdEqualTo(fId)
      .findFirst();

  // Agar message mil jaye toh uski internal id return karein
  return message?.id;
}
