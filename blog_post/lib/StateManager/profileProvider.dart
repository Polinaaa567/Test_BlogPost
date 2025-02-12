import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blog_post/DTO/profile.dart';
import 'package:blog_post/conf.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

class ProfileStore with ChangeNotifier {
  IP ipAddress = IP();

  // final _ipAddress = json.decode(jsonS)['ip_address'];

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
    if (_email.isEmpty)
      _errorMessageEmail = "Введите email";
    else if (!EmailValidator.validate(_email))
      _errorMessageEmail = "Некорректный email";
    else
      _errorMessageEmail = null;
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
    else
      _errorMessagePassword = null;
  }

  void setPasswordRepeat(String passwd) {
    _passwordRepeat = passwd;
    _validatePasswordRepeat();

    notifyListeners();
  }

  void _validatePasswordRepeat() {
    if (_passwordRepeat.isEmpty)
      _errorMessagePasswordRepeat = "Введите пароль";
    else if (_passwordRepeat.length < 8)
      _errorMessagePasswordRepeat = "Длина пароля должна быть не меньше 8";
    else if (_passwordRepeat != _password)
      _errorMessagePasswordRepeat = "Пароли не совпадают";
    else
      _errorMessagePasswordRepeat = null;
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

  String? _name = "";
  String? _lastName = "";
  img.Image? _imageAvatar = null;
  Uint8List _bytes = Uint8List(0);

  String? get getName => _name;
  String? get getLastName => _lastName;
  img.Image? get getImageAvatar => _imageAvatar;
  Uint8List get getBytes => _bytes;

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
  }

  Future<dynamic> sendDataReg() async {
    try {
      final response = await http.post(
          Uri.parse("http://${ipAddress.ipAddress}:8888/auth/register"),
          body: json.encode({'email': _email, 'password': _password}),
          headers: {'Content-Type': 'application/json'});
      if (response.body.contains("false")) {
        return "Пользователь с таким email существует";
      } else {
        return null;
      }
    } catch (e) {
      return "Произошла ошибка: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> sendDataLogin() async {
    try {
      final response = await http.post(
          Uri.parse("http://${ipAddress.ipAddress}:8888/auth/login"),
          body: json.encode({'email': _email, 'password': _password}),
          headers: {'Content-Type': 'application/json'});
      if (response.body.contains("true")) {
        return null;
      } else {
        return utf8.decode(response.bodyBytes);
      }
    } catch (e) {
      return "Произошла ошибка: $e";
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> sendDataAboutUser() async {
    try {
      // List<int> jpgBytes = img.encodeJpg(_imageAvatar);
      // Uint8List? imageBytes = Uint8List.fromList(jpgBytes);

      final response = await http.put(
          Uri.parse("http://${ipAddress.ipAddress}:8888/profile/save"),
          body: json.encode({
            'email': _email,
            "lastName": _lastName,
            'avatar': null,
            'name': _name
          }),
          headers: {'Content-Type': 'application/json'});
      if (response.body.contains("true")) {
        return null;
      } else {
        return utf8.decode(response.bodyBytes);
      }
    } catch (e) {
      return "Произошла ошибка: $e";
    }
  }

  // проблемы с фото и там где есть не null значение
  Future<void> getDataAboutUser() async {
    // final response = await http.post(
    //     Uri.parse("http://$_ipAddress:8888/profile/info"),
    //     body: json.encode({"email": _email}),
    //     headers: {'Content-Type': 'application/json'});
    // if (response.statusCode == 200) {
    //   try {
    //     final decodedJson = json.decode(response.body);
    //
    //     List<ProfileInfo> profiles = [];
    //     if (decodedJson is List) {
    //       for (final element in decodedJson) {
    //         if (element != null) {
    //           try {
    //             profiles.add(ProfileInfo.fromList(element));
    //           } catch (e) {
    //             Logger().d('Пропущен невалидный элемент: $e');
    //           }
    //         }
    //       }
    //     }
    //
    //     if (profiles.isNotEmpty) {
    //       final profile = profiles.first;
    //       if (profile.name != null) {
    //         _name = profile.name;
    //         _nameController.text = profile.name ?? '';
    //       }
    //       if (profile.lastName != null) {
    //         _lastName = profile.lastName;
    //         _lastNameController.text = profile.lastName ?? '';
    //
    //       }
    //
    //       if (profile.avatar != null && profile.avatar!.isNotEmpty) {
    //         _bytes = profile.avatar!;
    //       }
    //     }
    //   } catch (e) {
    //     Logger().d('Ошибка при декодировании JSON: $e');
    //   }
    // } else {
    //   throw Exception("Не удалось загрузить данные");
    // }
  }

  Future<void> deleteAccount() async{
     await http.delete(
        Uri.parse("http://${ipAddress.ipAddress}:8888/profile/delete"),
        body: json.encode({"email": _email}),
        headers: {'Content-Type': 'application/json'});
  }
}
