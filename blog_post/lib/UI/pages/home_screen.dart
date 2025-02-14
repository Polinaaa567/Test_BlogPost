import 'package:blog_post/StateManager/home_screen_provider.dart';
import 'package:blog_post/UI/pages/feed_posts.dart';
import 'package:blog_post/UI/pages/profile.dart';
import 'package:blog_post/UI/pages/settigs.dart';
import 'package:blog_post/UI/pages/viewing_post.dart';

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
      ViewingPostScreen()
    ];
    final List<String> titles = ["Лента постов", "Профиль", "Настройки"];

    HomeScreenProvider homeScreenProviderRead = context.read<HomeScreenProvider>();
    HomeScreenProvider homeScreenProviderWatch = context.watch<HomeScreenProvider>();

    return Scaffold(
        appBar: AppBar(
          title: Text(titles[homeScreenProviderRead.getSelectedPagesIndex]),
        ),
        body: pages[homeScreenProviderRead.getSelectedPagesIndex],
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Посты",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Профиль",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Настройки",
              )
            ],
            currentIndex: homeScreenProviderRead.getSelectedPagesIndex,
            onTap: (index) async {
              homeScreenProviderRead.setSelectedPagesIndex(index);
            }));
  }
}
