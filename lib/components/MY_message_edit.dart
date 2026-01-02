// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'chat_bubble.dart';

class MyMessageEdit extends StatelessWidget {
  final String message;
  final String userId;
  final bool isCurrentUser;
  final int isRead;
  final bool isDelivered;
  final DateTime time;
  final Alignment alignment;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  const MyMessageEdit({
    super.key,
    required this.message,
    required this.isDelivered,
    required this.isRead,
    required this.time,
    required this.userId,
    required this.isCurrentUser,
    required this.alignment,
    this.onEdit,
    this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    print(
      "DEBUG: Message:::::::::::::::::::::::::::: $message | isRead: $isRead",
    );
    return Align(
      alignment: isCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: ChatBubble(
          onEdit: onEdit,
          onCopy: onCopy,
          onDelete: onDelete,
          message: message,
          isCurrentUser: isCurrentUser,
          isDelivered: isDelivered,
          time: time,
          isRead: isRead,
        ),
      ),
    );
  }
}
