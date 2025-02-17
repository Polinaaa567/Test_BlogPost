import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/components/posts_feed_components/post_group_widget.dart';
import 'package:blog_post/UI/pages/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewingPostScreen extends StatelessWidget {
  const ViewingPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  await postStoreWatch.fetchAllPosts(profileStoreWatch.getEmail);
                  await postStoreWatch.fetchMyPosts(profileStoreWatch.getEmail);
                  postStoreWatch.setIsOnePostInfo();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: postStoreRead.getPostOneInfo!.map((elem) {
                  return PostListWidget(elem: elem);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
