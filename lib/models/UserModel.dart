import 'package:isar/isar.dart';

part 'UserModel.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  late String name;
  late String email;
  DateTime? timestamp;
}

@collection
class ChatRoom {
  Id id = Isar.autoIncrement;

  @Index(unique: true, composite: [CompositeIndex('participant2Id')])
  late String participant1Id;

  late String participant2Id;

  String? lastMessage;
  DateTime? lastMessageTime;

  static String generateChatRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  String get chatRoomId =>
      generateChatRoomId(participant1Id, participant2Id);
}

@collection
class ChatMessage {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? firebaseId;

  @Index()
  late String chatRoomId;

  late String senderId;
  late String senderEmail;
  late String receiverId;
  late String messageText;

  @Index()
  late DateTime timestamp;

  late int isRead;
}

@collection
class Contact {
  @Index(unique: true, replace: true)
  Id id = Isar.autoIncrement;

  @Index()
  late String ownerId;

  @Index()
  late String contactId;

  late String contactName;
  late String contactEmail;
}
