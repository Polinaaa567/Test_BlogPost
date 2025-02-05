import 'package:blog_post/StateManager/profileProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedPostsScreen extends StatelessWidget {
  // снизу должна быть менюшка по всем экранам

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return Scaffold(
        appBar: AppBar(title: const Text('Лента постов')), body: Column(
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(
            labelText: "Введите название для поиска"
          ),
        ),
      ],
    ));
  }
}
