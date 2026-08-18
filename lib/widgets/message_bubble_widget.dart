import 'package:flutter/material.dart';

import 'package:final_project/models/message_model.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageModel message;

  const MessageBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.message,
          style: TextStyle(
            color: isUser ? scheme.onPrimary : scheme.onSurface,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
