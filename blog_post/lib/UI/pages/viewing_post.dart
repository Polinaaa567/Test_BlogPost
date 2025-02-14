import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewingPostScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Подробная информация"),
        actions: [
          IconButton(
              onPressed: () async {
                await postStoreWatch.fetchAllPosts(profileStoreWatch.getEmail);
                await postStoreWatch.fetchMyPosts(profileStoreWatch.getEmail);

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
                // postStoreRead.setSelectedPagesIndex(1);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: Column(
        children: postStoreRead.getPostOneInfo!.map((elem) {
          return Column(children: [
            Text(elem.headline ?? "headline"),
            elem.photoPost != null
                ? Image.memory(elem.photoPost!, width: 250, height: 250)
                : Container(
                    width: 250,
                    height: 250,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 125,
                      color: Colors.white,
                    ),
                  ),
            Text(elem.textPost ?? "text"),
            Row(
              children: [
                IconButton(
                    onPressed: () async {
                      // postStoreWatch.toggleLike();
                      // await postStoreWatch.fetchLikedPosts(
                      //     elem, profileStoreRead.getEmail);
                    },
                    icon: Icon(
                      elem.stateLike == true
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined,
                      color: elem.stateLike == true
                          ? Colors.deepPurple
                          : Colors.grey,
                    )),
                Text("${elem.countLike ?? 0}"),
                IconButton(onPressed: () {}, icon: const Icon(Icons.comment)),
                Text("${elem.countComments}"),
                const Padding(padding: EdgeInsets.only(right: 8)),
                Text(
                    "${elem.datePublished.day}.${elem.datePublished.month}.${elem.datePublished.year}"),
              ],
            )
          ]);
        }).toList(),
      ),
    );
  }
}
