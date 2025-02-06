import 'dart:ffi';

import 'package:flutter/cupertino.dart';

class PostStore with ChangeNotifier {
  int _selectedPagesIndex = 0;
  int get getSelectedPagesIndex => _selectedPagesIndex;

  void setSelectedPagesIndex(int index) {
    _selectedPagesIndex = index;

    notifyListeners();
  }
}