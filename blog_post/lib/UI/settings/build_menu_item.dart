import 'package:flutter/material.dart';

class BuildMenuItem extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BuildMenuItem(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(minimumSize: WidgetStateProperty.all(Size(200, 50))),
      child: Text(text, style: const TextStyle(fontSize: 17)),
    );
  }
}
