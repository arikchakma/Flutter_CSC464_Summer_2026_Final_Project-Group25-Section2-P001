import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:final_project/models/chat_model.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:final_project/state_management/auth_provider.dart';
import 'package:final_project/state_management/chat_provider.dart';
import 'package:final_project/state_management/message_provider.dart';
import 'package:final_project/widgets/conversation_tile_widget.dart';
import 'package:final_project/widgets/empty_state_widget.dart';
import 'package:final_project/widgets/language_picker_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startConversation(BuildContext context) async {
    final language = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => const LanguagePickerWidget(),
    );

    if (language == null || !context.mounted) return;

    final provider = context.read<ChatProvider>();
    final chat = await provider.createChat(language);

    if (!context.mounted) return;

    _openConversation(context, chat);
  }

  void _openConversation(BuildContext context, ChatModel chat) {
    context.read<ChatProvider>().selectChat(chat);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ChatModel chat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text('"${chat.title}" and its messages will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<ChatProvider>().deleteChat(chat.id);
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your conversations stay saved and will be here when you sign back in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<MessageProvider>().clear();
    await context.read<AuthProvider>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 76,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hi, ${context.watch<AuthProvider>().displayName}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'My Conversations',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              tooltip: 'Sign out',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _confirmSignOut(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startConversation(context),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'New chat',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.chats.isEmpty) {
            return EmptyStateWidget(scheme: Theme.of(context).colorScheme);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: provider.chats.length,
            itemBuilder: (context, index) {
              final chat = provider.chats[index];

              return ConversationTileWidget(
                chat: chat,
                onTap: () => _openConversation(context, chat),
                onDelete: () => _confirmDelete(context, chat),
              );
            },
          );
        },
      ),
    );
  }
}
