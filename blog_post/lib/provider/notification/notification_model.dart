import 'package:blog_post/provider/notification/notificatoin_repository.dart';

import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';

class NotificationModel extends ChangeNotifier {
  INotificationRepository notificationRepository =
      FactoryNotificationRepository.createNotificationRepository();

  String _email = "";
  void setEmail(String email) {
    _email = email;

    notifyListeners();
  }

  bool _isNotificationNewPost = false;
  bool get isNotificationNewPost => _isNotificationNewPost;

  void changeNotificationNewPost() async {
    _isNotificationNewPost = !_isNotificationNewPost;
    notifyListeners();

    if (_isNotificationNewPost) {
      await fetchCountAllNotMyPosts();
      await savePrefNotificationNewPost();
    } else {
      await deletePrefNotificationNewPost();
    }
  }

  bool _isNotificationLike = false;
  bool get isNotificationLike => _isNotificationLike;

  void changeNotificationLike() async {
    _isNotificationLike = !_isNotificationLike;
    notifyListeners();

    if (_isNotificationLike) {
      await fetchCountLikes();
      await savePrefNotificationLike();
    } else {
      await deletePrefNotificationLike();
    }
  }

  bool _isNotificationNewComment = false;
  bool get isNotificationNewComment => _isNotificationNewComment;

  void changeNotificationNewComment() async {
    _isNotificationNewComment = !_isNotificationNewComment;
    notifyListeners();

    if (_isNotificationNewComment) {
      await fetchCountComments();
      await savePrefNotificationNewComment();
    } else {
      await deletePrefNotificationComment();
    }
  }

  Future<void> savePrefNotificationLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setBool('notify_like', _isNotificationLike);
      await prefs.setInt("count_like", _dbCountLike);

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка сохранения настроек: $e');
      throw Exception('Не удалось сохранить уведомления для нового поста');
    }
  }

  Future<void> savePrefNotificationNewPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      Logger().d("Уведомлять");
      await prefs.setBool('notify_new_post', _isNotificationNewPost);
      await prefs.setInt("count_post", _dbCountPost);
    } catch (e) {
      debugPrint('Ошибка сохранения настроек: $e');
      throw Exception('Не удалось сохранить уведомления для нового поста');
    }
  }

  Future<void> savePrefNotificationNewComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setBool('notify_new_comment', _isNotificationNewComment);
      await prefs.setInt("count_comments", _dbCountComment);
    } catch (e) {
      debugPrint('Ошибка сохранения настроек: $e');
      throw Exception('Не удалось сохранить уведомления для нового поста');
    }
  }

  Future<void> readPrefNotificationLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool("notify_like") ?? false;
    int intValue = prefs.getInt('count_like') ?? 0;

    _isNotificationLike = boolValue;
    _prefCountLike = intValue;

    notifyListeners();
  }

  Future<void> readPrefNotificationNewPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool("notify_new_post") ?? false;
    int intValue = prefs.getInt('count_post') ?? 0;

    _isNotificationNewPost = boolValue;
    _prefCountPost = intValue;

    notifyListeners();
  }

  Future<void> readPrefNotificationComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool boolValue = prefs.getBool("notify_new_comment") ?? false;
    int intValue = prefs.getInt('count_comments') ?? 0;

    _isNotificationNewComment = boolValue;
    _prefCountComment = intValue;

    notifyListeners();
  }

  Future<void> readAllPrefNotification() async {
    await readPrefNotificationLike();
    await readPrefNotificationNewPost();
    await readPrefNotificationComment();
  }

  Future<void> deletePrefNotificationLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await prefs.remove('notify_like');
      await prefs.remove("count_like");
    } catch (e) {
      debugPrint('Ошибка удаления настроек: $e');
      throw Exception('Не удалось удалить уведомления для нового поста');
    }
  }

  Future<void> deletePrefNotificationNewPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove('notify_new_post');
      await prefs.remove("count_post");

      Logger().d("Не уведомлять");
    } catch (e) {
      debugPrint('Ошибка удаления настроек: $e');
      throw Exception('Не удалось удалить уведомления для нового поста');
    }
  }

  Future<void> deletePrefNotificationComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.remove('notify_new_comment');
      await prefs.remove("count_comments");
    } catch (e) {
      debugPrint('Ошибка удаления настроек: $e');
      throw Exception('Не удалось удалить уведомления для нового поста');
    }
  }

  Future<void> deleteAllPref() async {
    await deletePrefNotificationComment();
    await deletePrefNotificationLike();
    await deletePrefNotificationNewPost();

    _isNotificationNewPost = false;
    _isNotificationLike = false;
    _isNotificationNewComment = false;

    notifyListeners();
  }

  Future<void> fetchCountAllNotMyPosts() async {
    _dbCountPost = await notificationRepository.fetchCountAllNotMyPosts(_email);
    notifyListeners();
  }

  Future<void> fetchCountLikes() async {
    _dbCountLike = await notificationRepository.fetchCountLikes(_email);
    notifyListeners();
  }

  Future<void> fetchCountComments() async {
    _dbCountComment = await notificationRepository.fetchCountComments(_email);
    notifyListeners();
  }

  Future<void> fetchAllCounts() async {
    if (_isNotificationNewPost) {
      await fetchCountAllNotMyPosts();
    }
    if (_isNotificationNewComment) {
      await fetchCountComments();
    }
    if (_isNotificationLike) {
      await fetchCountLikes();
    }
  }

  int _prefCountPost = 0;
  int _dbCountPost = 0;

  int? differencePosts() {
    int difference = _dbCountPost - _prefCountPost;
    if (difference > 0) {
      return difference;
    } else if (difference == 0 || difference < 0) {
      return null;
    }
    return null;
  }

  int _prefCountLike = 0;
  int _dbCountLike = 0;

  int? differenceLikes() {
    int difference = _dbCountLike - _prefCountLike;
    if (difference > 0) {
      return difference;
    } else if (difference == 0 || difference < 0) {
      return null;
    }
    return null;
  }

  int _prefCountComment = 0;
  int _dbCountComment = 0;

  int? differenceComments() {
    int difference = _dbCountComment - _prefCountComment;
    if (difference > 0) {
      return difference;
    } else if (difference == 0 || difference < 0) {
      return null;
    }
    return null;
  }

  Future<void> savePrefAll() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      if (_isNotificationNewPost) {
        await prefs.setInt("count_post", _dbCountPost);
      }
      if (_isNotificationLike) {
        await prefs.setInt("count_like", _dbCountLike);
      }
      if (_isNotificationNewComment) {
        await prefs.setInt("count_comments", _dbCountComment);
      }
    } catch (e) {
      debugPrint('Ошибка сохранения настроек: $e');
      throw Exception('Не удалось сохранить настройки');
    }
  }
}
