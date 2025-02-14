import 'package:blog_post/StateManager/comment_probider.dart';
import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModalCommentWidget extends StatelessWidget {
  final int idPost;
  const ModalCommentWidget({super.key, required this.idPost});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    CommentsProvider commentStoreRead = context.read<CommentsProvider>();
    CommentsProvider commentStoreWatch = context.watch<CommentsProvider>();

    double mWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Column(
          children: commentStoreRead.allComments!
              .map((comment) => Column(
            children: [
              Row(
                children: [
                  ClipOval(
                      child: comment.avatar.isNotEmpty
                          ? Image.memory(
                        comment.avatar,
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
                      )),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // убрать для null
                              Text(comment.lastName ?? "anonimus"),
                              const Padding(
                                  padding: EdgeInsets.only(left: 8)),
                              Text(comment.name ?? "98")
                            ],
                          ),
                          Container(
                            constraints: BoxConstraints(maxHeight: 60),
                            child: Text(
                              comment.textComment,
                              textDirection: TextDirection.ltr,
                              softWrap: true,
                            ),
                          ),
                          Text(
                              "${comment.dateCreator.day}.${comment.dateCreator.month}.${comment.dateCreator.year}")
                        ],
                      )),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
            ],
          ))
              .toList(),
        ),
      ],
    );
  }
}
