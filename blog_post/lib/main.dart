import 'package:blog_post/provider/authentication/authentication_model.dart';
import 'package:blog_post/provider/comments/comment_model.dart';
import 'package:blog_post/provider/navigation_bar/home_screen_model.dart';
import 'package:blog_post/provider/notification/notification_model.dart';
import 'package:blog_post/provider/feed_posts/post_model.dart';
import 'package:blog_post/provider/profile/profile_model.dart';
import 'package:blog_post/UI/auth_reg/re_entry_or_auth_future_builder.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProfileStore()),
        ChangeNotifierProvider(create: (context) => PostStore()),
        ChangeNotifierProvider(create: (context) => HomeScreenProvider()),
        ChangeNotifierProvider(create: (context) => CommentsProvider()),
        ChangeNotifierProvider(create: (context) => AuthenticationModel()),
        ChangeNotifierProvider(create: (context) => NotificationModel())
      ],
      child: const BlogPost(),
    ));

class BlogPost extends StatelessWidget {
  const BlogPost({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ReEntryOrAuth(),
    );
  }
}

