import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'dart:async';

class ErrorMessage extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final Color color;

  ErrorMessage({
    required this.message,
    required this.onClose,
    this.color = Colors.red, // Default to red if not specified
  });

  @override
  _ErrorMessageState createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<ErrorMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Start a timer to close the message after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        _controller.forward().then((_) {
          widget.onClose();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _controller.isCompleted ? 0.0 : 1.0,
      duration: const Duration(seconds: 1),
      child: Container(
        color: widget.color, // Use the provided color
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                HeroIcon(
                  HeroIcons.exclamationCircle,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: HeroIcon(
                  HeroIcons.xCircle,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: widget.onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
