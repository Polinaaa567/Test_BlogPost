import 'package:blog_post/UI/navigator_bar/home_screen.dart';
import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/UI/feed_posts/feed_screen/post_group_widget.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewingPostScreen extends StatelessWidget {
  const ViewingPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();


    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  postStoreWatch.setCurrentTab(postStoreWatch.currentTab);

                  postStoreWatch.setIsOnePostInfo();
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => const NavigationBarMenu()),
                        (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: postStoreRead.postOneInfo!.map((elem) {
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
