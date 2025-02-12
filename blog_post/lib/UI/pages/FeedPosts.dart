import 'package:blog_post/DTO/PostStructure.dart';
import 'package:blog_post/StateManager/postProvider.dart';
import 'package:blog_post/StateManager/profileProvider.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class AddPostButton extends StatelessWidget {
  final dynamic onPressed;

  const AddPostButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 16.0,
        right: 16.0,
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ));
  }
}

class PostWidget extends StatelessWidget {
  final Posts elem;
  final bool showEditDeleteButtons;
  final dynamic onPressedDelete;
  const PostWidget(
      {super.key,
      required this.elem,
      this.showEditDeleteButtons = true,
      this.onPressedDelete});

  @override
  Widget build(BuildContext context) {
    // PostStore postStoreRead = context.read<PostStore>();
    // PostStore postStoreWatch = context.watch<PostStore>();
    // ProfileStore profileStoreRead = context.read<ProfileStore>();
    // ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    double screenWidth = MediaQuery.of(context).size.width;
    return Column(children: [
      Row(
        children: [
          ClipOval(
            child: elem.avatar != null
                ? Image.memory(
                    elem.avatar!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.person,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
          ),
          const Padding(padding: EdgeInsets.only(left: 8)),
          Text(elem.lastName ?? "last_name"),
          const Padding(padding: EdgeInsets.only(left: 4)),
          Text(elem.name ?? "name"),
          if (showEditDeleteButtons) ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {},
            )
          ]
        ],
      ),
      GestureDetector(
        onTap: () {
          Navigator();
          Logger().d("tap tap");
        },
        child: Container(
            width: screenWidth,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
              ],
            )),
      ),
      Row(
        children: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined)),
          Text("${elem.countLike ?? 0}"),
          IconButton(onPressed: () {}, icon: const Icon(Icons.comment)),
          Text("${elem.countComments}"),
          const Padding(padding: EdgeInsets.only(right: 8)),
          Text(
              "${elem.datePublished.day}.${elem.datePublished.month}.${elem.datePublished.year}"),
        ],
      ),
      const Padding(padding: EdgeInsets.only(top: 8)),
    ]);
  }
}

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
          const TabBar(
            tabs: [
              Tab(
                text: "Мои посты",
              ),
              Tab(
                text: "Все посты",
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                GestureDetector(
                    onVerticalDragEnd: (details) async {
                      if (details.velocity.pixelsPerSecond.dy < 0) {
                        await postStoreWatch
                            .fetchMyPosts(profileStoreRead.getEmail);
                        await postStoreWatch.getAllPosts();
                      }
                    },
                    child: Stack(children: [
                      SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: postStoreRead.getPostsMy!.map((elem) {
                              return PostWidget(
                                elem: elem,
                                showEditDeleteButtons: elem.state == 'draft',
                              );
                            }).toList(),
                          )),
                      AddPostButton(
                        onPressed: null,
                      )
                    ])),
                Stack(children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: postStoreRead.getPosts!.map((elem) {
                        return PostWidget(
                          elem: elem,
                          showEditDeleteButtons: elem.state == 'draft',
                        );
                      }).toList(),
                    ),
                  ),
                  AddPostButton(
                    onPressed: null,
                  )
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
