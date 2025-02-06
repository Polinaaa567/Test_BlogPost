import 'package:blog_post/StateManager/postProvider.dart';
import 'package:blog_post/UI/pages/FeedPosts.dart';
import 'package:blog_post/UI/pages/Profile.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [FeedPostsScreen(), ProfileScreen()];
    final List<String> _titles = ["Лента постов", "Профиль"];

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();
    return Scaffold(
        appBar: AppBar(
          title: Text(_titles[postStoreWatch.getSelectedPagesIndex]),
        ),
        body: _pages[postStoreRead.getSelectedPagesIndex],
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Посты"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Профиль")
            ],
            currentIndex: postStoreRead.getSelectedPagesIndex,
            onTap: (index) {
              postStoreRead.setSelectedPagesIndex(index);
            }));
  }
}
