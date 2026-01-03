import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChatEditService {
  void editMessage(
    dynamic message,
    Map<String, dynamic> data, {
    required BuildContext context,
    required Function(String) onSave,
    Widget Function(TextEditingController)? customTextField,
    String? dialogTitle,
    String? cancelButtonText,
    String? saveButtonText,
    InputDecoration? inputDecoration,
    int? maxLines,
    bool? autofocus,
  }) {
    TextEditingController editController = TextEditingController(
      text: message,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle ?? 'Edit Message'),
          content: customTextField != null
              ? customTextField(editController)
              : TextField(
                  controller: editController,
                  decoration:
                      inputDecoration ??
                      const InputDecoration(
                        hintText: 'Enter your message',
                        border: OutlineInputBorder(),
                      ),
                  maxLines: maxLines,
                  autofocus: autofocus ?? true,
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(cancelButtonText ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  onSave(editController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text(saveButtonText ?? 'Save'),
            ),
          ],
        );
      },
    );
  }

  void copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));

    Get.snackbar(
      'Copied',
      'Copied Message',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[800],
      colorText: Colors.white,
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      icon: Icon(Icons.check_circle, color: Colors.green),
      duration: Duration(seconds: 1),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  void showDeleteDialog({
    required BuildContext context,
    required Function() onDelete,
    String? title,
    String? message,
    String? cancelButtonText,
    String? deleteButtonText,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Delete Message'),
          content: Text(
            message ??
                'Are you sure you want to delete this message?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelButtonText ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(deleteButtonText ?? 'Delete'),
            ),
          ],
        );
      },
    );
  }

  // Success Message
  void showSuccessMessage(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[700],
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 1),
    );
  }

  // Error Message
  void showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[700],
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 1),
    );
  }
}
