import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:blog_post/provider/feed_posts/post_repository.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';

import 'package:blog_post/entities/grouped_posts.dart';
import 'package:blog_post/entities/post.dart';

class PostStore with ChangeNotifier {
  IPostRepository postRepository = FactoryPostRepository.createPostRepository();

  List<Post>? _postsAll = [];
  List<Post>? _postsMy = [];

  String _currentTab = 'My';
  String get currentTab => _currentTab;

  void setCurrentTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  List<IGroupedPosts>? _groupedPostsAll;
  List<IGroupedPosts>? _groupedPostsMy;

  List<IGroupedPosts>? get groupedPostsAll => _groupedPostsAll;
  List<IGroupedPosts>? get groupedPostsMy => _groupedPostsMy;

  void groupPostsAll() {
    if (_postsAll != null) {
      final Map<DateTime, List<Post>> groupedMap = {};
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
      final Map<DateTime, List<Post>> groupedMap = {};
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

  void toggleGroupExpansion(int index) {
    final List<IGroupedPosts>? postsList =
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
    _postsAll = await postRepository.fetchAllPosts(email);

    groupPostsAll();
    notifyListeners();
  }

  Future<void> fetchMyPosts(String email) async {
    _postsMy = await postRepository.fetchMyPosts(email);

    groupPostsMy();
    notifyListeners();
  }

  Future<void> createNewDraftPost(String email) async {
    await postRepository.createNewDraftPost(
        _idPost, email, _headline, _imagePost, _listPhotoPost, _textPost);
  }

  Future<void> deleteDraft(int idPost, String email) async {
    await postRepository.deleteDraft(idPost, email);

    _postsMy!.removeWhere((elem) => elem.idPost == idPost);
    groupPostsMy();
    notifyListeners();

    Logger().d(_postsMy);
  }

  Future<void> fetchLikedPosts(Post elem, String email) async {
    elem.stateLike = !elem.stateLike;
    notifyListeners();

    Logger().d("idPost = ${elem.idPost}, isLiked = ${elem.stateLike}}");

    try {
      List<dynamic> jsonData = await postRepository.fetchLikedPosts(
          elem.idPost, elem.stateLike, email);

      for (var item in jsonData) {
        elem.countLike = item["count_like"];

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

        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  List<Post>? _postOneInfo = [];
  List<Post>? get postOneInfo => _postOneInfo;

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
    try {
      _postOneInfo =
          await postRepository.fetchPostInfo(idPost, email, isUserAuth);

      notifyListeners();
      Logger().d("headlineeeeeee: $_isThisEdit");

      if (_isThisEdit) {
        for (var elem in _postOneInfo!) {
          _headline = elem.headline ?? "";
          _textPost = elem.textPost ?? "";
          _headlineController.text = elem.headline ?? "";
          _textPostController.text = elem.textPost ?? "";
          _listPhotoPost = elem.photoPost;
          _idPost = elem.idPost;
          notifyListeners();
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  final TextEditingController _searchTextMyController = TextEditingController();
  TextEditingController get searchTextMyController => _searchTextMyController;

  String _searchTextMy = "";
  String get searchTextMy => _searchTextMy;

  void setSearchTextMy(String text) {
    _searchTextMy = text;
    notifyListeners();
  }

  final TextEditingController _searchTextAllController =
      TextEditingController();
  TextEditingController get searchTextAllController => _searchTextAllController;

  String _searchTextAll = "";
  String get searchTextAll => _searchTextAll;

  void setSearchTextAll(String text) {
    _searchTextAll = text;
    notifyListeners();
  }

  Future<void> searchPosts(String? email, bool isUserAuth) async {
    if (_currentTab == "All") {
      if (!isUserAuth) {
        email = null;
      }

      try {
        _postsAll = await postRepository.searchAllPosts(
            _currentTab, email, isUserAuth, _searchTextAll);
        Logger().d("searhPostsAll: $_currentTab, $email, $_searchTextAll");
        groupPostsAll();

        notifyListeners();
      } catch (e) {
        throw Exception(e);
      }
    } else {
      Logger().d("searchPostsMy: $_currentTab, $email, $_searchTextMy");

      try {
        _postsMy = await postRepository.searchMyPosts(
            _currentTab, email, _searchTextMy);
        Logger().d("searchPostsMy: $_currentTab, $email, $_searchTextMy");
        groupPostsMy();

        notifyListeners();
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  String setCountPosts(int count) {
    final countNew = count % 10;

    if (countNew > 4 && countNew < 10) {
      return "постов";
    } else if (countNew > 1) {
      return "поста";
    } else if ((count >= 10 && count < 15)) {
      return "постов";
    } else if (countNew == 0) {
      return "постов";
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
      await postRepository.createNewPublishedPost(
          _idPost, email, _headline, _imagePost, _listPhotoPost, _textPost);
    } catch (e) {
      throw Exception(e);
    }
  }

  int? _idPost = 0;
  int? get idPost => _idPost;

  Uint8List _listPhotoPost = Uint8List(0);
  Uint8List get listPhotoPost => _listPhotoPost;

  final TextEditingController _headlineController = TextEditingController();
  TextEditingController get headlineController => _headlineController;

  String _headline = "";
  String get headline => _headline;

  void setHeadline(String text) {
    _headline = text;
    notifyListeners();
  }

  Uint8List _imagePost = Uint8List(0);
  Uint8List get imagePost => _imagePost;

  Future<void> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);
      if (sizeInMB < 1) {
        _imagePost = img.encodeJpg(
            img.decodeImage(File(pickedFile.path).readAsBytesSync())!);
        notifyListeners();
      }
    }
  }

  final TextEditingController _textPostController = TextEditingController();
  TextEditingController get textPostController => _textPostController;

  String _textPost = "";
  String get textPost => _textPost;

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
    _imagePost = Uint8List(0);
    _idPost = 0;
    _isPublished = false;
    _postOneInfo = [];
    notifyListeners();
  }

  void clearAll() {
    clearPostsEdit();
    clearSearchAll();
    clearSearchMy();
    _postsAll = [];
    _postsMy = [];
    _currentTab = "My";
    notifyListeners();
  }

  bool _isPublished = false;
  bool get isPublished => _isPublished;

  void changePublication() {
    _isPublished = !_isPublished;
    notifyListeners();
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
