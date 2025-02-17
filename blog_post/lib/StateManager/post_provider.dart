import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';

import 'package:blog_post/Entities/grouped_posts.dart';
import 'package:blog_post/Entities/post_structure.dart';
import 'package:blog_post/configure/config.dart';

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

  void toggleGroupExpansion(
    int index,
  ) {
    final List<GroupedPosts>? postsList =
        _currentTab.contains("My") ? _groupedPostsMy : _groupedPostsAll;

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

  Future<void> fetchLikedPosts(Posts elem, String email) async {
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

          if (_currentTab.contains("My")) {
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

  bool _isThisEdit = false;
  bool get isThisEdit => _isThisEdit;

  void setIsThisEdit(bool isThisEdit) {
    _isThisEdit = isThisEdit;

    notifyListeners();
  }

  Future<void> fetchPostInfo(int idPost, String? email, bool isUserAuth) async {
    if (!isUserAuth) {
      email = null;
    }
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/post/info"),
        body: json.encode({"idPost": idPost, "email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonData = json.decode(response.body);
        _postOneInfo = jsonData.map((elem) => Posts.fromList(elem)).toList();

        notifyListeners();
        Logger().d("headlineeeeeee: $_isThisEdit");

        if (_isThisEdit) {
          for (var elem in _postOneInfo!) {
            _headline = elem.headline ?? "";
            _textPost = elem.textPost ?? "";
            _headlineController.text = elem.headline ?? "";
            _textPostController.text = elem.textPost ?? "";
            _listPhotoPost = elem.photoPost ?? Uint8List(0);
            _idPost = elem.idPost;
            notifyListeners();
          }
        }
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
      if (!isUserAuth) {
        email = null;
      }
      final response = await http.post(
          Uri.parse("http://${MyIP.ipAddress}:8888/post/find"),
          body: json.encode({
            "tabPost": _currentTab,
            "email": email,
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

  String setCountPosts(int count) {
    count = count % 10;

    if (count > 4 || (count >= 10 && count < 15)) {
      return "постов";
    } else if (count > 1) {
      return "поста";
    }
    return "пост";
  }

  bool _isOnePostInfo = false;
  bool get isOnePostInfo => _isOnePostInfo;

  void setIsOnePostInfo() {
    _isOnePostInfo = !isOnePostInfo;
    notifyListeners();
  }

  Future<void> createNewPublishedPost(String email) async {
    try {
      List<int>? jpgBytes;

      if (_imagePost != null) {
        jpgBytes = img.encodeJpg(_imagePost!);
      }
      await http
          .post(Uri.parse("http://${MyIP.ipAddress}:8888/post/new/published"),
              body: json.encode({
                "idPost": _idPost ?? null,
                "email": email,
                "headline": _headline,
                "photoPost": jpgBytes != null
                    ? jpgBytes
                    : (_listPhotoPost.isNotEmpty)
                        ? _listPhotoPost
                        : null,
                "textPost": _textPost
              }),
              headers: {'Content-Type': 'application/json'});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createNewDraftPost(String email) async {
    try {
      List<int>? jpgBytes;

      if (_imagePost != null) {
        jpgBytes = img.encodeJpg(_imagePost!);
      }

      await http.post(Uri.parse("http://${MyIP.ipAddress}:8888/post/new/draft"),
          body: json.encode({
            "idPost": _idPost ?? null,
            "email": email,
            "headline": _headline,
            "photoPost": jpgBytes != null
                ? jpgBytes
                : (_listPhotoPost.isNotEmpty)
                    ? _listPhotoPost
                    : null,
            "textPost": _textPost
          }),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      throw "Произошла ошибка: $e";
    }
  }

  int? _idPost = 0;
  int? get getIdPost => _idPost;

  Uint8List _listPhotoPost = Uint8List(0);
  Uint8List get listPhotoPost => _listPhotoPost;

  final TextEditingController _headlineController = TextEditingController();
  TextEditingController get getHeadlineController => _headlineController;

  String _headline = "";
  String get getHeadline => _headline;

  void setHeadline(String text) {
    _headline = text;
    notifyListeners();
  }

  img.Image? _imagePost;
  img.Image? get getImagePost => _imagePost;

  Future<void> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imagePost = img.decodeImage(File(pickedFile.path).readAsBytesSync());
      notifyListeners();
    }
  }

  final TextEditingController _textPostController = TextEditingController();
  TextEditingController get getTextPostController => _textPostController;

  String _textPost = "";
  String get getTextPost => _textPost;

  void setTextPost(String text) {
    _textPost = text;
    notifyListeners();
  }

  void clearPostsEdit() {
    _headlineController.clear();
    _textPostController.clear();
    _textPost = '';
    _headline = '';
    _listPhotoPost = Uint8List(0);
    _imagePost = null;
    _idPost = 0;
    _isPublished = false;
    // _postsAll =[];
    _postOneInfo = [];
    notifyListeners();

  }

  bool _isPublished = false;
  bool get isPublished => _isPublished;

  void changePublication() {
    _isPublished = !_isPublished;
    notifyListeners();
  }
}
