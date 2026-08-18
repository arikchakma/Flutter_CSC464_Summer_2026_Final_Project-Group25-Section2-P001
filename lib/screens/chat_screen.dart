import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/models/chat_model.dart';
import 'package:final_project/models/message_model.dart';
import 'package:final_project/state_management/message_provider.dart';
import 'package:final_project/utility/constant.dart';
import 'package:final_project/widgets/message_bubble_widget.dart';
import 'package:final_project/widgets/message_composer_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.chat.title),
            Text(
              '${flagForLanguage(widget.chat.language)} ${widget.chat.language}',
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
                _ErrorBanner(
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
                flagForLanguage(widget.chat.language),
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
          if (isTyping) return const _TypingIndicator();

          return MessageBubbleWidget(
            message: MessageModel(
              id: 'streaming',
              sender: senderAi,
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

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final t = (_controller.value - index * 0.2) % 1.0;
                final lift = t < 0.5 ? t * 2 : (1 - t) * 2;

                return Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
                  child: Transform.translate(
                    offset: Offset(0, -3 * lift),
                    child: Container(
                      height: 7,
                      width: 7,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withValues(
                          alpha: 0.4 + 0.6 * lift,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: scheme.onErrorContainer),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
