import 'package:blog_post/DTO/post_structure.dart';

class GroupedPosts {
  final DateTime date;
  final List<Posts> posts;
  bool isExpanded;

  GroupedPosts({
    required this.date,
    required this.posts,
    this.isExpanded = false,
  });

  String get formattedDate => '${date.day}-${date.month}-${date.year}';
  int get postCount => posts.length;
}