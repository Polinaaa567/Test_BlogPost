import 'package:blog_post/provider/comments/comment_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModalCommentWidget extends StatelessWidget {
  final int idPost;

  const ModalCommentWidget({super.key, required this.idPost});

  @override
  Widget build(BuildContext context) {
    CommentsProvider commentStoreWatch = context.watch<CommentsProvider>();
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    CommentsProvider commentStoreRead = context.read<CommentsProvider>();

    return Container(
      color: const Color.fromRGBO(213, 201, 230, 1.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Комментарии",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromRGBO(116, 72, 186, 1.0),
                      fontSize: 30,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Caveat"),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
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
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      children: [
                        Column(
                          children: commentStoreWatch.allComments!
                              .map(
                                (comment) => Column(
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
                                                ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 10),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    comment.lastName ??
                                                        "Delete",
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 8),
                                                  ),
                                                  Text(
                                                    comment.name ?? "User",
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 4)),
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxHeight: 60),
                                                child: Text(
                                                  comment.textComment,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 2)),
                                              Text(
                                                "${comment.dateCreator.day}.${comment.dateCreator.month}.${comment.dateCreator.year}",
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 10)),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          if (profileStoreRead.isUserAuth)
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: commentStoreWatch.commentTextController,
                onChanged: commentStoreRead.setCommentText,
                decoration: InputDecoration(
                    labelText: "Комментарий",
                    suffixIcon: IconButton(
                        onPressed: () async {
                          final lastName = profileStoreRead.lastName;
                          final name = profileStoreRead.name;

                          (lastName != null &&
                                  lastName != '' &&
                                  name != null &&
                                  name != '')
                              ? [
                                  await commentStoreWatch.newComment(
                                      idPost, profileStoreRead.email),
                                  await commentStoreWatch
                                      .fetchAllComments(idPost)
                                ]
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Введите имя и фамилию"),
                                  ),
                                );
                        },
                        icon: const Icon(Icons.send))),
              ),
            ),
        ],
      ),
    );
  }
}
