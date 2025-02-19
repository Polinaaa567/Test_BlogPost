import 'package:blog_post/entities/post.dart';

abstract class IGroupedPosts {
  DateTime get date;
  List<Post> get posts;
  bool get isExpanded;

  String get formattedDate => '${date.day}-${date.month}-${date.year}';
  int get postCount => posts.length;
}


class GroupedPosts extends IGroupedPosts {
  @override
  final DateTime date;
  @override
  final List<Post> posts;
  @override
  bool isExpanded;

  GroupedPosts({
    required this.date,
    required this.posts,
    this.isExpanded = false,
  });



}
