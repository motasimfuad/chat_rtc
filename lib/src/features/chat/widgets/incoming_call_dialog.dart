import 'package:flutter/material.dart';

class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final VoidCallback onAnswer;
  final VoidCallback onReject;

  const IncomingCallDialog({
    Key? key,
    required this.callerName,
    required this.onAnswer,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Incoming Call'),
      content: Text('$callerName is calling you'),
      actions: [
        TextButton(
          onPressed: onReject,
          child: const Text('Reject'),
        ),
        TextButton(
          onPressed: onAnswer,
          child: const Text('Answer'),
        ),
      ],
    );
  }
}
