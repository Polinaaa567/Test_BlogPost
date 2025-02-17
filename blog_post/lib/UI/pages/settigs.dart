import 'package:blog_post/StateManager/home_screen_provider.dart';
import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/auth_reg_widget.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PostStore postStoreRead = context.read<PostStore>();
    PostStore postStoreWatch = context.watch<PostStore>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();

    HomeScreenProvider homeScreenProviderRead =
        context.read<HomeScreenProvider>();

    return Center( child: SingleChildScrollView(
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
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (profileStoreRead.isUserAuth) ...[
                  BuildMenuItemMy(
                    text: "Профиль",
                    onPressed: () {
                      homeScreenProviderRead.setSelectedPagesIndex(1);
                    },
                  ),
                  const SizedBox(height: 16),
                  BuildMenuItemMy(text: "Уведомления", onPressed: () {}),
                  const SizedBox(height: 16),
                  BuildMenuItemMy(
                    text: "Удалить аккаунт",
                    onPressed: () async {
                      await profileStoreRead.deleteAccount();
                      profileStoreRead.setEmptyDataAuthorization();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthRegWidget(),
                        ),
                      );
                      homeScreenProviderRead.setSelectedPagesIndex(0);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                BuildMenuItemMy(
                  text: "Выход",
                  onPressed: () {
                    profileStoreRead.setEmptyDataAuthorization();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthRegWidget(),
                      ),
                    );
                    homeScreenProviderRead.setSelectedPagesIndex(0);
                  },
                ),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Text("version 0.0.0", style: TextStyle(color: Colors.white, fontSize: 17),),
                ),
              ],
            ),
            ),

          ],
        ),
      ),
    ));
  }
}

class BuildMenuItemMy extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BuildMenuItemMy(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(200, 50))
        ),
        child: Text(text, style: TextStyle(fontSize: 17)),
    );
  }
}
