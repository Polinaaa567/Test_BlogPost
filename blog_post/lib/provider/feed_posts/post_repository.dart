import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:blog_post/configs/config.dart';
import 'package:blog_post/entities/post.dart';

class FactoryPostRepository {
  static IPostRepository createPostRepository() {
    return PostRepository();
  }
}

abstract class IPostRepository {
  Future<List<Post>?> fetchAllPosts(String? email);
  Future<List<Post>?> fetchMyPosts(String email);
  Future<void> createNewDraftPost(int? idPost, String email, String headline,
      Uint8List imagePost, Uint8List listPhotoPost, String textPost);
  Future<void> deleteDraft(int idPost, String email);
  Future<void> createNewPublishedPost(
      int? idPost,
      String email,
      String headline,
      Uint8List imagePost,
      Uint8List listPhotoPost,
      String textPost);
  Future<List<dynamic>> fetchLikedPosts(int idPost, bool state, String email);
  Future<List<Post>?> fetchPostInfo(int idPost, String? email, bool isUserAuth);
  Future<List<Post>?> searchAllPosts(
      String currentTab, String? email, bool isUserAuth, String searchTextAll);
  Future<List<Post>?> searchMyPosts(
      String currentTab, String? email, String searchTextMy);
}

class PostRepository implements IPostRepository {
  @override
  Future<List<Post>?> fetchAllPosts(String? email) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post"),
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((elem) => Post.fromList(elem)).toList();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      return null;
    }
  }

  @override
  Future<List<Post>?> fetchMyPosts(String email) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/user"),
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((elem) => Post.fromList(elem)).toList();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      return null;
    }
  }

  @override
  Future<void> createNewDraftPost(int? idPost, String email, String headline,
      Uint8List imagePost, Uint8List listPhotoPost, String textPost) async {
    try {
      await http.post(Uri.parse("http://${MyIP.ipAddress}:8888/post/new/draft"),
          body: json.encode({
            "idPost": idPost,
            "email": email,
            "headline": headline,
            "photoPost": imagePost.isNotEmpty
                ? imagePost
                : (listPhotoPost.isNotEmpty)
                    ? listPhotoPost
                    : null,
            "textPost": textPost
          }),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      throw "Произошла ошибка: $e";
    }
  }

  @override
  Future<void> deleteDraft(int idPost, String email) async {
    await http.delete(Uri.parse("http://${MyIP.ipAddress}:8888/post"),
        body: json.encode({'email': email, 'idPost': idPost}),
        headers: {'Content-Type': 'application/json'});
  }

  @override
  Future<void> createNewPublishedPost(
      int? idPost,
      String email,
      String headline,
      Uint8List imagePost,
      Uint8List listPhotoPost,
      String textPost) async {
    try {
      await http
          .post(Uri.parse("http://${MyIP.ipAddress}:8888/post/new/published"),
              body: json.encode({
                "idPost": idPost,
                "email": email,
                "headline": headline,
                "photoPost": imagePost.isNotEmpty
                    ? imagePost
                    : (listPhotoPost.isNotEmpty)
                        ? listPhotoPost
                        : null,
                "textPost": textPost
              }),
              headers: {'Content-Type': 'application/json'});
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List> fetchLikedPosts(int idPost, bool state, String email) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/like"),
        body: json.encode({"idPost": idPost, "state": state, "email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load comments');
  }

  @override
  Future<List<Post>?> fetchPostInfo(
      int idPost, String? email, bool isUserAuth) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/info"),
        body: json.encode({"idPost": idPost, "email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((elem) => Post.fromList(elem)).toList();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      return null;
    }
  }

  @override
  Future<List<Post>?> searchAllPosts(String currentTab, String? email,
      bool isUserAuth, String searchTextAll) async {
    if (!isUserAuth) {
      email = null;
    }
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/find"),
        body: json.encode({
          "tabPost": currentTab,
          "email": email,
          "searchRequest": searchTextAll
        }),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((elem) => Post.fromList(elem)).toList();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      return null;
    }
  }

  @override
  Future<List<Post>?> searchMyPosts(
      String currentTab, String? email, String searchTextMy) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/find"),
        body: json.encode({
          "tabPost": currentTab,
          "email": email,
          "searchRequest": searchTextMy
        }),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((elem) => Post.fromList(elem)).toList();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      return null;
    }
  }
}
