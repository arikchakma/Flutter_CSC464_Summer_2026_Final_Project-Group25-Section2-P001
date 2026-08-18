import 'package:flutter/material.dart';

class MessageComposerWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const MessageComposerWidget({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  State<MessageComposerWidget> createState() => _MessageComposerWidgetState();
}

class _MessageComposerWidgetState extends State<MessageComposerWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText == _hasText) return;

    setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSend = _hasText && !widget.isSending;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => widget.onSend(),
                    style: TextStyle(color: scheme.onSurface, height: 1.35),
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(enabled: canSend, onSend: widget.onSend),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onSend;

  const _SendButton({required this.enabled, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: enabled ? scheme.primary : scheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: enabled ? onSend : null,
        tooltip: 'Send',
        icon: Icon(
          Icons.arrow_upward_rounded,
          size: 22,
          color: enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
