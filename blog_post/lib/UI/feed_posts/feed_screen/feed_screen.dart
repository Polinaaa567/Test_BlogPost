import 'package:blog_post/provider/notification/notification_model.dart';
import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:blog_post/UI/feed_posts/create_post/add_post_button_widget.dart';
import 'package:blog_post/UI/feed_posts/feed_screen/post_group_widget.dart';
import 'package:blog_post/UI/feed_posts/feed_screen/search_text_field_widget.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    NotificationModel notificationModelRead = context.read<NotificationModel>();

    final posts = notificationModelRead.differencePosts();
    final comments = notificationModelRead.differenceComments();
    final likes = notificationModelRead.differenceLikes();

    return profileStoreRead.isUserAuth
        ? DefaultTabController(
            initialIndex: postStoreRead.currentTab.contains("My") ? 0 : 1,
            length: 2,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 10),
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Лента постов",
                          style: TextStyle(fontSize: 35, fontFamily: "Caveat"),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          onPressed: () {
                            if (posts == null &&
                                comments == null &&
                                likes == null) return;

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (posts != null)
                                      Text("Новых постов: $posts"),
                                    if (comments != null)
                                      Text("Новых комментариев: $comments"),
                                    if (likes != null)
                                      Text("Новых лайков: $likes"),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: (posts == null &&
                                  comments == null &&
                                  likes == null)
                              ? const Icon(
                                  Icons.notifications,
                                  color: Colors.grey,
                                )
                              : const Icon(
                                  Icons.notifications_active,
                                  color: Colors.yellow,
                                ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: TabBar(
                    onTap: (index) {
                      postStoreRead.setCurrentTab(index == 0 ? "My" : "All");
                    },
                    tabs: const [
                      Tab(text: "Мои посты"),
                      Tab(text: "Все посты"),
                    ],
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      TabsViewAllMy(),
                      TabsViewAllMy(),
                    ],
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              await postStoreWatch.fetchAllPosts(null);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "Лента постов",
                        style: TextStyle(fontSize: 35, fontFamily: "Caveat"),
                      )),
                  const SearchWidget(),
                  Column(
                    children: postStoreRead.groupedPostsAll != null
                        ? postStoreRead.groupedPostsAll!
                            .map((group) =>
                                ExpandablePostGroupWidget(groupedPosts: group))
                            .toList()
                        : [],
                  )
                ],
              ),
            ),
          );
  }
}

class TabsViewAllMy extends StatelessWidget {
  const TabsViewAllMy({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    String currentTab = postStoreWatch.currentTab;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            if (currentTab.contains("My")) {
              await postStoreWatch.fetchMyPosts(profileStoreRead.email);
            } else {
              await postStoreWatch.fetchAllPosts(profileStoreRead.email);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SearchWidget(),
                Column(
                  children: currentTab.contains("My")
                      ? postStoreRead.groupedPostsMy != null
                          ? postStoreRead.groupedPostsMy!
                              .map((group) => ExpandablePostGroupWidget(
                                  groupedPosts: group))
                              .toList()
                          : []
                      : postStoreRead.groupedPostsAll != null
                          ? postStoreRead.groupedPostsAll!
                              .map(
                                (group) => ExpandablePostGroupWidget(
                                    groupedPosts: group),
                              )
                              .toList()
                          : [],
                )
              ],
            ),
          ),
        ),
        if (profileStoreRead.isUserAuth) const AddPostButton()
      ],
    );
  }
}
