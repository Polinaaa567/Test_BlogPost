import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class Posts {
  final String? lastName;
  final String? name;
  final Uint8List avatar;
  final int idPost;
  final String? headline;
  final Uint8List? photoPost;
  final String? textPost;
  final DateTime datePublished;
  int? countLike;
  final int countComments;
  bool stateLike;
  final String state;

  Posts({
    required this.lastName,
    required this.name,
    required this.avatar,
    required this.idPost,
    required this.headline,
    required this.photoPost,
    required this.textPost,
    required this.datePublished,
    required this.countLike,
    required this.countComments,
    required this.stateLike,
    required this.state,
  });

  factory Posts.fromList(Map<String, dynamic> json) {
    Logger().d("json id_post:  ${json['id_post']}");
    List<int> avatarList = json['avatar'] != null
        ? (json['avatar'] as List<dynamic>).map((e) => e as int).toList()
        : [];
    return Posts(
      lastName: json['last_name'],
      name: json['name'],
      avatar: Uint8List.fromList(avatarList),
      idPost: json['id_post'],
      headline: json['headline'],
      photoPost: json['photo_post'],
      textPost: json['text_post'],
      datePublished: DateFormat('dd-MM-yyyy').parse(json['date_published']),
      countLike: json['count_like'],
      countComments: json['count_comments'],
      stateLike: (json['state_like'] == 0) ? false : true,
      state: json['state'] ?? "all",
    );
  }
}
