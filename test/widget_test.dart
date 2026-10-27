import 'package:chat/widgets/chat_message.dart';
import 'package:chat/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserAvatar.initials handles short and multi-word names', () {
    expect(UserAvatar.initials('A'), 'A');
    expect(UserAvatar.initials('alexis'), 'AL');
    expect(UserAvatar.initials('Alexis Hurtado'), 'AH');
    expect(UserAvatar.initials('  '), '?');
  });

  testWidgets('ChatMessage renders text and time', (tester) async {
    final controller = AnimationController(
        vsync: const TestVSync(), duration: Duration.zero)
      ..forward();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ChatMessage(
          id: '1',
          text: 'Hola',
          uid: 'u1',
          isMyMessage: true,
          time: DateTime(2024, 1, 1, 9, 5),
          animationController: controller,
        ),
      ),
    ));

    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('09:05'), findsOneWidget);
    controller.dispose();
  });
}
