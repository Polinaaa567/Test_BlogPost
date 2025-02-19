import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blog_post/entities/profile.dart';
import 'package:blog_post/configs/config.dart';
import 'package:blog_post/provider/profile/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ProfileStore with ChangeNotifier {
  IProfileRepository profileRepository =
      FactoryProfileRepository.createProfileRepository();

  bool _isAuth = true;
  bool get isAuth => _isAuth;
  void changeIsAuth() {
    _isAuth = !_isAuth;
    notifyListeners();
  }

  final TextEditingController _emailController = TextEditingController();
  TextEditingController get emailController => _emailController;

  final TextEditingController _passwordController = TextEditingController();
  TextEditingController get passwordController => _passwordController;

  final TextEditingController _repeatPasswordController =
      TextEditingController();
  TextEditingController get repeatPasswordController =>
      _repeatPasswordController;

  String _email = "";
  String? _errorMessageEmail = "";
  String _password = "";
  String? _errorMessagePassword = "";
  String _passwordRepeat = "";
  String? _errorMessagePasswordRepeat = "";

  bool _isPasswordVisible = true;
  bool _isPasswordRepeatVisible = true;

  String get email => _email;
  String? get errorMessageEmail => _errorMessageEmail;

  String get password => _password;
  String? get errorMessagePassword => _errorMessagePassword;
  bool get passwordVisible => _isPasswordVisible;

  String get passwordRepeat => _passwordRepeat;
  String? get errorMessagePasswordRepeat => _errorMessagePasswordRepeat;
  bool get passwordRepeatVisible => _isPasswordRepeatVisible;

  List<IProfile>? _profileInfo = [];
  List<IProfile>? get profileInfo => _profileInfo;

  bool _isUserAuth = false;
  bool get isUserAuth => _isUserAuth;
  void changeIsUserAuth() {
    _isUserAuth = !_isUserAuth;
    notifyListeners();
  }

  void setIsUserAuth(bool isUserAuth) {
    _isUserAuth = isUserAuth;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    _verifyEmail();

    notifyListeners();
  }

  void _verifyEmail() {
    if (_email.isEmpty) {
      _errorMessageEmail = "Введите email";
    } else if (!EmailValidator.validate(_email)) {
      _errorMessageEmail = "Некорректный email";
    } else {
      _errorMessageEmail = null;
    }
  }

  void setPassword(String passwd) {
    _password = passwd;
    _validatePassword();

    notifyListeners();
  }

  void _validatePassword() {
    if (_password.isEmpty) {
      _errorMessagePassword = "Введите пароль";
    } else if (_password.length < 8) {
      _errorMessagePassword = "Длина пароля должна быть не меньше 8";
    } else {
      _errorMessagePassword = null;
    }
  }

  void setPasswordRepeat(String passwd) {
    _passwordRepeat = passwd;
    _validatePasswordRepeat();

    notifyListeners();
  }

  void _validatePasswordRepeat() {
    if (_passwordRepeat.isEmpty) {
      _errorMessagePasswordRepeat = "Введите пароль";
    } else if (_passwordRepeat.length < 8) {
      _errorMessagePasswordRepeat = "Длина пароля должна быть не меньше 8";
    } else if (_passwordRepeat != _password) {
      _errorMessagePasswordRepeat = "Пароли не совпадают";
    } else {
      _errorMessagePasswordRepeat = null;
    }
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
    _errorMessagePassword = "";
    _errorMessageEmail = "";
    _errorMessagePasswordRepeat = "";

    notifyListeners();
  }

  final TextEditingController _nameController = TextEditingController();
  TextEditingController get nameController => _nameController;

  final TextEditingController _lastNameController = TextEditingController();
  TextEditingController get lastNameController => _lastNameController;

  String? _name = "";
  String? _lastName = "";

  img.Image? _imageAvatar;
  Uint8List _bytes = Uint8List(0);

  String? get name => _name;
  String? get lastName => _lastName;
  img.Image? get imageAvatar => _imageAvatar;

  Uint8List get bytes => _bytes;

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
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB < 1) {
        _bytes = img.encodeJpg(img.decodeImage(file.readAsBytesSync())!);
        notifyListeners();
      }
    }
  }

  Future<dynamic> sendDataReg() async {
    return await profileRepository.sendDataReg(_email, _password);
  }

  Future<dynamic> sendDataLogin() async {
    return await profileRepository.sendDataLogin(_email, _password);
  }

  Future<dynamic> sendDataAboutUser() async {
    return await profileRepository.sendDataAboutUser(
        _email, _lastName, _bytes, _name);
  }

  Future<void> fetchDataAboutUser() async {
    try {
      _profileInfo = await profileRepository.fetchDataAboutUser(_email);

      for (var info in _profileInfo!) {
        _nameController.text = info.name ?? "";
        _lastNameController.text = info.lastName ?? "";

        _bytes = info.avatar.isNotEmpty ? info.avatar : Uint8List(0);
        _lastName = info.lastName ?? "";
        _name = info.name ?? "";

        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteAccount() async {
    await profileRepository.deleteAccount(_email);
  }
}
