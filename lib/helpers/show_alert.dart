import 'package:flutter/material.dart';

Future<void> showAlert(BuildContext context, String title, String subtitle) {
  return showAdaptiveDialog(
    context: context,
    builder: (dialogContext) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}
