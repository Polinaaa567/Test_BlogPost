import 'package:blog_post/StateManager/postProvider.dart';
import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/Authorization.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return Column(
      children: <Widget>[
        ElevatedButton(
            onPressed: () {
              postStoreRead.setSelectedPagesIndex(1);
            },
            child: Text("Профиль")),
        ElevatedButton(onPressed: () {}, child: Text("Уведомления")),
        ElevatedButton(onPressed: () async {
          await profileStoreRead.deleteAccount();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AuthorizationScreen()));
        }, child: Text("Удалить аккаунт")),
        ElevatedButton(
            onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AuthorizationScreen()));
            },
            child: Text("Выход")),
        Text("version 0.0.0")
      ],
    );

    throw UnimplementedError();
  }
}
