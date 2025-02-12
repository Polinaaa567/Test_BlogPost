import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:blog_post/DTO/PostStructure.dart';
import 'package:blog_post/conf.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class PostStore with ChangeNotifier {
  IP ipAddress = IP();

  int _selectedPagesIndex = 0;
  int get getSelectedPagesIndex => _selectedPagesIndex;

  List<Posts>? _postsAll = [];
  bool _isLoading = true;

  List<Posts>? get getPosts => _postsAll;
  bool get isLoading => _isLoading;

  List<Posts>? _postsMy = [];
  List<Posts>? get getPostsMy => _postsMy;

  bool _isLiked = false;

  int _selectedPostId = 0;
  int get getSelectedPostID => _selectedPostId;

  void setSelectedPagesIndex(int index) {
    _selectedPagesIndex = index;

    notifyListeners();
  }

  TextEditingController _searchTextController = TextEditingController();
  TextEditingController get getSearchTextController => _searchTextController;

  String _searchText = "";
  String get getSearchText => _searchText;

  void setSearchText(String text) {
    _searchText = text;

    notifyListeners();
  }

  Future<void> getAllPosts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
          Uri.parse("http://${ipAddress.ipAddress}:8888/posts"),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        try {
          List<dynamic> jsonData = json.decode(response.body);

          _postsAll = jsonData.map((elem) => Posts.fromList(elem)).toList();
          Logger().d("check: $_postsAll");
          notifyListeners();
        } catch (e) {
          Logger().d('Ошибка при парсинге JSON: $e');
        }
        // notifyListeners();

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyPosts(String email) async {
    try {
      final response = await http.post(
          Uri.parse("http://${ipAddress.ipAddress}:8888/posts/user"),
          body: json.encode({"email": email}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        try {
          List<dynamic> jsonData = json.decode(response.body);

          _postsMy = jsonData.map((elem) => Posts.fromList(elem)).toList();
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

  Future<void> fetchDeleteDraft(int idPost) async{

  }
}
