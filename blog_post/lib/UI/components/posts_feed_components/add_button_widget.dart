import 'package:flutter/material.dart';

class AddPostButton extends StatelessWidget {
  const AddPostButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 16.0,
        right: 16.0,
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ));
  }
}
