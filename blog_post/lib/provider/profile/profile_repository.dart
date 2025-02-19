import 'dart:convert';
import 'dart:typed_data';

import 'package:blog_post/entities/profile.dart';
import 'package:http/http.dart' as http;
import 'package:blog_post/configs/config.dart';

class FactoryProfileRepository {
  static IProfileRepository createProfileRepository() {
    return ProfileRepository();
  }
}

abstract class IProfileRepository {
  Future<dynamic> sendDataReg(String email, String password);
  Future<dynamic> sendDataLogin(String email, String password);
  Future<dynamic> sendDataAboutUser(
      String email, String? lastName, Uint8List bytes, String? name);
  Future<List<IProfile>?> fetchDataAboutUser(String email);
  Future<void> deleteAccount(String email);
}

class ProfileRepository implements IProfileRepository {
  @override
  Future sendDataReg(String email, String password) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/auth/register"),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'});
    if (!response.body.contains("true")) {
      return utf8.decode(response.bodyBytes);
    } else {
      return null;
    }
  }

  @override
  Future sendDataLogin(String email, String password) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/auth/login"),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'});
    if (response.body.contains("true")) {
      return null;
    } else {
      return utf8.decode(response.bodyBytes);
    }
  }

  @override
  Future sendDataAboutUser(
      String email, String? lastName, Uint8List bytes, String? name) async {
    final response =
        await http.put(Uri.parse("http://${MyIP.ipAddress}:8888/profile/save"),
            body: json.encode({
              'email': email,
              "lastName": lastName,
              'avatar': bytes.isNotEmpty ? bytes : null,
              'name': name
            }),
            headers: {'Content-Type': 'application/json'});
    if (response.body.contains("true")) {
      return null;
    } else {
      return utf8.decode(response.bodyBytes);
    }
  }

  @override
  Future<List<IProfile>?> fetchDataAboutUser(String email) async {
    final response = await http.post(
        Uri.parse("http://${MyIP.ipAddress}:8888/profile"),
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((elem) => IProfile.fromList(elem)).toList();
    } else {
      return null;
    }
  }

  @override
  Future<void> deleteAccount(String email) async{
    await http.delete(Uri.parse("http://${MyIP.ipAddress}:8888/profile/delete"),
        body: json.encode({"email": email}),
        headers: {'Content-Type': 'application/json'});
  }
}
