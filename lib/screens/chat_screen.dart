import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/models/chat_model.dart';
import 'package:final_project/models/message_model.dart';
import 'package:final_project/state_management/chat_provider.dart';
import 'package:final_project/state_management/message_provider.dart';
import 'package:final_project/utility/constant.dart';
import 'package:final_project/widgets/error_banner_widget.dart';
import 'package:final_project/widgets/message_bubble_widget.dart';
import 'package:final_project/widgets/message_composer_widget.dart';
import 'package:final_project/widgets/typing_indicator_widget.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().openChat(widget.chat.id);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    _controller.clear();

    await context.read<MessageProvider>().sendMessage(
      text,
      widget.chat.language,
    );
  }

  ChatModel _currentChat(BuildContext context) {
    for (final chat in context.watch<ChatProvider>().chats) {
      if (chat.id == widget.chat.id) return chat;
    }

    return widget.chat;
  }

  @override
  Widget build(BuildContext context) {
    final chat = _currentChat(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(chat.title),
            Text(
              '${AppConstant.flagForLanguage(widget.chat.language)} ${widget.chat.language}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, provider, child) {
          _scrollToBottom();

          return Column(
            children: [
              Expanded(child: _buildMessages(provider)),
              if (provider.error != null)
                ErrorBannerWidget(
                  message: provider.error!,
                  onRetry: () => provider.retry(widget.chat.language),
                ),
              MessageComposerWidget(
                controller: _controller,
                isSending: provider.isSending,
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessages(MessageProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isStreaming = provider.streamingReply.isNotEmpty;
    final isTyping = provider.isSending && !isStreaming;
    final hasPending = isStreaming || isTyping;

    if (provider.messages.isEmpty && !hasPending) {
      final scheme = Theme.of(context).colorScheme;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstant.flagForLanguage(widget.chat.language),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Say hello to start practising ${widget.chat.language}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: provider.messages.length + (hasPending ? 1 : 0),
      itemBuilder: (context, index) {
        if (hasPending && index == 0) {
          if (isTyping) return const TypingIndicatorWidget();

          return MessageBubbleWidget(
            message: MessageModel(
              id: 'streaming',
              sender: AppConstant.senderAi,
              message: provider.streamingReply,
              timestamp: DateTime.now(),
            ),
          );
        }

        final position = hasPending ? index - 1 : index;

        return MessageBubbleWidget(
          message: provider.messages[provider.messages.length - 1 - position],
        );
      },
    );
  }

}
