import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String id;
  final String text;
  final String uid;
  final bool isMyMessage;
  final DateTime? time;
  final AnimationController animationController;

  const ChatMessage({
    super.key,
    required this.id,
    required this.text,
    required this.uid,
    required this.isMyMessage,
    required this.animationController,
    this.time,
  });

  ChatMessage copyWith({String? text, AnimationController? animationController}) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      uid: uid,
      isMyMessage: isMyMessage,
      time: time,
      animationController: animationController ?? this.animationController,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = isMyMessage ? colors.primary : colors.surfaceContainerHighest;
    final fg = isMyMessage ? colors.onPrimary : colors.onSurface;
    const r = Radius.circular(18);
    const tail = Radius.circular(4);

    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        child: Align(
          alignment:
              isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: r,
                  topRight: r,
                  bottomLeft: isMyMessage ? r : tail,
                  bottomRight: isMyMessage ? tail : r,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text, style: TextStyle(color: fg, fontSize: 15)),
                  if (time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(time!.toLocal()),
                      style: TextStyle(
                          color: fg.withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
