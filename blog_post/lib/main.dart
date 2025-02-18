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

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        authentificationModelRead.readPinCodeFromPref(),
        authentificationModelRead.readEmailFromPref(),
        authentificationModelRead.readUseBiometryFromPref()
      ]).then((values) {
        return {
          'pinCode': values[0] as String?,
          'email': values[1] as String?,
          'useBiometry': values[2] as bool?,
        };
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const AuthRegWidget();
        } else {
          final pinCode = snapshot.data?['pinCode'];
          final email = snapshot.data?['email'];
          final useBiometry = snapshot.data?['useBiometry'];
          if (pinCode != null && pinCode.isNotEmpty && email != null && email.isNotEmpty) {
            return ReEntry(pinCode, email, useBiometry, true);
          } else {
            return const AuthRegWidget();
          }
        }
      },
    );
  }
}