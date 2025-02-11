import 'package:blog_post/DTO/PostStructure.dart';
import 'package:flutter/cupertino.dart';

class PostStore with ChangeNotifier {
  int _selectedPagesIndex = 0;
  int get getSelectedPagesIndex => _selectedPagesIndex;

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

  // PostStructure seachPosts() {
  //
  // }
}
