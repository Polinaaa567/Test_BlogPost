import 'dart:typed_data';

import 'package:intl/intl.dart';

class CommentStructure {
  final String textComment;
  final DateTime dateCreator;
  final String? lastName;
  final String? name;
  final Uint8List avatar;

  CommentStructure(
      {required this.textComment,
      required this.dateCreator,
      required this.lastName,
      required this.name,
      required this.avatar});

  factory CommentStructure.fromList(Map<String, dynamic> json) {
    List<int> avatarList = json['avatar'] != null
        ? (json['avatar'] as List<dynamic>).map((e) => e as int).toList()
        : [];
    return CommentStructure(
        textComment: json['text_comment'],
        dateCreator: DateFormat('dd-MM-yyyy').parse(json['date_creator']),
        lastName: json['last_name'],
        name: json['name'],
        avatar: Uint8List.fromList(avatarList));
  }
}
