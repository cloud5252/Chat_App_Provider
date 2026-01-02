import 'package:chat_app_provider/models/UserModel.dart';
import 'package:chat_app_provider/services/Isar_services/Isar_chat_service.dart';
import 'package:flutter/material.dart';

class ChatLocalService extends ChangeNotifier {
  static final ChatLocalService _instance =
      ChatLocalService._internal();

  factory ChatLocalService() {
    return _instance;
  }

  ChatLocalService._internal();

  String _chatRoomId = '';
  String get chatRoomId => _chatRoomId;
  Stream<List<ChatMessage>>? _cachedStream;

  Stream<List<ChatMessage>> get messagesStream {
    if (_chatRoomId.isEmpty) return const Stream.empty();
    _cachedStream ??= IsarChatService.watchChatMessages(_chatRoomId);
    return _cachedStream!;
  }

  void updateChatRoomId(String id) {
    if (_chatRoomId == id) return;
    _chatRoomId = id;
    _cachedStream = null;
    notifyListeners();
  }

  Future<void> initializeChatRoom(
    String currentUserId,
    String receiverId,
  ) async {
    if (currentUserId.isEmpty || receiverId.isEmpty) {
      debugPrint("❌ IDs are empty!");
      return;
    }

    try {
      await IsarChatService.getOrCreateChatRoom(
        currentUserId,
        receiverId,
      );
    } catch (e) {
      debugPrint("Chat Room Error: $e");
    }
    notifyListeners();
  }

  // Menusheet function
  void menusheet(
    LongPressStartDetails details,
    TextStyle textStyle,
    BuildContext context, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onCopy,
  }) {
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
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!, width: 2.0),
      ),
      elevation: 4,
      items: [
        PopupMenuItem(
          onTap: onEdit,
          child: Row(
            children: [
              Text('Edit', style: textStyle),
              const Spacer(),
              const Icon(Icons.edit, color: Colors.green, size: 20),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: onCopy,
          child: Row(
            children: [
              Text('Copy', style: textStyle),
              const Spacer(),
              const Icon(Icons.copy, color: Colors.orange, size: 20),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: onDelete,
          child: Row(
            children: [
              Text('Delete', style: textStyle),
              const Spacer(),
              const Icon(Icons.delete, color: Colors.red, size: 20),
            ],
          ),
        ),
      ],
    ).then((value) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
}
