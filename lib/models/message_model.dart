import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:final_project/utility/constant.dart';

class MessageModel {
  final String id;
  final String sender;
  final String message;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  bool get isUser => sender == AppConstant.senderUser;

  factory MessageModel.fromJson(String id, Map<String, dynamic> json) {
    return MessageModel(
      id: id,
      sender: json['sender'] ?? AppConstant.senderAi,
      message: json['message'] ?? '',
      timestamp: _parseDate(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
