// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'chat_bubble.dart';

class MyMessageEdit extends StatelessWidget {
  final String message;
  final String userId;
  final bool isCurrentUser;
  final Alignment alignment;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  const MyMessageEdit({
    super.key,
    required this.message,
    required this.userId,
    required this.isCurrentUser,
    required this.alignment,
    this.onEdit,
    this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: 18,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx - 150,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.grey[700]!, width: 0.2),
          ),
          elevation: 4,
          items: [
            PopupMenuItem(
              child: Row(
                children: [
                  Text('Edit', style: textStyle),
                  Spacer(),
                  Icon(Icons.edit, color: Colors.green),
                ],
              ),
              onTap: onEdit,
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Text('Copy', style: textStyle),
                  Spacer(),
                  Icon(Icons.copy, color: Colors.orange),
                ],
              ),
              onTap: onCopy,
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Text('Delete', style: textStyle),
                  Spacer(),

                  Icon(Icons.delete, color: Colors.red),
                ],
              ),
              onTap: onDelete,
            ),
          ],
        );
      },
      child: Container(
        alignment: alignment,
        child: ChatBubble(
          message: message,
          isCurrentUser: isCurrentUser,
        ),
      ),
    );
  }
}
