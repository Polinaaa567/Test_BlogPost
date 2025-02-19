import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

abstract class IPost {
  String? get lastName;
  String? get name;
  Uint8List get avatar;
  int get idPost;
  String? get headline;
  Uint8List get photoPost;
  String? get textPost;
  DateTime get datePublished;
  int? get countLike;
  int get countComments;
  bool get stateLike;
  String get state;

  factory IPost.fromList(Map<String, dynamic> json) {
    return Post.fromList(json);
  }
}

class Post implements IPost {
  @override
  final String? lastName;
  @override
  final String? name;
  @override
  final Uint8List avatar;
  @override
  final int idPost;
  @override
  final String? headline;
  @override
  final Uint8List photoPost;
  @override
  final String? textPost;
  @override
  final DateTime datePublished;
  @override
  int? countLike;
  @override
  final int countComments;
  @override
  bool stateLike;
  @override
  final String state;

  Post({
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

  factory Post.fromList(Map<String, dynamic> json) {
    Logger().d("json id_post:  ${json['id_post']}");
    List<int> avatarList = json['avatar'] != null
        ? (json['avatar'] as List<dynamic>).map((e) => e as int).toList()
        : [];

    List<int> photoPost = json['photo_post'] != null
        ? (json['photo_post'] as List<dynamic>).map((e) => e as int).toList()
        : [];

    return Post(
      lastName: json['last_name'],
      name: json['name'],
      avatar: Uint8List.fromList(avatarList),
      idPost: json['id_post'],
      headline: json['headline'],
      photoPost: Uint8List.fromList(photoPost),
      textPost: json['text_post'],
      datePublished: DateFormat('dd-MM-yyyy').parse(json['date_published']),
      countLike: json['count_like'],
      countComments: json['count_comments'],
      stateLike: (json['state_like'] == 0 || json['state_like'] == null) ? false : true,
      state: json['state'] ?? "all",
    );
  }
}
