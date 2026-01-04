import 'package:chat_app_provider/Themes/theme_provider.dart';
import 'package:chat_app_provider/components/MY_message_edit.dart';
import 'package:chat_app_provider/components/My_text_feilds.dart';
import 'package:chat_app_provider/helpers/helpers.dart';
import 'package:chat_app_provider/models/UserModel.dart';
import 'package:chat_app_provider/pages/set_languag.dart';
import 'package:chat_app_provider/services/Ai_service/gemini_translator.dart';
import 'package:chat_app_provider/services/Ai_service/language_provider.dart';

import 'package:chat_app_provider/services/chat/chat_Edit_service.dart';
import 'package:chat_app_provider/services/chat/chat_local_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth/authentication.dart';
import '../services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverId;
  final String userName;
  final String myId;

  const ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverId,
    required this.userName,
    required this.myId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messagesController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatEditService chatEditService = ChatEditService();
  final ChatService chatService = ChatService();
  final Authentication authentication = Authentication();
  late Stream<List<dynamic>> _messageStream;

  @override
  void initState() {
    super.initState();
    List<String> ids = [widget.myId, widget.recieverId];
    ids.sort();
    String roomID = ids.join('_');
    _messageStream = chatService.getHybridMessages(
      authentication.getCurrentuser()!.uid,
      widget.recieverId,
    );
    ChatLocalService().updateChatRoomId(roomID);
    ChatLocalService().initializeChatRoom(
      widget.myId,
      widget.recieverId,
    );
  }

  bool _isLoading = false;
  void sendmessage() async {
    String originalText = _messagesController.text.trim();
    if (originalText.isEmpty) return;

    _messagesController.clear();
    bool isEnglish = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).isEnglishMode;

    if (isEnglish) {
      var connectivityResult = await (Connectivity()
          .checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _messagesController.text = originalText;
        showNoInternetDialog(context);
        return;
      }
    }

    _processAndSendMessage(originalText, isEnglish);
  }

  Future<void> _processAndSendMessage(
    String text,
    bool isEnglish,
  ) async {
    String messageToFinalSend = text;

    try {
      if (isEnglish) {
        setState(() => _isLoading = true);
        messageToFinalSend =
            await GeminiTranslator.translateToEnglish(text);
        setState(() => _isLoading = false);
      }

      await chatService.sendMessages(
        widget.recieverId,
        messageToFinalSend,
      );
    } catch (e) {
      debugPrint("Send Error: $e");
      setState(() => _isLoading = false);
    }
  }

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          centerTitle: true,

          title: Text(widget.userName),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
          actions: [
            PopupMenuButton<String>(
              color: isDarkMode
                  ? Colors.grey.shade600
                  : Colors.grey.shade300,

              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isDarkMode
                      ? Colors.white24
                      : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              onOpened: () {
                FocusScope.of(context).unfocus();
              },
              onCanceled: () {
                Future.delayed(const Duration(milliseconds: 5), () {
                  if (mounted) FocusScope.of(context).unfocus();
                });
              },
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'Setting') {}
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Setting',
                  enabled: true,
                  height: kMinInteractiveDimension,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetLanguag(),
                      ),
                    );
                  },
                  child: Text('Setting'),
                ),
              ],
            ),
          ],
        ),

        body: Column(
          children: [
            Expanded(child: buildmessageslist()),
            buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget buildmessageslist() {
    return StreamBuilder<List<dynamic>>(
      stream: _messageStream,

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data ?? [];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            Map<String, dynamic> data;

            if (message is ChatMessage) {
              data = {
                'senderId': message.senderId,
                'receiverID': message.receiverId,
                'message': message.messageText,
                'timestamp': message.timestamp,
                'id': message.id.toString(), // Isar ID
                'messageId': message.firebaseId,
                'isRead': message.isRead,
              };
            } else {
              data = message as Map<String, dynamic>;
              data['id'] = data['id'] ?? '';
            }

            return buildMessageItem(data, context);
          },
        );
      },
    );
  }

  Widget buildMessageItem(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    // 1. Basic Data Extraction
    final String myId = authentication.getCurrentuser()!.uid;
    final String messageText = data['message'] ?? '';
    final String senderId = data['senderId'] ?? '';
    final String messageId = data['messageId'] ?? data['id'] ?? '';
    final DateTime timestamp = data['timestamp'] ?? DateTime.now();

    final bool isCurrentUser = (senderId == myId);
    final bool isDelivered = data['isDelivered'] ?? false;

    int currentStatus = 0;
    if (data['isRead'] != null) {
      currentStatus = data['isRead'] is int
          ? data['isRead']
          : (int.tryParse(data['isRead'].toString()) ?? 0);
    }

    final String otherUserId = isCurrentUser
        ? (data['receiverID'] ?? "")
        : senderId;
    final String chatRoomId = getChatRoomId(myId, otherUserId);

    if (!isCurrentUser && currentStatus < 3 && messageId.isNotEmpty) {
      chatService.updateMessageStatus(chatRoomId, messageId, 3);
    }

    final alignment = isCurrentUser
        ? Alignment.topRight
        : Alignment.topLeft;

    Future<void> handleDelete() async {
      final String isarIdStr = data['id']?.toString() ?? "";
      final String firebaseIdStr =
          data['messageId']?.toString() ?? "";

      if (isarIdStr.isNotEmpty) {
        await chatService.deleteMessage(
          chatRoomId,
          firebaseIdStr,
          isarIdStr,
        );
      }
    }

    Future<void> handleEdit(String editedMessage) async {
      await chatService.editMessage(
        editedMessage,
        chatRoomId,
        messageId.toString(),
      );
    }

    return MyMessageEdit(
      message: messageText,
      isCurrentUser: isCurrentUser,
      alignment: alignment,
      userId: senderId,
      isRead: currentStatus,
      isDelivered: isDelivered,
      time: timestamp,
      onDelete: () => chatEditService.showDeleteDialog(
        context: context,
        onDelete: () async {
          await handleDelete();
        },
      ),
      onCopy: () =>
          chatEditService.copyToClipboard(messageText, context),
      onEdit: () => chatEditService.editMessage(
        messageText,
        data,
        context: context,
        onSave: (val) => handleEdit(val),
        customTextField: (controller) => TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Type your message',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MyTextFeilds(
                  controller: _messagesController,
                  obsecurtext: false,
                  hinttext: 'Write here',
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.shade400,
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: sendmessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
