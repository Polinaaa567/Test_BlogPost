import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/components/posts_feed_components/add_button_widget.dart';
import 'package:blog_post/UI/components/posts_feed_components/post_group_widget.dart';
import 'package:blog_post/UI/components/posts_feed_components/search_widget.dart';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    return profileStoreRead.isUserAuth
        ? DefaultTabController(
      initialIndex: postStoreRead.getCurrentTab.contains("My") ? 0 : 1,
            length: 2,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  alignment: AlignmentDirectional.center,
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 10),
                  child: const Text(
                    "Лента постов",
                    style: TextStyle(fontSize: 35, fontFamily: "Caveat"),
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
              physics: AlwaysScrollableScrollPhysics(),
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
            ));
  }
}

class TabsViewAllMy extends StatelessWidget {
  const TabsViewAllMy({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    String currentTab = postStoreWatch.getCurrentTab;
    return Stack(
      children: [
        RefreshIndicator(
            onRefresh: () async {
              if (currentTab.contains("My")) {
                await postStoreWatch.fetchMyPosts(profileStoreRead.getEmail);
              } else {
                await postStoreWatch.fetchAllPosts(profileStoreRead.getEmail);
              }
            },
            child:
            SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
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
                              .map((group) => ExpandablePostGroupWidget(
                                  groupedPosts: group))
                              .toList()
                          : [],
                )
              ],
            ),
          ),),

        if (profileStoreRead.isUserAuth) const AddPostButton()
      ],
    );
  }
}
