import 'package:blog_post/StateManager/authentification_model.dart';
import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReEntry extends StatelessWidget {
  final String? pinCode;
  final String? email;
  final bool? useBiometric;
  final bool? state;

  const ReEntry([this.pinCode, this.email, this.useBiometric, this.state]);

  @override
  Widget build(BuildContext context) {
    AuthentificationModel authentificationModelRead =
        context.read<AuthentificationModel>();
    AuthentificationModel authentificationModelWatch =
        context.watch<AuthentificationModel>();
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30),
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
                          color:
                              authentificationModelWatch.pinCode.length > index
                                  ? Colors.green
                                  : Colors.red,
                          shape: BoxShape.circle),
                    );
                  }),
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.all(20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                children: [
                  ...List.generate(9, (index) {
                    return InkWell(
                      onTap: () async {
                        String digit = (index + 1).toString();
                        authentificationModelWatch.appendToPinCode(digit);
                        if (authentificationModelRead.pinCode.length == 4) {
                          if (state == true) {
                            if (authentificationModelRead.pinCode == pinCode) {
                              profileStoreRead.setIsUserAuth(true);
                              profileStoreRead.setEmail(email ?? "");

                              await postStoreWatch
                                  .fetchAllPosts(profileStoreRead.getEmail);
                              await profileStoreRead.getDataAboutUser();
                              await postStoreWatch
                                  .fetchMyPosts(profileStoreRead.getEmail);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) =>
                                          const HomeScreen()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Неправильный Пин-код")));
                            }
                          } else {
                            authentificationModelRead
                                .savePreferences(profileStoreRead.getEmail);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const HomeScreen()));
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  }),
                  Container(
                    margin: EdgeInsets.all(10),
                  ),
                  InkWell(
                    onTap: () async {
                      authentificationModelRead.appendToPinCode("0");
                      if (authentificationModelRead.pinCode.length == 4) {
                        if (state == true) {
                          if (authentificationModelRead.pinCode == pinCode) {
                            profileStoreRead.setIsUserAuth(true);
                            profileStoreRead.setEmail(email ?? "");
                            await postStoreWatch
                                .fetchAllPosts(profileStoreRead.getEmail);
                            await profileStoreRead.getDataAboutUser();
                            await postStoreWatch
                                .fetchMyPosts(profileStoreRead.getEmail);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const HomeScreen()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Неправильный Пин-код")));
                          }
                        } else {
                          authentificationModelRead
                              .savePreferences(profileStoreRead.getEmail);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => const HomeScreen()));
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
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
                      if (authentificationModelRead.pinCode.length == 0 &&
                          (authentificationModelRead.canCheckBiometrics ||
                              useBiometric == true)) {
                        await authentificationModelWatch.authenticate();

                        if (authentificationModelRead.isAuthenticating ==
                                true &&
                            authentificationModelRead.isCancelled != true &&
                            state == true) {
                          profileStoreRead.setIsUserAuth(true);
                          profileStoreRead.setEmail(email ?? "");
                          await postStoreWatch
                              .fetchAllPosts(profileStoreRead.getEmail);
                          await profileStoreRead.getDataAboutUser();
                          await postStoreWatch
                              .fetchMyPosts(profileStoreRead.getEmail);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => const HomeScreen()));
                        }
                      } else {
                        authentificationModelRead.removeLastDigit();
                      }
                    },
                    child: (authentificationModelWatch.isAuthenticating ==
                                false &&
                            authentificationModelRead.pinCode.length == 0)
                        ? (state == true && useBiometric == true)
                            ? Container(
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Icon(
                                    Icons.fingerprint,
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Icon(
                                    Icons.fingerprint,
                                    size: 24,
                                  ),
                                ),
                              )
                        : Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Icon(
                                Icons.backspace,
                                size: 24,
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ),
            // Text(authentificationModelWatch.pinCode ?? ""),
          ],
        ),
      ),
    );
  }
}
