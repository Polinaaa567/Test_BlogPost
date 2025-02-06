import 'dart:io';

import 'package:blog_post/UI/pages/DTO/PostStructure.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

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
  String? _errorMessageEmail = "";
  String _password = "";
  String? _errorMessagePassword = "";
  String _passwordRepeat = "";
  String? _errorMessagePasswordRepeat = "";

  bool _isPasswordVisible = true;
  bool _isPasswordRepeatVisible = true;

  String get getEmail => _email;
  String? get getErrorMessageEmail => _errorMessageEmail;

  String get getPassword => _password;
  String? get getErrorMessagePassword => _errorMessagePassword;
  bool get getPasswordVisible => _isPasswordVisible;

  String get getPasswordRepeat => _passwordRepeat;
  String? get getErrorMessagePasswordRepeat => _errorMessagePasswordRepeat;
  bool get getPasswordRepeatVisible => _isPasswordRepeatVisible;

  void setEmail(String email) {
    _email = email;
    _validteEmail();

    notifyListeners();
  }

  void _validteEmail() {
    if (_email.isEmpty) _errorMessageEmail = "Введите email";
    else if (!EmailValidator.validate(_email)) _errorMessageEmail = "Некорректный email";
    else _errorMessageEmail = null;
  }

  void setPassword(String passwd) {
    _password = passwd;
    _validatePassword();

    notifyListeners();
  }

  void _validatePassword() {
    if (_password.isEmpty)
      _errorMessagePassword = "Введите пароль";
    else if (_password.length < 8)
      _errorMessagePassword = "Длина пароля должна быть не меньше 8";
    else _errorMessagePassword = null;
  }

  void setPasswordRepeat(String passwd) {
    _passwordRepeat = passwd;
    _validatePasswordRepeat();

    notifyListeners();
  }

  void _validatePasswordRepeat() {
    if (_passwordRepeat.isEmpty) _errorMessagePasswordRepeat = "Введите пароль";
    else if (_passwordRepeat.length < 8) _errorMessagePasswordRepeat = "Длина пароля должна быть не меньше 8";
    else if (_passwordRepeat != _password) _errorMessagePasswordRepeat = "Пароли не совпадают";
    else _errorMessagePasswordRepeat = null;
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

  final TextEditingController _nameController = TextEditingController();
  TextEditingController get getNameController => _nameController;

  final TextEditingController _lastNameController = TextEditingController();
  TextEditingController get getLastNameController => _lastNameController;

  String _name = "";
  String _lastName = "";
  img.Image? _imageAvatar = null;

  String get getName => _name;
  String get getLastName => _lastName;
  img.Image? get getImageAvatar => _imageAvatar;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setLastName(String lastName) {
    _lastName = lastName;
    notifyListeners();
  }

  Future<void> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageAvatar = img.decodeImage(File(pickedFile.path).readAsBytesSync());

      Logger().d(_imageAvatar?.data);

      notifyListeners();
    }

    void saveDataAboutUser () {
      UserData(_imageAvatar, _email, _password, _lastName, _name);
    }
  }
}
