import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

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
                  controller: postStoreWatch.getHeadlineController,
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
              controller: postStoreWatch.getTextPostController,
              onChanged: postStoreRead.setTextPost,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: "Текст поста",
              ),
            ),
            (postStoreRead.getImagePost != null)
                ? Image.memory(
                    img.encodeJpg(postStoreRead.getImagePost!),
                    width: 400,
                    height: 400,
                  )
                : _isThisEdit && postStoreRead.listPhotoPost.isNotEmpty
                    ? Image.memory(
                        postStoreRead.listPhotoPost,
                        width: 400,
                        height: 400,
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
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          if ((_isThisEdit &&
                                  postStoreRead.isPublished == false) ||
                              ((_isThisEdit == false &&
                                  postStoreRead.isPublished == false))) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            try {
                              await postStoreWatch.createNewDraftPost(
                                  profileStoreRead.getEmail);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();

                              await postStoreRead
                                  .fetchMyPosts(profileStoreRead.getEmail);
                              postStoreRead.clearPostsEdit();
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Ошибка при загрузке данных')),
                              );
                            }
                          } else if (profileStoreRead.getLastName != null &&
                              profileStoreRead.getLastName != null &&
                              profileStoreRead.getName != '' &&
                              profileStoreRead.getName != null &&
                              postStoreRead.getHeadline != '' &&
                              postStoreRead.getTextPost != "" &&
                              (postStoreRead.getImagePost != null ||
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
                                  profileStoreRead.getEmail);
                              await postStoreRead
                                  .fetchMyPosts(profileStoreRead.getEmail);
                              await postStoreRead
                                  .fetchAllPosts(profileStoreRead.getEmail);
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Данные не все заполнены")));
                          }
                        },
                        child: Text("Сохранить")),
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
                                            postStoreRead.getIdPost!,
                                            profileStoreRead.getEmail);
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
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Text("Удалить"))
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
