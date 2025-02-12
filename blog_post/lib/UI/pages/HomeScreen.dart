import 'package:blog_post/StateManager/postProvider.dart';
import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/FeedPosts.dart';
import 'package:blog_post/UI/pages/Profile.dart';
import 'package:blog_post/UI/pages/Settigs.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const FeedPostsScreen(),
      const ProfileScreen(),
      SettingsScreen(),

    ];
    final List<String> titles = ["Лента постов", "Профиль", "Настройки"];

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return Scaffold(
        appBar: AppBar(
          title: Text(titles[postStoreWatch.getSelectedPagesIndex]),
        ),
        body: pages[postStoreRead.getSelectedPagesIndex],
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Посты"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Профиль"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Настройки")
            ],
            currentIndex: postStoreRead.getSelectedPagesIndex,
            onTap: (index) async {
              postStoreRead.setSelectedPagesIndex(index);
            }));
  }
}
