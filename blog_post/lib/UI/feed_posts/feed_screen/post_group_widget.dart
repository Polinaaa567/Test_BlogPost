import 'package:blog_post/entities/grouped_posts.dart';
import 'package:blog_post/entities/post.dart';
import 'package:blog_post/UI/feed_posts/create_post/new_edit_post.dart';
import 'package:blog_post/provider/comments/comment_model.dart';
import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:blog_post/UI/feed_posts/feed_screen/comment_widget.dart';
import 'package:blog_post/UI/feed_posts/info_post/viewing_post.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpandablePostGroupWidget extends StatelessWidget {
  final IGroupedPosts groupedPosts;

  const ExpandablePostGroupWidget({super.key, required this.groupedPosts});

  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    String currentTab = postStoreRead.currentTab;
    var borderRadius = const BorderRadius.all(Radius.circular(32));

    return Column(
      children: [
        ListTile(
          title: Text(
              "${groupedPosts.formattedDate} (${groupedPosts.postCount} ${postStoreRead.setCountPosts(groupedPosts.postCount)})",
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          trailing: Icon(
              groupedPosts.isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () => postStoreRead.toggleGroupExpansion(
              currentTab.contains("My")
                  ? postStoreWatch.groupedPostsMy!.indexOf(groupedPosts)
                  : postStoreWatch.groupedPostsAll!.indexOf(groupedPosts)),
          selectedTileColor: const Color.fromRGBO(155, 122, 191, 1.0),
          tileColor: const Color.fromRGBO(219, 195, 255, 1.0),
          selected: groupedPosts.isExpanded,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        if (groupedPosts.isExpanded)
          Column(
            children: groupedPosts.posts
                .map((post) => PostListWidget(elem: post))
                .toList(),
          )
      ],
    );
  }
}

class PostListWidget extends StatelessWidget {
  final Post elem;

  const PostListWidget({
    super.key,
    required this.elem,
  });

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    CommentsProvider commentStoreRead = context.read<CommentsProvider>();

    double mWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              ClipOval(
                child: elem.avatar.isNotEmpty
                    ? Image.memory(
                        elem.avatar,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 6),
                child: Text(
                  elem.lastName ?? "last_name",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                elem.name ?? "name",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              if (elem.state == 'draft') ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    postStoreRead.setIsThisEdit(true);

                    await postStoreRead.fetchPostInfo(
                        elem.idPost, profileStoreRead.email, true);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const NewEditPostPage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () async {
                    await postStoreWatch.deleteDraft(
                        elem.idPost, profileStoreRead.email);
                  },
                )
              ]
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (!postStoreRead.isOnePostInfo && elem.state != "draft") {
              await postStoreWatch.fetchPostInfo(elem.idPost,
                  profileStoreRead.email, profileStoreRead.isUserAuth);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewingPostScreen()));
              postStoreWatch.setIsOnePostInfo();
            }
          },
          child: SizedBox(
            width: mWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  elem.headline ?? "headline",
                  textDirection: TextDirection.ltr,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                elem.photoPost.isNotEmpty
                    ? Image.memory(
                        elem.photoPost,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      )
                    : Container(
                        width: 400,
                        height: 400,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 125,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
          ),
        ),
        if (postStoreRead.isOnePostInfo)
          Text(
            elem.textPost ?? "text",
            textDirection: TextDirection.ltr,
            softWrap: true,
            style: const TextStyle(fontSize: 18),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (elem.state != 'draft') ...[
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    if (profileStoreRead.isUserAuth) ...[
                      IconButton(
                        onPressed: () async => await postStoreWatch
                            .fetchLikedPosts(elem, profileStoreRead.email),
                        icon: Icon(
                          elem.stateLike
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color:
                              elem.stateLike ? Colors.deepPurple : Colors.grey,
                        ),
                      ),
                    ] else if (!profileStoreRead.isUserAuth) ...[
                      const Icon(Icons.thumb_up_alt_outlined),
                    ],
                    Text("${elem.countLike ?? 0}"),
                    IconButton(
                      onPressed: () async {
                        await commentStoreRead.fetchAllComments(elem.idPost);
                        showModalBottomSheet(
                            context: context,
                            builder: (builder) =>
                                ModalCommentWidget(idPost: elem.idPost));
                      },
                      icon: const Icon(Icons.comment),
                    ),
                    Text("${elem.countComments}"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                    "${elem.datePublished.day}.${elem.datePublished.month}.${elem.datePublished.year}"),
              ),
            ],
          ],
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8))
      ],
    );
  }
}
