import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ClipOval(
                      child: profileStoreWatch.bytes.isNotEmpty
                              ? Image.memory(
                                  profileStoreWatch.bytes,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.grey,
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: IconButton(
                          icon: const Icon(Icons.create_outlined),
                          color: Colors.white,
                          onPressed: () async =>
                              await profileStoreRead.getImageFromGallery()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text("Email: ${profileStoreRead.email}"),
          TextFormField(
            controller: profileStoreRead.nameController,
            decoration: const InputDecoration(labelText: "Введите имя"),
            onChanged: profileStoreWatch.setName,
          ),
          TextFormField(
            controller: profileStoreWatch.lastNameController,
            decoration: const InputDecoration(labelText: "Введите фамилию"),
            onChanged: profileStoreWatch.setLastName,
          ),
          ElevatedButton(
              onPressed: () async {
                if (profileStoreRead.lastName != "" &&
                    profileStoreRead.lastName != null &&
                    profileStoreRead.name != '' &&
                    profileStoreRead.name != null) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  try {
                    dynamic response =
                        await profileStoreWatch.sendDataAboutUser();
                    if (response == null) {
                      await postStoreRead.fetchMyPosts(profileStoreRead.email);
                      await postStoreRead.fetchMyPosts(profileStoreRead.email);
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Данные успешно сохранены")));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(response)));
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Ошибка при загрузке данных')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Введите все данные")));
                }
              },
              child: const Text("Сохранить"))
        ],
      ),
    );
  }
}
