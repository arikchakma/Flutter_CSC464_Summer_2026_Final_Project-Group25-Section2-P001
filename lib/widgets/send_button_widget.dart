import 'package:flutter/material.dart';

class SendButtonWidget extends StatelessWidget {
  final bool enabled;
  final VoidCallback onSend;

  const SendButtonWidget({
    super.key,
    required this.enabled,
    required this.onSend,
  });

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
