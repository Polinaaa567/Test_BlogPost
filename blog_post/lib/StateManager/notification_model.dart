import 'package:flutter/material.dart';

class NotificationModel extends ChangeNotifier {
  bool _isNotificateNewPost = false;
  bool get isNotificateNewPost => _isNotificateNewPost;

  void changeNotificateNewPost() {
    _isNotificateNewPost = !_isNotificateNewPost;
    notifyListeners();
  }

  bool _isNotificateLike = false;
  bool get isNotificateLike => _isNotificateLike;

  void changeNotificateLike() {
    _isNotificateLike = !_isNotificateLike;
    notifyListeners();
  }

  bool _isNotificateNewComment = false;
  bool get isNotificateNewComment => _isNotificateNewComment;

  void changeNotificateNewComment() {
    _isNotificateNewComment = !_isNotificateNewComment;
    notifyListeners();
  }

}