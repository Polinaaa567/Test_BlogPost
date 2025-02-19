import 'package:blog_post/UI/navigator_bar/home_screen.dart';
import 'package:blog_post/provider/authentication/authentication_model.dart';
import 'package:blog_post/provider/notification/notification_model.dart';
import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReEntry extends StatelessWidget {
  final bool? state;

  const ReEntry([this.state]);

  @override
  Widget build(BuildContext context) {
    AuthenticationModel authenticationModelRead =
        context.read<AuthenticationModel>();
    AuthenticationModel authenticationModelWatch =
        context.watch<AuthenticationModel>();
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    NotificationModel notificationModelRead = context.read<NotificationModel>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: (state != true)
                  ? const Text("Введите новый пароль")
                  : const Text("Введите пароль"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 12.0,
                      height: 12,
                      decoration: BoxDecoration(
                          color: authenticationModelWatch.pinCode.length > index
                              ? Colors.green
                              : Colors.black,
                          shape: BoxShape.circle),
                    );
                  }),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  ...List.generate(9, (index) {
                    return InkWell(
                      onTap: () async {
                        String digit = (index + 1).toString();
                        authenticationModelWatch.appendToPinCode(digit);
                        if (authenticationModelWatch.pinCode.length == 4) {
                          if (state == true) {
                            if (authenticationModelRead.pinCode ==
                                authenticationModelRead.pinCodePrefs) {
                              profileStoreRead.setIsUserAuth(true);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              try {
                                profileStoreRead.setEmail(
                                    authenticationModelRead.email ?? "");
                                notificationModelRead.setEmail(
                                    authenticationModelRead.email ?? "");

                                await notificationModelRead
                                    .readAllPrefNotification();
                                await notificationModelRead.fetchAllCounts();
                                await notificationModelRead.savePrefAll();

                                await postStoreWatch
                                    .fetchAllPosts(profileStoreRead.email);
                                await postStoreWatch
                                    .fetchMyPosts(profileStoreRead.email);
                                await profileStoreRead.fetchDataAboutUser();

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          const NavigationBarMenu()),
                                  (Route<dynamic> route) => false,
                                );
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Ошибка при загрузке данных')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Неправильный Пин-код")));
                              authenticationModelWatch.cleanPinCode();
                            }
                          } else {
                            authenticationModelRead
                                .savePreferences(profileStoreRead.email);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      const NavigationBarMenu()),
                              (Route<dynamic> route) => false,
                            );
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.all(10),
                  ),
                  InkWell(
                    onTap: () async {
                      authenticationModelRead.appendToPinCode("0");
                      if (authenticationModelRead.pinCode.length == 4) {
                        if (state == true) {
                          if (authenticationModelRead.pinCode ==
                              authenticationModelRead.pinCodePrefs) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            try {
                              profileStoreRead.setIsUserAuth(true);
                              profileStoreRead
                                  .setEmail(authenticationModelRead.email);
                              notificationModelRead
                                  .setEmail(authenticationModelRead.email);

                              await notificationModelRead
                                  .readAllPrefNotification();
                              await notificationModelRead.fetchAllCounts();
                              await notificationModelRead.savePrefAll();

                              await postStoreWatch
                                  .fetchAllPosts(profileStoreRead.email);
                              await postStoreWatch
                                  .fetchMyPosts(profileStoreRead.email);
                              await profileStoreRead.fetchDataAboutUser();

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) =>
                                        const NavigationBarMenu()),
                                (Route<dynamic> route) => false,
                              );
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Ошибка при загрузке данных')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Неправильный Пин-код")));
                          }
                        } else {
                          authenticationModelRead
                              .savePreferences(profileStoreRead.email);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    const NavigationBarMenu()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                        child: Text(
                          "0",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (authenticationModelRead.pinCode.isEmpty &&
                          (authenticationModelRead.canCheckBiometrics ||
                              authenticationModelRead.isUseBiometry == true) &&
                          authenticationModelRead.isAuthenticating == false) {
                        await authenticationModelWatch.authenticate();

                        if (authenticationModelRead.isAuthenticating == true &&
                            authenticationModelRead.isCancelled != true &&
                            state == true) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          try {
                            profileStoreRead.setIsUserAuth(true);
                            profileStoreRead
                                .setEmail(authenticationModelRead.email);
                            await postStoreWatch
                                .fetchAllPosts(profileStoreRead.email);
                            await profileStoreRead.fetchDataAboutUser();
                            await postStoreWatch
                                .fetchMyPosts(profileStoreRead.email);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      const NavigationBarMenu()),
                              (Route<dynamic> route) => false,
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Ошибка при загрузке данных')),
                            );
                          }
                        }
                      } else {
                        authenticationModelRead.removeLastDigit();
                      }
                    },
                    child: (!authenticationModelWatch.isAuthenticating &&
                            authenticationModelRead.pinCode.isEmpty)
                        ? (state == true)
                            ? (authenticationModelRead.isUseBiometry)
                                ? Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Icon(
                                        Icons.fingerprint,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Icon(
                                        Icons.backspace,
                                        size: 24,
                                      ),
                                    ),
                                  )
                            : (authenticationModelRead.canCheckBiometrics)
                                ? Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Icon(
                                        Icons.fingerprint,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10),),
                                    child: const Center(
                                      child: Icon(
                                        Icons.backspace,
                                        size: 24,
                                      ),
                                    ),
                                  )
                        : Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),),
                            child: const Center(
                              child: Icon(
                                Icons.backspace,
                                size: 24,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
