import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/Authorization.dart';
import 'package:blog_post/UI/pages/Profile.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    return Scaffold(
      appBar: AppBar(title: const Text("Регистрация")),
      body: Column(
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: profileStoreWatch.getEmailController,
            onChanged: profileStoreRead.setEmail,
            decoration: InputDecoration(
                labelText: 'email',
                errorText: profileStoreRead.getErrorMessageEmail),
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: profileStoreRead.getPasswordVisible,
            controller: profileStoreWatch.getPasswordController,
            onChanged: profileStoreRead.setPassword,
            decoration: InputDecoration(
              labelText: 'пароль',
              errorText: profileStoreRead.getErrorMessagePassword,
              suffixIcon: IconButton(
                  icon: Icon(profileStoreRead.getPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => profileStoreRead.changePasswordVisible()),
              alignLabelWithHint: false,
            ),
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: profileStoreRead.getPasswordRepeatVisible,
            controller: profileStoreWatch.getRepeatPasswordController,
            onChanged: profileStoreRead.setPasswordRepeat,
            decoration: InputDecoration(
              labelText: 'подтвердить пароль',
              errorText: profileStoreRead.getErrorMessagePasswordRepeat,
              suffixIcon: IconButton(
                  icon: Icon(profileStoreRead.getPasswordRepeatVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      profileStoreRead.changePasswordRepeatVisible()),
              alignLabelWithHint: false,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (profileStoreRead.getErrorMessageEmail == null &&
                    profileStoreRead.getErrorMessagePassword == null &&
                    profileStoreRead.getErrorMessagePasswordRepeat == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()));
                }
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                      const Color.fromRGBO(204, 128, 255, 1))),
              child: const Text("Войти")),
          InkWell(
            child: const Text("Авторизация"),
            onTap: () {
              profileStoreRead.setEmptyDataAuthorization();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthorizationScreen()));
            },
          ),
        ],
      ),
    );
  }
}
