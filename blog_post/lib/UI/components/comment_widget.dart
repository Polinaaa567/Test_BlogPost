import 'package:blog_post/StateManager/comment_probider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModalCommentWidget extends StatelessWidget {
  final int idPost;

  const ModalCommentWidget({super.key, required this.idPost});

  @override
  Widget build(BuildContext context) {
    CommentsProvider commentStoreRead = context.read<CommentsProvider>();
    CommentsProvider commentStoreWatch = context.watch<CommentsProvider>();

    return Column(
      children: [
        Column(
          children: commentStoreWatch.allComments!
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
                                  Text(comment.lastName ?? "Delete",
                                      style: const TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.bold
                                      )),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 8)),
                                  Text(comment.name ?? "User",
                                      style: const TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.bold
                                      ))
                                ],
                              ),
                              const Padding(padding: EdgeInsets.only(top: 4)),

                              Container(
                                constraints: const BoxConstraints(maxHeight: 60),
                                child: Text(
                                  comment.textComment,
                                  textDirection: TextDirection.ltr,
                                    style: const TextStyle(
                                        fontSize: 17,
                                    )
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 2)),
                              Text(
                                  "${comment.dateCreator.day}.${comment.dateCreator.month}.${comment.dateCreator.year}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal
                                  ))
                            ],
                          )),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }
}
