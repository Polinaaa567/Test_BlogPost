import 'dart:typed_data';

import 'package:logger/logger.dart';

class Posts {
  final String? lastName;
  final String? name;
  final Uint8List? avatar;
  final int idPost;
  final String? headline;
  final Uint8List? photoPost;
  final DateTime datePublished;
  final int? countLike;
  final int countComments;
  final String state;

  Posts(
      {required this.lastName,
      required this.name,
      required this.avatar,
      required this.idPost,
      required this.headline,
      required this.photoPost,
      required this.datePublished,
      required this.countLike,
      required this.countComments,
      required this.state});

  factory Posts.fromList(Map<String, dynamic> json) {
    Logger().d("json: $json");
    Logger().d("json id_post:  ${json['id_post']}");

    return Posts(
        lastName: json['last_name'],
        name: json['name'],
        avatar: json['avatar'],
        idPost: json['id_post'],
        headline: json['headline'],
        photoPost: json['photo_post'],
        datePublished: DateTime.parse(json['date_published']),
        countLike: json['count_like'],
    countComments: json['count_comments'],
    state: json['state'] ?? "all"
    );
  }
}
