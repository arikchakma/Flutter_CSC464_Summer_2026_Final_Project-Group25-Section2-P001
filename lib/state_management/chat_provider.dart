import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:final_project/models/chat_model.dart';
import 'package:final_project/utility/constant.dart';

class ChatProvider with ChangeNotifier {
  final CollectionReference _chats = FirebaseFirestore.instance.collection(
    chatsCollection,
  );

  StreamSubscription<QuerySnapshot>? _subscription;

  String? userId;
  List<ChatModel> chats = [];
  bool isLoading = true;
  String? error;
  ChatModel? selectedChat;

  void setUser(String? uid) {
    if (userId == uid) return;

    userId = uid;
    chats = [];
    selectedChat = null;
    error = null;

    if (uid == null) {
      _subscription?.cancel();
      _subscription = null;
      isLoading = false;
      return;
    }

    isLoading = true;
    loadChats();
  }

  void loadChats() {
    _subscription?.cancel();

    if (userId == null) return;

    _subscription = _chats
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            chats = snapshot.docs
                .map(
                  (doc) => ChatModel.fromJson(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();
            isLoading = false;
            error = null;
            notifyListeners();
          },
          onError: (_) {
            isLoading = false;
            error = 'Could not load your conversations.';
            notifyListeners();
          },
        );
  }

  Future<ChatModel> createChat(String language) async {
    final now = DateTime.now();

    final chat = ChatModel(
      id: '',
      userId: userId!,
      language: language,
      title: '$language Practice',
      lastMessage: '',
      createdAt: now,
      updatedAt: now,
    );

    final doc = await _chats.add(chat.toJson());

    return ChatModel(
      id: doc.id,
      userId: chat.userId,
      language: chat.language,
      title: chat.title,
      lastMessage: chat.lastMessage,
      createdAt: chat.createdAt,
      updatedAt: chat.updatedAt,
    );
  }

  Future<void> deleteChat(String chatId) async {
    final messages = await _chats
        .doc(chatId)
        .collection(messagesCollection)
        .get();

    for (final message in messages.docs) {
      await message.reference.delete();
    }

    await _chats.doc(chatId).delete();

    if (selectedChat?.id == chatId) selectedChat = null;

    notifyListeners();
  }

  void selectChat(ChatModel? chat) {
    selectedChat = chat;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
