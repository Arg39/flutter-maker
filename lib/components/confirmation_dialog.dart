import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onCancel;

  ConfirmationDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () async {
            await onCancel();
            Navigator.of(context).pop();
          },
          child: Text('Tidak'),
        ),
        TextButton(
          onPressed: () async {
            await onConfirm();
            Navigator.of(context).pop();
          },
          child: Text('Iya'),
        ),
      ],
    );
  }
}
