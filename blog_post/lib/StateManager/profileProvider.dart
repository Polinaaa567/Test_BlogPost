import 'package:flutter/cupertino.dart';

class ProfileStore with ChangeNotifier {
  final TextEditingController _emailController = TextEditingController();
  TextEditingController get getEmailController => _emailController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get getPasswordController => _passwordController;

  final TextEditingController _repeatPasswordController =
      TextEditingController();
  TextEditingController get getRepeatPasswordController =>
      _repeatPasswordController;

  String _email = "";
  String _password = "";
  String _passwordRepeat = "";

  bool _isPasswordVisible = true;
  bool _isPasswordRepeatVisible = true;

  String get getEmail => _email;
  String get getPassword => _password;
  String get getPasswordRepeat => _passwordRepeat;
  bool get getPasswordVisible => _isPasswordVisible;
  bool get getPasswordRepeatVisible => _isPasswordRepeatVisible;

  void setEmail(String email) {
    _email = email;

    notifyListeners();
  }

  void setPassword(String passwd) {
    _password = passwd;

    notifyListeners();
  }

  void setPasswordRepeat(String passwd) {
    _passwordRepeat = passwd;

    notifyListeners();
  }

  void changePasswordVisible() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void changePasswordRepeatVisible() {
    _isPasswordRepeatVisible = !_isPasswordRepeatVisible;
    notifyListeners();
  }

  void setEmptyDataAuthorization() {
    _email = "";
    _password = "";
    _passwordRepeat = "";
    _emailController.clear();
    _repeatPasswordController.clear();
    _passwordController.clear();

    notifyListeners();
  }
}
