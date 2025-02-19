import 'dart:typed_data';
import 'package:intl/intl.dart';

abstract class IComment {
  String get textComment;
  DateTime get dateCreator;
  String? get lastName;
  String? get name;
  Uint8List get avatar;

  factory IComment.fromList(Map<String, dynamic> json) {
    return Comment.fromList(json);
  }
}

class Comment implements IComment {
  @override
  final String textComment;
  @override
  final DateTime dateCreator;
  @override
  final String? lastName;
  @override
  final String? name;
  @override
  final Uint8List avatar;

  Comment({
    required this.textComment,
    required this.dateCreator,
    required this.lastName,
    required this.name,
    required this.avatar,
  });

  factory Comment.fromList(Map<String, dynamic> json) {
    List<int> avatarList = json['avatar'] != null
        ? (json['avatar'] as List<dynamic>).map((e) => e as int).toList()
        : [];
    return Comment(
      textComment: json['text_comment'],
      dateCreator: DateFormat('dd-MM-yyyy').parse(json['date_creator']),
      lastName: json['last_name'],
      name: json['name'],
      avatar: Uint8List.fromList(avatarList),
    );
  }
}
