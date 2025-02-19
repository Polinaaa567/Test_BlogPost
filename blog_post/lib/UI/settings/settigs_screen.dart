import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:blog_post/provider/authentication/authentication_model.dart';
import 'package:blog_post/provider/navigation_bar/home_screen_model.dart';
import 'package:blog_post/provider/notification/notification_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:blog_post/UI/auth_reg/auth_reg_widget.dart';
import 'package:blog_post/UI/notification/notification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationModel notificationModelRead = context.read<NotificationModel>();
    ProfileStore profileStoreRead = context.read<ProfileStore>();
    AuthenticationModel authenticationModelRead =
        context.read<AuthenticationModel>();
    HomeScreenProvider homeScreenProviderRead =
        context.read<HomeScreenProvider>();

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(90, 64, 138, 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (profileStoreRead.isUserAuth) ...[
                      BuildMenuItem(
                        text: "Профиль",
                        onPressed: () {
                          homeScreenProviderRead.setSelectedPagesIndex(1);
                        },
                      ),
                      const SizedBox(height: 16),
                      BuildMenuItem(
                        text: "Уведомления",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen()));
                        },
                      ),
                      const SizedBox(height: 16),
                      BuildMenuItem(
                        text: "Удалить аккаунт",
                        onPressed: () async {
                          await profileStoreRead.deleteAccount();
                          await authenticationModelRead.cleanPrefs();
                          await notificationModelRead.deleteAllPref();
                          profileStoreRead.setEmptyDataAuthorization();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthRegWidget(),
                            ),
                            (Route<dynamic> route) => false,
                          );

                          homeScreenProviderRead.setSelectedPagesIndex(0);
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    BuildMenuItem(
                      text: "Выход",
                      onPressed: () async {
                        profileStoreRead.setEmptyDataAuthorization();
                        await authenticationModelRead.cleanPrefs();
                        await notificationModelRead.deleteAllPref();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthRegWidget(),
                          ),
                          (Route<dynamic> route) => false,
                        );

                        homeScreenProviderRead.setSelectedPagesIndex(0);
                      },
                    ),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "version 0.0.0",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildMenuItem extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BuildMenuItem({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(minimumSize: WidgetStateProperty.all(Size(200, 50))),
      child: Text(text, style: const TextStyle(fontSize: 17)),
    );
  }
}
