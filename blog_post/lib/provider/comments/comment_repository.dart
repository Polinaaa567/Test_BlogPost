import 'dart:convert';

import 'package:blog_post/entities/comment.dart';
import 'package:http/http.dart' as http;
import 'package:blog_post/configs/config.dart';

class FactoryCommentRepository {
  static ICommentRepository createCommentRepository () {
    return CommentRepository();
  }
}

abstract class ICommentRepository {
    Future<void> newComment(int idPost, String email, String commentText);
    Future<List<IComment>?> fetchAllComments(int idPost);
}

class CommentRepository implements ICommentRepository {

  @override
  Future<List<IComment>?> fetchAllComments(int idPost) async{
    final response = await http.get(
        Uri.parse("http://${MyIP.ipAddress}:8888/comments?idPost=$idPost"),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((elem) => IComment.fromList(elem)).toList();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      return null;
    }
  }

  @override
  Future<void> newComment(int idPost, String email, String commentText) async {
    await http.post(Uri.parse("http://${MyIP.ipAddress}:8888/comments/new"),
        body: json.encode(
            {'email': email, 'idPost': idPost, "textComment": commentText}),
        headers: {'Content-Type': 'application/json'});
  }
}