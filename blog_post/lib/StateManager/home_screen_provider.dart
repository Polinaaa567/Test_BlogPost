import 'package:flutter/material.dart';

class HomeScreenProvider with ChangeNotifier {
  int _selectedPagesIndex = 0;
  int get getSelectedPagesIndex => _selectedPagesIndex;

  void setSelectedPagesIndex(int index) {
    _selectedPagesIndex = index;

    notifyListeners();
  }
}