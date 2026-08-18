import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String userId;
  final String language;
  final String title;
  final String lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.userId,
    required this.language,
    required this.title,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(String id, Map<String, dynamic> json) {
    return ChatModel(
      id: id,
      userId: json['userId'] ?? '',
      language: json['language'] ?? '',
      title: json['title'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'language': language,
      'title': title,
      'lastMessage': lastMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
