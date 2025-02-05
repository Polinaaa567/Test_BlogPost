import 'package:blog_post/StateManager/profileProvider.dart';
import 'package:blog_post/UI/pages/Authorization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ProfileStore())],
      child: const BlogPost(),
    ));

class BlogPost extends StatelessWidget {
  const BlogPost({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthorizationScreen(),
    );
  }
}
