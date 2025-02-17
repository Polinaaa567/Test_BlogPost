import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    String currentTab = postStoreRead.getCurrentTab;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
          controller: currentTab.contains("My")
              ? postStoreWatch.getSearchTextMyController
              : postStoreWatch.getSearchTextAllController,
          onChanged: currentTab.contains("My")
              ? postStoreRead.setSearchTextMy
              : postStoreRead.setSearchTextAll,
          decoration: InputDecoration(
              labelText: "Поиск",
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((postStoreWatch.getSearchTextMy != '' &&
                      currentTab.contains("My")) ||
                      (postStoreWatch.getSearchTextAll != '' &&
                          currentTab.contains("All"))) ...[
                    IconButton(
                      onPressed: () async {
                        await postStoreWatch.searchPosts(
                            profileStoreRead.getEmail,
                            profileStoreRead.isUserAuth);
                      },
                      icon: Icon(Icons.search),
                    ),
                    IconButton(
                        onPressed: () async {
                          if (currentTab.contains("My")) {
                            await postStoreRead
                                .fetchMyPosts(profileStoreRead.getEmail);
                            postStoreRead.clearSearchMy();
                          } else {
                            await postStoreRead
                                .fetchAllPosts(profileStoreRead.getEmail);
                            postStoreRead.clearSearchAll();
                          }
                        },
                        icon: Icon(Icons.clear))
                  ],
                ],
              ))),
    );
  }
}