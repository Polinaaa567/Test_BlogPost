
import 'package:blog_post/provider/navigation_bar/home_screen_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:blog_post/UI/feed_posts/feed_screen/feed_screen.dart';
import 'package:blog_post/UI/profile/profile_screen.dart';
import 'package:blog_post/UI/settings/settigs_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationBarMenu extends StatelessWidget {
  const NavigationBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    HomeScreenProvider homeScreenProviderRead =
        context.read<HomeScreenProvider>();
    HomeScreenProvider homeScreenProviderWatch =
    context.watch<HomeScreenProvider>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();

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
      body: pages[homeScreenProviderWatch.selectedPagesIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavItems,
        currentIndex: homeScreenProviderWatch.selectedPagesIndex,
        onTap: (index) async {
          homeScreenProviderWatch.setSelectedPagesIndex(index);
        },
      ),
    );
  }
}
