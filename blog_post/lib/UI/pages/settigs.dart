import 'package:blog_post/StateManager/home_screen_provider.dart';
import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/authorization.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    HomeScreenProvider homeScreenProviderRead =
        context.read<HomeScreenProvider>();
    HomeScreenProvider homeScreenProviderWatch =
        context.watch<HomeScreenProvider>();

    return Column(
      children: <Widget>[
        ElevatedButton(
            onPressed: () {
              homeScreenProviderRead.setSelectedPagesIndex(1);
            },
            child: Text("Профиль")),
        ElevatedButton(onPressed: () {}, child: Text("Уведомления")),
        ElevatedButton(
            onPressed: () async {
              await profileStoreRead.deleteAccount();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthorizationScreen()));
            },
            child: const Text("Удалить аккаунт")),
        ElevatedButton(
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthorizationScreen()));
            },
            child: const Text("Выход")),
        const Text("version 0.0.0")
      ],
    );

  }
}
