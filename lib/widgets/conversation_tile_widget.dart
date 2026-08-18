import 'package:flutter/material.dart';

import 'package:final_project/models/chat_model.dart';
import 'package:final_project/utility/constant.dart';
import 'package:final_project/utility/date_helper.dart';

class ConversationTileWidget extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationTileWidget({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final preview = chat.lastMessage.isEmpty
        ? 'No messages yet'
        : chat.lastMessage;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    flagForLanguage(chat.language),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatUpdatedAt(chat.updatedAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: scheme.onSurfaceVariant,
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
