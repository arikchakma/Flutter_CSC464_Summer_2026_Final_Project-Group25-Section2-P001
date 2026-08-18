import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

import 'package:final_project/models/message_model.dart';
import 'package:final_project/utility/constant.dart';
import 'package:final_project/utility/title_helper.dart';

class MessageProvider with ChangeNotifier {
  final CollectionReference _chats = FirebaseFirestore.instance.collection(
    AppConstant.chatsCollection,
  );

  StreamSubscription<QuerySnapshot>? _subscription;

  String? chatId;
  List<MessageModel> messages = [];
  bool isLoading = true;
  bool isSending = false;
  String streamingReply = '';
  String? error;

  CollectionReference get _messages =>
      _chats.doc(chatId).collection(AppConstant.messagesCollection);

  void openChat(String id) {
    chatId = id;
    messages = [];
    isLoading = true;
    isSending = false;
    streamingReply = '';
    error = null;

    _subscription?.cancel();

    _subscription = _messages
        .orderBy('timestamp')
        .snapshots()
        .listen(
          (snapshot) {
            messages = snapshot.docs
                .map(
                  (doc) => MessageModel.fromJson(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();
            isLoading = false;
            notifyListeners();
          },
          onError: (_) {
            isLoading = false;
            error = 'Could not load this conversation.';
            notifyListeners();
          },
        );

    notifyListeners();
  }

  Future<void> sendMessage(String text, String language) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isSending || chatId == null) return;

    final userMessage = MessageModel(
      id: '',
      sender: AppConstant.senderUser,
      message: trimmed,
      timestamp: DateTime.now(),
    );

    final isFirstMessage = messages.isEmpty;

    isSending = true;
    error = null;
    notifyListeners();

    try {
      await _messages.add(userMessage.toJson());
      await _updateChatPreview(trimmed);
    } catch (_) {
      isSending = false;
      error = 'Could not save your message.';
      notifyListeners();
      return;
    }

    if (isFirstMessage) {
      await _generateChatTitle(language, trimmed);
    }

    await _requestReply(language, [...messages, userMessage]);
  }

  Future<void> retry(String language) async {
    if (isSending || messages.isEmpty) return;

    isSending = true;
    error = null;
    notifyListeners();

    await _requestReply(language, messages);
  }

  Future<void> _requestReply(
    String language,
    List<MessageModel> history,
  ) async {
    if (history.isEmpty) return;

    streamingReply = '';
    notifyListeners();

    final buffer = StringBuffer();

    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: AppConstant.geminiModel,
        systemInstruction: Content.system(
          AppConstant.tutorInstruction(language),
        ),
        generationConfig: GenerationConfig(
          thinkingConfig: ThinkingConfig.withThinkingLevel(
            ThinkingLevel.minimal,
          ),
        ),
      );

      final chat = model.startChat(
        history: history
            .take(history.length - 1)
            .map(
              (message) => message.isUser
                  ? Content.text(message.message)
                  : Content.model([TextPart(message.message)]),
            )
            .toList(),
      );

      final replies = chat.sendMessageStream(
        Content.text(history.last.message),
      );

      await for (final reply in replies) {
        final chunk = reply.text ?? '';
        if (chunk.isEmpty) continue;

        buffer.write(chunk);
        streamingReply = buffer.toString();
        notifyListeners();
      }
    } on FirebaseAIException catch (_) {
      error = 'The tutor is busy right now. Please try again.';
    } catch (_) {
      error = 'Could not reach the tutor. Please try again.';
    }

    final reply = buffer.toString().trim();

    if (error == null && reply.isEmpty) {
      error = 'The tutor did not send a reply.';
    }

    if (error == null) {
      await _saveReply(reply);
    }

    streamingReply = '';
    isSending = false;
    notifyListeners();
  }

  Future<void> _saveReply(String reply) async {
    final aiMessage = MessageModel(
      id: 'pending',
      sender: AppConstant.senderAi,
      message: reply,
      timestamp: DateTime.now(),
    );

    messages = [...messages, aiMessage];
    streamingReply = '';
    isSending = false;
    notifyListeners();

    await _messages.add(aiMessage.toJson());
    await _updateChatPreview(reply);
  }

  Future<void> _generateChatTitle(String language, String firstMessage) async {
    final id = chatId;
    if (id == null) return;

    final title = await TitleHelper.generateChatTitle(language, firstMessage);
    if (title.isEmpty) return;

    try {
      await _chats.doc(id).update({'title': title});
    } catch (_) {
      // A missing title is not worth interrupting the conversation for.
    }
  }

  Future<void> _updateChatPreview(String lastMessage) async {
    await _chats.doc(chatId).update({
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    chatId = null;
    messages = [];
    isLoading = true;
    isSending = false;
    streamingReply = '';
    error = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
