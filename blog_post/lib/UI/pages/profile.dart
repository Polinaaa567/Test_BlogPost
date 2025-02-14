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

    return Column(
      children: <Widget>[
        Row(children: [
          ClipOval(
            child: profileStoreWatch.getImageAvatar != null
                ? Image.memory(
                    img.encodeJpg(profileStoreWatch.getImageAvatar!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : profileStoreWatch.getBytes.isNotEmpty
                    ? Image.memory(
                        profileStoreWatch.getBytes,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
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
          controller: profileStoreWatch.getLastNameController,
          decoration: const InputDecoration(labelText: "Введите фамилию"),
          onChanged: profileStoreRead.setLastName,
        ),
        ElevatedButton(
            onPressed: () async {
              dynamic response = await profileStoreWatch.sendDataAboutUser();
              if (response == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Данные успешно сохранены")));
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(response)));
              }
            },
            child: const Text("Сохранить"))
      ],
    );
  }
}
