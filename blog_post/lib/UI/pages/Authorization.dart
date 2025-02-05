import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/Registration.dart';
import 'package:email_validator/email_validator.dart';

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
              decoration: InputDecoration(labelText: "email"),
              onChanged: profileStoreRead.setEmail,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return "Введите email";
                else if (!EmailValidator.validate(value))
                  return "Некорректный email";
                return null;
              },
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              obscureText: profileStoreRead.getPasswordVisible,
              controller: profileStoreWatch.getPasswordController,
              onChanged: profileStoreRead.setPassword,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return "Введите пароль";
                else if (value.length < 8)
                  return "Длина пароля должна быть не меньше 8";
                return null;
              },
              decoration: InputDecoration(
                labelText: "Пароль",
                suffixIcon: IconButton(
                    icon: Icon(profileStoreRead.getPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => profileStoreRead.changePasswordVisible()),
                alignLabelWithHint: false,
              ),
            ),
            ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(204, 128, 255, 1))),
                child: Text("Войти")),
            InkWell(
              child: Text("Зарегистрироваться"),
              onTap: () {
                profileStoreRead.setEmptyDataAuthorization();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen()));
              },
            ),
          ],
        ));
  }
}
