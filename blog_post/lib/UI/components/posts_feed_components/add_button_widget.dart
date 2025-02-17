import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/UI/pages/new_edit_post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPostButton extends StatelessWidget {
  const AddPostButton({super.key});

  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();

    return Positioned(
        bottom: 16.0,
        right: 16.0,
        child: FloatingActionButton(
          onPressed: () {
            postStoreRead.setIsThisEdit(false);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NewEditPostPage()));
          },
          child: const Icon(Icons.add),
        ));
  }
}
