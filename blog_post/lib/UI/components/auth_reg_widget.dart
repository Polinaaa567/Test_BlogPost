import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/components/text_field_widget_auth.dart';
import 'package:blog_post/UI/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthRegWidget extends StatelessWidget {
  const AuthRegWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    double mWidth = MediaQuery.of(context).size.width;
    double mHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Stack(
          children: [
            Container(color: const Color.fromRGBO(232, 216, 255, 1)),
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                    height: mHeight * 0.76,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(115, 63, 184, 1.0),
                            Color.fromRGBO(181, 123, 255, 1.0)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))
                    ),
                  child: const Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 70),
                          child: Text("BlogPost",
                            style: TextStyle(
                                fontSize: 55,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Caveat',
                                shadows: [
                                  Shadow(
                                      color: Color.fromRGBO(58, 36, 83, 1.0),
                                      blurRadius: 10)
                                ]),
                          )),
                    ],
                  ),
                )),
            Center(
                child: Container(
                    height: mHeight * 0.5,
                    width: mWidth * 0.97,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.6),
                              spreadRadius: 6,
                              blurRadius: 10,
                              offset: Offset(0, 0))
                        ],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        )),
                    child: Column(children: [
                      profileStoreWatch.isAuth
                      ? const Text("Авторизация",
                          style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Caveat'))
                      : const Text(
                          "Регистрация",
                          style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Caveat'),
                        ),
                      TextFieldWidget(
                      controller: profileStoreWatch.getEmailController,
                      obscureText: null,
                      setParams: profileStoreRead.setEmail,
                      labelText: "Email",
                      errorText: profileStoreRead.getErrorMessageEmail,
                      iconsSuffix: null),
                  TextFieldWidget(
                    controller: profileStoreWatch.getPasswordController,
                    obscureText: profileStoreRead.getPasswordVisible,
                    setParams: profileStoreRead.setPassword,
                    labelText: "Пароль",
                    errorText: profileStoreRead.getErrorMessagePassword,
                    iconsSuffix: IconButton(
                        icon: Icon(profileStoreRead.getPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            profileStoreRead.changePasswordVisible()),
                  ),
                  if (!profileStoreWatch.isAuth) ...[
                    TextFieldWidget(
                      controller: profileStoreWatch.getRepeatPasswordController,
                      obscureText: profileStoreRead.getPasswordRepeatVisible,
                      setParams: profileStoreRead.setPasswordRepeat,
                      labelText: "Повторный пароль",
                      errorText: profileStoreRead.getErrorMessagePasswordRepeat,
                      iconsSuffix: IconButton(
                          icon: Icon(profileStoreRead.getPasswordRepeatVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              profileStoreRead.changePasswordRepeatVisible()),
                    ),
                  ],
                  if ((profileStoreRead.isAuth &&
                          profileStoreRead.getErrorMessageEmail == null &&
                          profileStoreRead.getErrorMessagePassword == null) ||
                      (!profileStoreRead.isAuth &&
                          profileStoreRead.getErrorMessageEmail == null &&
                          profileStoreRead.getErrorMessagePassword == null &&
                          profileStoreRead.getErrorMessagePasswordRepeat ==
                              null)) ...[
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(116, 72, 186, 1.0),
                            fixedSize: Size(mWidth * 0.3, mHeight * 0.05)),
                        onPressed: () async {
                          String? response;
                          if (profileStoreRead.isAuth) {
                            response = await profileStoreWatch.sendDataLogin();
                          } else {
                            response = await profileStoreWatch.sendDataReg();
                          }
                          if (response == null) {
                            await postStoreWatch
                                .fetchAllPosts(profileStoreWatch.getEmail);
                            profileStoreRead.setIsUserAuth(true);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                            if (profileStoreWatch.isAuth) {
                              await profileStoreWatch.getDataAboutUser();
                              await postStoreWatch
                                  .fetchMyPosts(profileStoreWatch.getEmail);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response)));
                          }
                        },
                        child: Text(
                          "Войти",
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ))
                  ],
                  Padding(
                    padding: EdgeInsets.only(top: mHeight * 0.01),
                  ),
                  InkWell(
                      onTap: () {
                        profileStoreRead.setEmptyDataAuthorization();
                        profileStoreRead.changeIsAuth();
                      },
                      child: profileStoreWatch.isAuth
                          ? const Text("Регистрация",
                              style: TextStyle(fontSize: 15))
                          : const Text("Авторизация",
                              style: TextStyle(fontSize: 15)))
                ]))),
        Positioned(
          bottom: mHeight * 0.18,
          left: mWidth * 0.15,
          right: mWidth * 0.15,
          top: mHeight * 0.77,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(116, 72, 186, 1.0),
              ),
              onPressed: () async {
                await postStoreWatch.fetchAllPosts(null);
                postStoreWatch.setCurrentTab("All");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
                profileStoreRead.setIsUserAuth(false);
              },
              child: Text(
                "Войти без регистрации",
                style: TextStyle(fontSize: 15, color: Colors.black),
              )),
        ),
      ],
    ));
  }
}
