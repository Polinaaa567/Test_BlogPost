import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/Authorization.dart';
import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatelessWidget {
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
            decoration: InputDecoration(labelText: 'email'),
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
            decoration: InputDecoration(
              labelText: 'пароль',
              suffixIcon: IconButton(
                  icon: Icon(profileStoreRead.getPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () => profileStoreRead.changePasswordVisible()),
              alignLabelWithHint: false,
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return "Введите пароль";
              else if (value.length < 8)
                return "Длина пароля должна быть не меньше 8";
              return null;
            },
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: profileStoreRead.getPasswordRepeatVisible,
            controller: profileStoreWatch.getRepeatPasswordController,
            onChanged: profileStoreRead.setPasswordRepeat,
            decoration: InputDecoration(
              labelText: 'подтвердить пароль',
              suffixIcon: IconButton(
                  icon: Icon(profileStoreRead.getPasswordRepeatVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      profileStoreRead.changePasswordRepeatVisible()),
              alignLabelWithHint: false,
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return "Введите пароль";
              else if (value.length < 8)
                return "Длина пароля должна быть не меньше 8";
              else if (!(value == profileStoreRead.getPassword))
                return "Пароли не совпадают";
              return null;
            },
          ),
          ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color.fromRGBO(204, 128, 255, 1))),
              child: Text("Войти")),
          InkWell(
            child: Text("Авторизация"),
            onTap: () {
              profileStoreRead.setEmptyDataAuthorization();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AuthorizationScreen()));
            },
          ),
        ],
      ),
    );
  }
}
