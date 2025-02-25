import 'package:blog_post/UI/auth_reg/re_entry.dart';
import 'package:blog_post/UI/auth_reg/text_field_widget_auth.dart';
import 'package:blog_post/UI/navigator_bar/home_screen.dart';
import 'package:blog_post/provider/authentication/authentication_model.dart';
import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthRegWidget extends StatelessWidget {
  const AuthRegWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    ProfileStore profileStoreWatch = context.watch<ProfileStore>();

    PostStore postStoreWatch = context.watch<PostStore>();

    AuthenticationModel authenticationModelRead =
        context.read<AuthenticationModel>();

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
              height: 630,
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
                      bottomRight: Radius.circular(30))),
              child: const Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Text(
                      "BlogPost",
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Caveat',
                        shadows: [
                          Shadow(
                              color: Color.fromRGBO(58, 36, 83, 1.0),
                              blurRadius: 10)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              height: 400,
              width: 450,
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
                ),
              ),
              child: Column(
                children: [
                  profileStoreWatch.isAuth
                      ? const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text("Авторизация",
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Caveat')))
                      : const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            "Регистрация",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Caveat'),
                          ),
                        ),
                  TextFieldWidget(
                      controller: profileStoreWatch.emailController,
                      obscureText: null,
                      setParams: profileStoreRead.setEmail,
                      labelText: "Email",
                      errorText: profileStoreRead.errorMessageEmail,
                      iconsSuffix: null),
                  TextFieldWidget(
                    controller: profileStoreWatch.passwordController,
                    obscureText: profileStoreRead.passwordVisible,
                    setParams: profileStoreRead.setPassword,
                    labelText: "Пароль",
                    errorText: profileStoreRead.errorMessagePassword,
                    iconsSuffix: IconButton(
                      icon: Icon(profileStoreRead.passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => profileStoreRead.changePasswordVisible(),
                    ),
                  ),
                  if (!profileStoreWatch.isAuth) ...[
                    TextFieldWidget(
                      controller: profileStoreWatch.repeatPasswordController,
                      obscureText: profileStoreRead.passwordRepeatVisible,
                      setParams: profileStoreRead.setPasswordRepeat,
                      labelText: "Повторный пароль",
                      errorText: profileStoreRead.errorMessagePasswordRepeat,
                      iconsSuffix: IconButton(
                        icon: Icon(profileStoreRead.passwordRepeatVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            profileStoreRead.changePasswordRepeatVisible(),
                      ),
                    ),
                  ],
                  if ((profileStoreRead.isAuth &&
                          profileStoreRead.errorMessageEmail == null &&
                          profileStoreRead.errorMessagePassword == null) ||
                      (!profileStoreRead.isAuth &&
                          profileStoreRead.errorMessageEmail == null &&
                          profileStoreRead.errorMessagePassword == null &&
                          profileStoreRead.errorMessagePasswordRepeat ==
                              null)) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(116, 72, 186, 1.0),
                          fixedSize: Size(mWidth * 0.3, mHeight * 0.05)),
                      onPressed: () async {
                        String? response;
                        if (profileStoreRead.isAuth) {
                          response = await profileStoreWatch.sendDataLogin();
                        } else {
                          response = await profileStoreWatch.sendDataReg();
                        }
                        if (response == null) {
                          postStoreWatch.setCurrentTab("My");
                          await authenticationModelRead
                              .checkBiometryAvailability();
                          await postStoreWatch
                              .fetchAllPosts(profileStoreWatch.email);
                          profileStoreRead.setIsUserAuth(true);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReEntry()));
                          if (profileStoreWatch.isAuth) {
                            await profileStoreWatch.fetchDataAboutUser();
                            await postStoreWatch
                                .fetchMyPosts(profileStoreWatch.email);
                          }
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(response)));
                        }
                      },
                      child: const Text(
                        "Войти",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    )
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
                        ? const Text(
                            "Регистрация",
                            style: TextStyle(fontSize: 15),
                          )
                        : const Text(
                            "Авторизация",
                            style: TextStyle(fontSize: 15),
                          ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(116, 72, 186, 1.0),
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    await postStoreWatch.fetchAllPosts(null);
                    postStoreWatch.setCurrentTab("All");
                    profileStoreRead.setIsUserAuth(false);

                    Navigator.of(context).pop();

                    await Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavigationBarMenu(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ошибка при загрузке данных'),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Войти без регистрации",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
