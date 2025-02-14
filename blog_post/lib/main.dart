import 'package:blog_post/StateManager/comment_probider.dart';
import 'package:blog_post/StateManager/home_screen_provider.dart';
import 'package:blog_post/StateManager/post_provider.dart';
import 'package:blog_post/StateManager/profile_provider.dart';
import 'package:blog_post/UI/pages/authorization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileStore()),
        ChangeNotifierProvider(create: (context) => PostStore()),
        ChangeNotifierProvider(create: (context) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (context) => CommentsProvider())
      ],
      child: const BlogPost(),
    ));

class BlogPost extends StatelessWidget {
  const BlogPost({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthorizationScreen(),
    );
  }
}
