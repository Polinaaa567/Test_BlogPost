import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/HomeScreen.dart';
import 'package:blog_post/UI/pages/Profile.dart';
import 'package:blog_post/UI/pages/Registration.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthorizationScreen extends StatelessWidget {
  const AuthorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return Scaffold(
        appBar: AppBar(title: const Text('Авторизация')),
        body: Column(
          children: <Widget>[
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: profileStoreWatch.getEmailController,
              decoration: InputDecoration(
                  labelText: "email",
                  errorText: profileStoreRead.getErrorMessageEmail),
              onChanged: profileStoreRead.setEmail,
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: profileStoreRead.getPasswordVisible,
              controller: profileStoreWatch.getPasswordController,
              onChanged: profileStoreRead.setPassword,
              decoration: InputDecoration(
                labelText: "Пароль",
                errorText: profileStoreRead.getErrorMessagePassword,
                suffixIcon: IconButton(
                    icon: Icon(profileStoreRead.getPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => profileStoreRead.changePasswordVisible()),
                alignLabelWithHint: false,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (profileStoreRead.getErrorMessageEmail == null &&
                      profileStoreRead.getErrorMessagePassword == null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen()));
                  }
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        const Color.fromRGBO(204, 128, 255, 1))),
                child: const Text("Войти")),
            InkWell(
              child: const Text("Зарегистрироваться"),
              onTap: () {
                profileStoreRead.setEmptyDataAuthorization();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistrationScreen()));
              },
            ),
          ],
        ));
  }
}
