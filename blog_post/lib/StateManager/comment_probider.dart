import 'dart:convert';

import 'package:blog_post/DTO/comment_structure.dart';
import 'package:blog_post/configure/config.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CommentsProvider with ChangeNotifier {
  List<CommentStructure>? _allComments = [];
  List<CommentStructure>? get allComments => _allComments;

  final TextEditingController _commentTextController = TextEditingController();
  TextEditingController get getCommentTextController => _commentTextController;

  String _commentText = '';
  String get commentText => _commentText;
  void setCommentText(String _commentText) {
    this._commentText = _commentText;
    notifyListeners();
  }

  Future<void> fetchAllComments(int idPost) async {
    final response = await http.get(
        Uri.parse("http://${MyIP.ipAddress}:8888/comments?idPost=$idPost"),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);

        _allComments =
            jsonData.map((elem) => CommentStructure.fromList(elem)).toList();
        notifyListeners();
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  // Сейчас не меняется кол-во комментариев в списках постов
  Future<void> newComment(int idPost, String email) async {
    Logger().d("я здесь");
    if(commentText != "") {

      final response = await http.post(
          Uri.parse("http://${MyIP.ipAddress}:8888/comments/new"),
          body: json.encode(
              {'email': email, 'idPost': idPost, "textComment": commentText}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        try {
          List<dynamic> jsonData = json.decode(response.body);
          _allComments =
              jsonData.map((elem) => CommentStructure.fromList(elem)).toList();
          _commentTextController.clear();
          _commentText = '';

          notifyListeners();
        } catch (e) {
          throw Exception(e);
        }
      }
    }
  }
}
