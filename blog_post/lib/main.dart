import 'package:blog_post/StateManager/authentification_model.dart';
import 'package:blog_post/StateManager/comment_probider.dart';
import 'package:blog_post/StateManager/home_screen_provider.dart';
import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/auth_reg_widget.dart';
import 'package:blog_post/UI/pages/re_entry.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileStore()),
        ChangeNotifierProvider(create: (context) => PostStore()),
        ChangeNotifierProvider(create: (context) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (context) => CommentsProvider()),
        ChangeNotifierProvider(create: (context) => AuthentificationModel())
      ],
      child: const BlogPost(),
    ));

class BlogPost extends StatelessWidget {
  const BlogPost({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReEntryOrAuth(),
    );
  }
}

class ReEntryOrAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthentificationModel authentificationModelRead =
    context.read<AuthentificationModel>();
    AuthentificationModel authentificationModelWatch =
    context.watch<AuthentificationModel>();

    ProfileStore profileStoreRead = context.read<ProfileStore>();

    return FutureBuilder<Map<String, String?>>(
      future: Future.wait([
        authentificationModelRead.readPinCodeFromPref(),
        authentificationModelRead.readEmailFromPref(),
      ]).then((values) {
        return {
          'pinCode': values[0] as String?,
          'email': values[1] as String?,
        };
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const AuthRegWidget();
        } else {
          final pinCode = snapshot.data?['pinCode'];
          final email = snapshot.data?['email'];
          if (pinCode != null && pinCode.isNotEmpty && email != null && email.isNotEmpty) {
            return ReEntry(pinCode, email);
          } else {
            return const AuthRegWidget();
          }
        }
      },
    );
  }
}