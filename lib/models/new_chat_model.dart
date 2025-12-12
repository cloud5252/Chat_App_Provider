class NewChatModel {
  final String userEmail;
  final String userName;
  // final String userId;
  // final String massage;
  // final Timestamp timestamp;

  NewChatModel({
    required this.userEmail,
    required this.userName,
    // required this.userId,
    // required this.senderId,
    // required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': userEmail,
      'senderEmail': userName,
      // 'receiverID': userId,
      // 'message': massage,
      // 'timestamp': Timestamp.now(),
    };
  }
}
