import 'package:blog_post/StateManager/postProvider.dart';
import 'package:blog_post/StateManager/profileProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedPostsScreen extends StatelessWidget {
  const FeedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: "Все посты",),
                  Tab(text: "Мои посты",),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Center(child: Icon(Icons.directions_car)),
                    Center(child: Icon(Icons.directions_transit)),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}
