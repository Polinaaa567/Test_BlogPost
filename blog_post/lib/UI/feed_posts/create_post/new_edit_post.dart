import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NewEditPostPage extends StatelessWidget {
  const NewEditPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    bool _isThisEdit = postStoreRead.isThisEdit;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "Внесённые изменения не сохранятся. Вы действительно хотите выйти?",
                              style: TextStyle(fontSize: 17),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_isThisEdit) {
                                    postStoreRead.setIsThisEdit(false);
                                  }
                                  postStoreRead.clearPostsEdit();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Да"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Нет"),
                              )
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            ),
            Column(
              children: [
                TextFormField(
                  controller: postStoreWatch.headlineController,
                  onChanged: postStoreRead.setHeadline,
                  decoration: InputDecoration(
                    labelText: "Заголовок",
                  ),
                  maxLines: 1,
                  maxLength: 50,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                ),
              ],
            ),
            TextFormField(
              controller: postStoreWatch.textPostController,
              onChanged: postStoreRead.setTextPost,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: "Текст поста",
              ),
            ),
            (postStoreRead.imagePost.isNotEmpty)
                ? Image.memory(
                    postStoreRead.imagePost,
                  )
                : _isThisEdit && postStoreRead.listPhotoPost.isNotEmpty
                    ? Image.memory(
                        postStoreRead.listPhotoPost,
                      )
                    : Container(),
            ElevatedButton(
                onPressed: () async {
                  await postStoreRead.getImageFromGallery();
                },
                child: Text("Загрузить изображение")),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Switch(
                        value: postStoreRead.isPublished,
                        onChanged: (value) =>
                            postStoreWatch.changePublication()),
                    Text(postStoreRead.isPublished
                        ? "Опубликовать"
                        : "Черновик"),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            if ((_isThisEdit &&
                                    !postStoreRead.isPublished) ||
                                ((!_isThisEdit &&
                                    !postStoreRead.isPublished))) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              try {
                                await postStoreWatch
                                    .createNewDraftPost(profileStoreRead.email);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();

                                await postStoreRead
                                    .fetchMyPosts(profileStoreRead.email);
                                postStoreRead.clearPostsEdit();
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Ошибка при загрузке данных')),
                                );
                              }
                            } else if (profileStoreRead.lastName != null &&
                                profileStoreRead.lastName != null &&
                                profileStoreRead.name != '' &&
                                profileStoreRead.name != null &&
                                postStoreRead.headline != '' &&
                                postStoreRead.textPost != "" &&
                                (postStoreRead.imagePost.isNotEmpty ||
                                    postStoreRead.listPhotoPost.isNotEmpty) &&
                                postStoreRead.isPublished == true) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              try {
                                await postStoreRead.createNewPublishedPost(
                                    profileStoreRead.email);
                                await postStoreRead
                                    .fetchMyPosts(profileStoreRead.email);
                                await postStoreRead
                                    .fetchAllPosts(profileStoreRead.email);
                                postStoreRead.clearPostsEdit();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Ошибка при загрузке данных')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Данные не все заполнены")));
                            }
                          },
                          child: const Text("Сохранить")),
                      if (_isThisEdit)
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Вы действительно хотите удалить черновик?",
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await postStoreRead.deleteDraft(
                                            postStoreRead.idPost!,
                                            profileStoreRead.email);
                                        postStoreRead.setIsThisEdit(false);

                                        postStoreRead.clearPostsEdit();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Да"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Нет"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text("Удалить"),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
