import 'package:chat_app_provider/Themes/theme_provider.dart';
import 'package:chat_app_provider/services/chat/chat_local_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final int isRead;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  final bool isDelivered;
  final DateTime time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isRead,
    required this.isCurrentUser,
    this.onEdit,
    this.onCopy,
    this.onDelete,
    required this.isDelivered,
    required this.time,
  });
  final int testStatus = 1;
  Widget buildStatusIcon(int status) {
    if (!isCurrentUser) return const SizedBox();

    switch (status) {
      case 0: // Pending
        return const Icon(
          Icons.access_time,
          size: 12,
          color: Colors.white70,
        );
      case 1: // Sent (Cloud)
        return const Icon(
          Icons.done,
          size: 20,
          color: Colors.white70,
        );
      case 2: // Delivered
        return const Icon(
          Icons.done_all,
          size: 20,
          color: Colors.white70,
        );
      case 3: // Seen
        return const Icon(
          Icons.done_all,
          size: 20,
          color: Colors.blue,
        );
      default:
        return const Icon(
          Icons.access_time,
          size: 15,
          color: Colors.white70,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final TextStyle menuTextStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    return Row(
      mainAxisAlignment: isCurrentUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCurrentUser)
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              FocusScope.of(context).unfocus();
              ChatLocalService().menusheet(
                LongPressStartDetails(
                  globalPosition: details.globalPosition,
                ),
                menuTextStyle,
                context,
                onEdit: onEdit ?? () {},
                onDelete: onDelete ?? () {},
                onCopy: onCopy ?? () {},
              );
            },
            child: const Icon(Icons.more_vert, color: Colors.grey),
          ),

        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? (isDarkMode
                        ? Colors.green.shade600
                        : Colors.green.shade500)
                  : (isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),

            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isCurrentUser
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontSize: 14,
                          color: isCurrentUser
                              ? Colors.white
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isCurrentUser) buildStatusIcon(isRead),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
