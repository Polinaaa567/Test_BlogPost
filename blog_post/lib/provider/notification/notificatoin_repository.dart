import 'package:blog_post/configs/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

class FactoryNotificationRepository {
  static INotificationRepository createNotificationRepository () {
    return NotificationRepository();
  }
}

abstract class INotificationRepository {
  Future<int> fetchCountAllNotMyPosts(String email);
  Future<int> fetchCountLikes(String email);
  Future<int> fetchCountComments(String email);
}

class NotificationRepository implements INotificationRepository {

  @override
  Future<int> fetchCountAllNotMyPosts(String email) async{
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/count/posts"),
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        for (var item in jsonData) {
          return item['count_posts'];
        }
      } catch (e) {
        throw Exception(e);
      }
    }
    return 0;
  }

  @override
  Future<int> fetchCountComments(String email) async{
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/comments/count"),
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        for (var item in jsonData) {
          return item['comment_count'];
        }
      } catch (e) {
        throw Exception(e);
      }
    }
    return 0;
  }

  @override
  Future<int> fetchCountLikes(String email) async{
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/count/like"),
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        for (var item in jsonData) {
          return item['count_like'];
        }
      } catch (e) {
        throw Exception(e);
      }
    }
    return 0;
  }
}
