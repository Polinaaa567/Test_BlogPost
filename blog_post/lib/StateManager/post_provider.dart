import 'dart:convert';
import 'dart:core';
import 'package:blog_post/DTO/grouped_posts.dart';
import 'package:flutter/material.dart';

import 'package:blog_post/DTO/post_structure.dart';
import 'package:blog_post/configure/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class PostStore with ChangeNotifier {
  List<Posts>? _postsAll = [];
  List<Posts>? get getPostsAll => _postsAll;

  List<Posts>? _postsMy = [];
  List<Posts>? get getPostsMy => _postsMy;

  void setPosts(List<Posts> posts) {
    _postsAll = posts;
    notifyListeners();
  }

  String _currentTab = 'My';
  String get getCurrentTab => _currentTab;

  void setCurrentTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  List<GroupedPosts>? _groupedPostsAll;
  List<GroupedPosts>? _groupedPostsMy;

  List<GroupedPosts>? get groupedPostsAll => _groupedPostsAll;
  List<GroupedPosts>? get groupedPostsMy => _groupedPostsMy;

  void groupPostsAll() {
    if (_postsAll != null) {
      final Map<DateTime, List<Posts>> groupedMap = {};
      for (var post in _postsAll!) {
        DateTime dateKey = DateTime(post.datePublished.year,
            post.datePublished.month, post.datePublished.day);
        if (!groupedMap.containsKey(dateKey)) {
          groupedMap[dateKey] = [];
        }
        groupedMap[dateKey]!.add(post);
      }
      _groupedPostsAll = groupedMap.entries
          .map((entry) => GroupedPosts(
                date: entry.key,
                posts: entry.value,
              ))
          .toList();
    }
    notifyListeners();
  }

  void groupPostsMy() {
    if (_postsMy != null) {
      final Map<DateTime, List<Posts>> groupedMap = {};
      for (var post in _postsMy!) {
        DateTime dateKey = DateTime(post.datePublished.year,
            post.datePublished.month, post.datePublished.day);
        if (!groupedMap.containsKey(dateKey)) {
          groupedMap[dateKey] = [];
        }
        groupedMap[dateKey]!.add(post);
      }
      _groupedPostsMy = groupedMap.entries
          .map((entry) => GroupedPosts(
                date: entry.key,
                posts: entry.value,
              ))
          .toList();
      notifyListeners();
    }
  }

  void toggleGroupExpansion(int index, bool isMyPosts) {
    final List<GroupedPosts>? postsList =
        isMyPosts ? _groupedPostsMy : _groupedPostsAll;

    if (postsList != null && index < postsList.length) {
      postsList[index] = GroupedPosts(
        date: postsList[index].date,
        posts: postsList[index].posts,
        isExpanded: !postsList[index].isExpanded,
      );
      notifyListeners();
    }
  }

  Future<void> fetchAllPosts(String? email) async {
    try {
      final response = await http.post(
          Uri.parse("http://${MyIP.ipAddress}:8888/post"),
          body: json.encode({"email": email}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        try {
          List<dynamic> jsonData = json.decode(response.body);
          _postsAll = jsonData.map((elem) => Posts.fromList(elem)).toList();
          groupPostsAll();

          notifyListeners();
        } catch (e) {
          Logger().d('Ошибка при парсинге JSON: $e');
        }
      } else {
        throw Exception('Ошибка загрузки поста');
      }
    } catch (e) {
      notifyListeners();
    }
  }

  Future<void> fetchMyPosts(String email) async {
    try {
      final response = await http.post(
          Uri.parse("http://${MyIP.ipAddress}:8888/post/user"),
          body: json.encode({"email": email}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        try {
          List<dynamic> jsonData = json.decode(response.body);

          _postsMy = jsonData.map((elem) => Posts.fromList(elem)).toList();
          groupPostsMy();
          notifyListeners();
        } catch (e) {
          Logger().d('Ошибка при парсинге JSON: $e');
        }
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      Logger().d('Ошибка в response: $e');
    }
  }

  Future<void> deleteDraft(int idPost, String email) async {
    await http.delete(Uri.parse("http://${MyIP.ipAddress}:8888/post/delete"),
        body: json.encode({'email': email, 'idPost': idPost}),
        headers: {'Content-Type': 'application/json'});

    _postsMy!.removeWhere((elem) => elem.idPost == idPost);
    groupPostsMy();
    notifyListeners();

    Logger().d(_postsMy);
  }

  Future<void> fetchLikedPosts(Posts elem, String email, bool isMyPosts) async {
    elem.stateLike = !elem.stateLike;
    notifyListeners();

    Logger().d("idPost = ${elem.idPost}, isLiked = ${elem.stateLike}}");

    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/like"),
        body: json.encode(
            {"idPost": elem.idPost, "state": elem.stateLike, "email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);

        for (var item in jsonData) {
          elem.countLike = item["count_like"];
          notifyListeners();

          if (isMyPosts) {
            for (var i in _postsAll!) {
              if (i.idPost == elem.idPost) {
                i.countLike = item["count_like"];
                i.stateLike = elem.stateLike;
              }
            }
          } else {
            for (var i in _postsMy!) {
              if (i.idPost == elem.idPost) {
                i.countLike = item["count_like"];
                i.stateLike = elem.stateLike;
              }
            }
          }
        }
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  List<Posts>? _postOneInfo = [];
  List<Posts>? get getPostOneInfo => _postOneInfo;

  Future<void> fetchPostInfo(int idPost, String email) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/info"),
        body: json.encode({"idPost": idPost, "email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        _postOneInfo = jsonData.map((elem) => Posts.fromList(elem)).toList();

        notifyListeners();
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  final TextEditingController _searchTextMyController = TextEditingController();
  TextEditingController get getSearchTextMyController =>
      _searchTextMyController;

  String _searchTextMy = "";
  String get getSearchTextMy => _searchTextMy;

  void setSearchTextMy(String text) {
    _searchTextMy = text;
    notifyListeners();
  }

  final TextEditingController _searchTextAllController =
      TextEditingController();
  TextEditingController get getSearchTextAllController =>
      _searchTextAllController;

  String _searchTextAll = "";
  String get getSearchTextAll => _searchTextAll;

  void setSearchTextAll(String text) {
    _searchTextAll = text;
    notifyListeners();
  }

  Future<void> searchPosts(String? email, bool isUserAuth) async {
    if (_currentTab == "All") {
      if(!isUserAuth) {
        email = null;
      }
      final response = await http.post(
          Uri.parse("http://${MyIP.ipAddress}:8888/post/find"),
          body: json.encode({
            "tabPost": _currentTab,
            "email": email ,
            "searchRequest": _searchTextAll
          }),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        try {
          List<dynamic> jsonData = json.decode(response.body);

          _postsAll = jsonData.map((elem) => Posts.fromList(elem)).toList();
          Logger().d("searhPostsAll: $_currentTab, $email, $_searchTextAll");
          groupPostsAll();

          notifyListeners();
        } catch (e) {
          throw Exception(e);
        }
      }
    } else {
      Logger().d("searhPostsMy: $_currentTab, $email, $_searchTextMy");
      final response = await http.post(
          Uri.parse("http://${MyIP.ipAddress}:8888/post/find"),
          body: json.encode({
            "tabPost": _currentTab,
            "email": email,
            "searchRequest": _searchTextMy
          }),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        try {
          List<dynamic> jsonData = json.decode(response.body);

          _postsMy = jsonData.map((elem) => Posts.fromList(elem)).toList();
          Logger().d("searhPostsMy: $_currentTab, $email, $_searchTextMy");
          groupPostsMy();

          notifyListeners();
        } catch (e) {
          throw Exception(e);
        }
      }
    }
  }

  void clearSearchMy() {
    _searchTextMyController.clear();
    _searchTextMy = '';

    notifyListeners();
  }

  void clearSearchAll() {
    _searchTextAllController.clear();
    _searchTextAll = '';

    notifyListeners();
  }
}
