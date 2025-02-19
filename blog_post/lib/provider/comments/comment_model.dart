import 'package:blog_post/entities/comment.dart';
import 'package:blog_post/provider/comments/comment_repository.dart';
import 'package:flutter/material.dart';

class CommentsProvider with ChangeNotifier {
  ICommentRepository commentRepository =
      FactoryCommentRepository.createCommentRepository();

  List<IComment>? _allComments = [];
  List<IComment>? get allComments => _allComments;

  final TextEditingController _commentTextController = TextEditingController();
  TextEditingController get commentTextController => _commentTextController;

  String _commentText = '';
  void setCommentText(String commentText) {
    _commentText = commentText;
    notifyListeners();
  }

  Future<void> fetchAllComments(int idPost) async {
    try {
      List<IComment>? response =
          await commentRepository.fetchAllComments(idPost);
      _allComments = response;

      notifyListeners();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> newComment(int idPost, String email) async {
    try {
      if (_commentText != "") {
        await commentRepository.newComment(idPost, email, _commentText);

        _commentTextController.clear();
        _commentText = '';
        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
