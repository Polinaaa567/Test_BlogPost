import 'package:blog_post/StateManager/postProvider.dart';
import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/Authorization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileStore()),
        ChangeNotifierProvider(create: (context) => PostStore())
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
