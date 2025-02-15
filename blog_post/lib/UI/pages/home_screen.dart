import 'package:blog_post/StateManager/home_screen_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/feed_posts.dart';
import 'package:blog_post/UI/pages/feed_screen.dart';
import 'package:blog_post/UI/pages/profile.dart';
import 'package:blog_post/UI/pages/settigs.dart';
import 'package:blog_post/UI/pages/viewing_post.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HomeScreenProvider homeScreenProviderRead =
        context.read<HomeScreenProvider>();
    HomeScreenProvider homeScreenProviderWatch =
        context.watch<HomeScreenProvider>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    final List<Widget> pages = [
      FeedScreen(),
      if (profileStoreRead.isUserAuth) const ProfileScreen(),
      SettingsScreen(),
    ];

    List<BottomNavigationBarItem> bottomNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Посты",
      ),
      if (profileStoreRead.isUserAuth)
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Профиль",
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Настройки",
      )
    ];

    return Scaffold(
        body: pages[homeScreenProviderRead.getSelectedPagesIndex],
        bottomNavigationBar: BottomNavigationBar(
            items: bottomNavItems,
            currentIndex: homeScreenProviderRead.getSelectedPagesIndex,
            onTap: (index) async {
              homeScreenProviderRead.setSelectedPagesIndex(index);
            }));
  }
}
