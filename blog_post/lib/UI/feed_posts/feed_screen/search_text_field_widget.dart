import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    String currentTab = postStoreRead.currentTab;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        controller: currentTab.contains("My")
            ? postStoreWatch.searchTextMyController
            : postStoreWatch.searchTextAllController,
        onChanged: currentTab.contains("My")
            ? postStoreRead.setSearchTextMy
            : postStoreRead.setSearchTextAll,
        decoration: InputDecoration(
          labelText: "Поиск",
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((postStoreWatch.searchTextMy != '' &&
                      currentTab.contains("My")) ||
                  (postStoreWatch.searchTextAll != '' &&
                      currentTab.contains("All"))) ...[
                IconButton(
                  onPressed: () async {
                    await postStoreWatch.searchPosts(
                        profileStoreRead.email, profileStoreRead.isUserAuth);
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () async {
                    if (currentTab.contains("My")) {
                      await postStoreRead
                          .fetchMyPosts(profileStoreRead.email);
                      postStoreRead.clearSearchMy();
                    } else {
                      await postStoreRead
                          .fetchAllPosts(profileStoreRead.email);
                      postStoreRead.clearSearchAll();
                    }
                  },
                  icon: const Icon(Icons.clear),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
