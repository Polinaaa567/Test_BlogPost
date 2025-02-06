import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

// аватар?

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return  Column(
          children: <Widget>[
            Row(children: [
              ClipOval(
                child: profileStoreRead.getImageAvatar != null
                    ? Image.memory(
                        img.encodePng(profileStoreRead.getImageAvatar!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: const Icon(Icons.person,
                            size: 50, color: Colors.white),
                      ),
              ),
              ElevatedButton(
                onPressed: () => profileStoreRead.getImageFromGallery(),
                child: const Text("Изменить фото"),
              ),
            ]),
            Text(profileStoreRead.getEmail),
            TextFormField(
              controller: profileStoreWatch.getNameController,
              decoration: const InputDecoration(labelText: "Введите имя"),
              onChanged: profileStoreRead.setName,
            ),
            TextFormField(
              controller: profileStoreWatch.getNameController,
              decoration: const InputDecoration(labelText: "Введите фамилию"),
              onChanged: profileStoreRead.setLastName,
            ),
            ElevatedButton(onPressed: () {}, child: const Text("Сохранить"))
          ],
        );
  }
}
