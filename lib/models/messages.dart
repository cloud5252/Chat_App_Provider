import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  final String senderId;
  final String senderEmail;
  final String receiverID;
  final String massage;
  final Timestamp timestamp;

  Messages({
    required this.massage,
    required this.receiverID,
    required this.senderEmail,
    required this.senderId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': massage,
      'timestamp': Timestamp.now(),
    };
  }
}
