import 'package:blog_post/DTO/grouped_posts.dart';
import 'package:blog_post/DTO/post_structure.dart';
import 'package:blog_post/StateManager/comment_probider.dart';
import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/components/add_button_widget.dart';
import 'package:blog_post/UI/components/comment_widget.dart';
import 'package:blog_post/UI/pages/viewing_post.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class ExpandablePostGroupWidget extends StatelessWidget {
  final GroupedPosts groupedPosts;
  final bool isMyPost;

  const ExpandablePostGroupWidget(
      {super.key, required this.groupedPosts, required this.isMyPost});
  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    return Column(
      children: [
        ListTile(
          title:
              Text("${groupedPosts.formattedDate} (${groupedPosts.postCount})"),
          trailing: Icon(
              groupedPosts.isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () => postStoreRead.toggleGroupExpansion(
              isMyPost
                  ? postStoreWatch.groupedPostsMy!.indexOf(groupedPosts)
                  : postStoreWatch.groupedPostsAll!.indexOf(groupedPosts),
              isMyPost),
        ),
        if (groupedPosts.isExpanded)
          Column(
              children: groupedPosts.posts
                  .map((post) => PostWidget(
                      elem: post,
                      showEditDeleteButtons: post.state == 'draft',
                      isMyPost: isMyPost))
                  .toList())
      ],
    );
  }
}

class PostWidget extends StatelessWidget {
  final Posts elem;
  final bool showEditDeleteButtons;
  final dynamic onPressedDelete;
  final bool isMyPost;

  const PostWidget(
      {super.key,
      required this.elem,
      this.showEditDeleteButtons = true,
      this.onPressedDelete,
      required this.isMyPost});

  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    CommentsProvider commentStoreRead = context.read<CommentsProvider>();
    CommentsProvider commentStoreWatch = context.watch<CommentsProvider>();

    double mWidth = MediaQuery.of(context).size.width;
    double mHeight = MediaQuery.of(context).size.height;

    // double screenWidth = MediaQuery.of(context).size.width;
    return Column(children: [
      Row(
        children: [
          ClipOval(
            child: elem.avatar.isNotEmpty
                ? Image.memory(
                    elem.avatar,
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
              onPressed: () async {
                await postStoreWatch.deleteDraft(
                    elem.idPost, profileStoreRead.getEmail);
              },
            )
          ]
        ],
      ),
      GestureDetector(
        onTap: () async {
          await postStoreWatch.fetchPostInfo(
              elem.idPost, profileStoreRead.getEmail);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ViewingPostScreen()));
          Logger().d("tap tap");
        },
        child: SizedBox(
            width: 500,
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
      //
      Row(children: [
        if (!showEditDeleteButtons) ...[
          IconButton(
              onPressed: () async => await postStoreWatch.fetchLikedPosts(
                  elem, profileStoreRead.getEmail, isMyPost),
              icon: Icon(
                elem.stateLike == true
                    ? Icons.thumb_up
                    : Icons.thumb_up_alt_outlined,
                color: elem.stateLike == true ? Colors.deepPurple : Colors.grey,
              )),
          Text("${elem.countLike ?? 0}"),
          IconButton(
            onPressed: () async {
              await commentStoreRead.fetchAllComments(elem.idPost);
              return showModalBottomSheet(
                context: context,
                builder: (builder) => Container(
                  // width: mWidth,
                  // height: mHeight *0.75,
                  color: Color.fromRGBO(213, 201, 230, 1.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(onPressed: () {}, icon: Icon(Icons.close)),
                          const Text("Комментарии",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(116, 72, 186, 1.0),
                                fontSize: 26,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ),
                      const Divider(
                        indent: 20,
                        endIndent: 20,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              ModalCommentWidget(idPost: elem.idPost),
                            ],
                          ),
                        ),
                      ),
                      Container(
              padding: EdgeInsets.all(8),
                              child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller:
                                commentStoreWatch.getCommentTextController,
                            onChanged: commentStoreRead.setCommentText,
                            decoration: InputDecoration(
                                labelText: "Комментарий",
                                suffixIcon: IconButton(
                                    onPressed: () async =>
                                        await commentStoreWatch.newComment(
                                            elem.idPost,
                                            profileStoreRead.getEmail),
                                    icon: const Icon(Icons.send))),
                          )),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.comment),
          ),
          Text("${elem.countComments}"),
          const Padding(padding: EdgeInsets.only(right: 8)),
          Text(
              "${elem.datePublished.day}.${elem.datePublished.month}.${elem.datePublished.year}"),
        ]
      ]),
      const Padding(padding: EdgeInsets.only(top: 8)),
    ]);
  }
}

class FeedPostsScreen extends StatelessWidget {
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
              Tab(text: "Мои посты"),
              Tab(text: "Все посты"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                GestureDetector(
                    onVerticalDragEnd: (details) async {
                      // if (details.velocity.pixelsPerSecond.dy < 0) {
                      //   await postStoreWatch
                      //       .fetchMyPosts(profileStoreRead.getEmail);
                      //   await postStoreWatch.getAllPosts();
                      //   Logger().d("Swipe");
                      // }
                    },
                    child: Stack(children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(children: <Widget>[
                          TextFormField(
                            controller:
                                postStoreWatch.getSearchTextMyController,
                            onChanged: postStoreRead.setSearchTextMy,
                            decoration: InputDecoration(
                                labelText: "Поиск",
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (postStoreWatch.getSearchTextMy !=
                                        '') ...[
                                      IconButton(
                                        onPressed: () async {
                                          await postStoreWatch.searhPosts(
                                              profileStoreRead.getEmail, "My");
                                        },
                                        icon: Icon(Icons.search),
                                      ),
                                      IconButton(
                                          onPressed: () async {
                                            await postStoreRead.fetchMyPosts(
                                                profileStoreRead.getEmail);
                                            postStoreRead.clearSearchMy();
                                          },
                                          icon: Icon(Icons.clear))
                                    ]
                                  ],
                                )),
                          ),
                          Column(
                              children: postStoreRead.groupedPostsMy != null
                                  ? postStoreRead.groupedPostsMy!
                                      .map((group) => ExpandablePostGroupWidget(
                                            groupedPosts: group,
                                            isMyPost: true,
                                          ))
                                      .toList()
                                  : [])
                        ]),
                      ),
                      AddPostButton()
                    ])),
                Stack(children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(children: [
                      TextFormField(
                        controller: postStoreWatch.getSearchTextAllController,
                        onChanged: postStoreRead.setSearchTextAll,
                        decoration: InputDecoration(
                            labelText: "Поиск",
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (postStoreWatch.getSearchTextAll != '') ...[
                                  IconButton(
                                    onPressed: () async {
                                      await postStoreWatch.searhPosts(
                                          profileStoreRead.getEmail, "All");
                                    },
                                    icon: Icon(Icons.search),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        await postStoreRead.fetchAllPosts(
                                            profileStoreRead.getEmail);
                                        postStoreRead.clearSearchAll();
                                      },
                                      icon: Icon(Icons.clear))
                                ]
                              ],
                            )),
                      ),
                      Column(
                          children: postStoreRead.groupedPostsAll != null
                              ? postStoreRead.groupedPostsAll!
                                  .map((group) => ExpandablePostGroupWidget(
                                        groupedPosts: group,
                                        isMyPost: false,
                                      ))
                                  .toList()
                              : [])
                    ]),
                  ),
                  AddPostButton()
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  const FeedPostsScreen({super.key});
}

