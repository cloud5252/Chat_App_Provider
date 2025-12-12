import 'package:chat_app_provider/components/MY_message_edit.dart';
import 'package:chat_app_provider/components/My_text_feilds.dart';

import 'package:chat_app_provider/services/chat/chat_Edit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth/authentication.dart';
import '../services/chat/chat_service.dart';

class ChatPage extends StatelessWidget {
  final String recieverEmail;
  final String recieverId;
  final String userName;

  ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverId,
    required this.userName,
  });
  final TextEditingController _messagesController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatEditService chatEditService = ChatEditService();
  final ChatService chatService = ChatService();
  final Authentication authentication = Authentication();

  void sendmessage() async {
    if (_messagesController.text.isNotEmpty) {
      String messageText = _messagesController.text;
      _messagesController.clear();

      await chatService.sendMessages(recieverId, messageText);
    }
  }

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        centerTitle: true,

        title: Text(userName),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),

      body: Column(
        children: [
          Expanded(child: buildmessageslist()),
          buildMessageInput(),
        ],
      ),
    );
  }

  Widget buildmessageslist() {
    String senderId = authentication.getCurrentuser()!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(senderId, recieverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!.docs;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
        return ListView(
          controller: _scrollController,
          children: messages
              .map((doc) => buildMessageItem(doc, context))
              .toList(),
        );
      },
    );
  }

  Widget buildMessageItem(
    DocumentSnapshot document,
    BuildContext context,
  ) {
    Map<String, dynamic> data =
        document.data() as Map<String, dynamic>;
    String messageId = document.id;

    bool currentUserId =
        data["senderId"] == authentication.getCurrentuser()!.uid;
    var alignment = (currentUserId)
        ? Alignment.topRight
        : Alignment.topLeft;

    return MyMessageEdit(
      onDelete: () => chatEditService.showDeleteDialog(
        context: context,
        onDelete: () async {
          try {
            String currentUserId = authentication
                .getCurrentuser()!
                .uid;
            String otherUserId = data['senderId'] == currentUserId
                ? data['receiverID']
                : data['senderId'];

            String chatRoomId = getChatRoomId(
              currentUserId,
              otherUserId,
            );

            await chatService.deleteMessage(chatRoomId, messageId);

            chatEditService.showSuccessMessage('Message deleted');
          } catch (e) {
            chatEditService.showErrorMessage(
              'Failed to delete message',
            );
          }
        },
      ),
      onCopy: () =>
          chatEditService.copyToClipboard(data['message'], context),
      onEdit: () => chatEditService.editMessage(
        data['message'] ?? '',
        data,
        context: context,
        onSave: (String editedMessage) async {
          String currentUserId = authentication.getCurrentuser()!.uid;

          String otherUserId = data['senderId'] == currentUserId
              ? data['receiverID']
              : data['senderId'];

          String chatRoomId = getChatRoomId(
            currentUserId,
            otherUserId,
          );

          await chatService.editMessage(
            editedMessage,
            chatRoomId,
            messageId,
          );
        },
        customTextField: (controller) => TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Type your message',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      message: data['message'] ?? '',
      isCurrentUser: currentUserId,
      alignment: alignment,
      userId: currentUserId.toString(),
    );
  }

  Widget buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                  color: Colors.green,
                ),
                child: IconButton(
                  onPressed: sendmessage,
                  icon: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
