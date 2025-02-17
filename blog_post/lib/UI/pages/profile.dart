import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
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
    PostStore postStoreWatch = context.watch<PostStore>();

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
                    child: profileStoreWatch.getImageAvatar != null
                        ? Image.memory(
                            img.encodeJpg(profileStoreRead.getImageAvatar!),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : profileStoreWatch.getBytes.isNotEmpty
                            ? Image.memory(
                                profileStoreRead.getBytes,
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
                           await profileStoreWatch.getImageFromGallery()),
                  ),
                ),
              ],
            ),
          ],
        ),
        Text("Email: ${profileStoreRead.getEmail}"),
        TextFormField(
          controller: profileStoreWatch.getNameController,
          decoration: const InputDecoration(labelText: "Введите имя"),
          onChanged: profileStoreRead.setName,
        ),
        TextFormField(
          controller: profileStoreWatch.getLastNameController,
          decoration: const InputDecoration(labelText: "Введите фамилию"),
          onChanged: profileStoreRead.setLastName,
        ),
        ElevatedButton(
            onPressed: () async {
              if (profileStoreRead.getLastName != "" &&
                  profileStoreRead.getLastName != null &&
                  profileStoreRead.getName != '' &&
                  profileStoreRead.getName != null) {
                dynamic response = await profileStoreWatch.sendDataAboutUser();
                if (response == null) {
                  await postStoreRead.fetchMyPosts(profileStoreRead.getEmail);
                  await postStoreRead.fetchMyPosts(profileStoreRead.getEmail);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Данные успешно сохранены")));
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(response)));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Введите все данные")));
              }
            },
            child: const Text("Сохранить"))
      ],
    ));
  }
}
