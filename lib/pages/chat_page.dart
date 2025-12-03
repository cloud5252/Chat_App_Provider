import 'package:chat_app_provider/components/My_text_feilds.dart';
import 'package:chat_app_provider/components/chat_bubble.dart';
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

  final ChatService chatService = ChatService();
  final Authentication authentication = Authentication();

  void sendmessage() async {
    if (_messagesController.text.isNotEmpty) {
      await chatService.sendMessages(
        recieverId,
        _messagesController.text,
      );
      _messagesController.clear();
    }
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
              .map((doc) => buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data =
        document.data() as Map<String, dynamic>;

    bool currentUserId =
        data["senderId"] == authentication.getCurrentuser()!.uid;

    var alignment = (currentUserId)
        ? Alignment.topRight
        : Alignment.topLeft;

    return Container(
      alignment: alignment,
      child: ChatBubble(
        message: data['message'],
        isCurrentUser: currentUserId,
      ),
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
