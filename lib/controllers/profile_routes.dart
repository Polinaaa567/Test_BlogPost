import 'dart:io';
import 'dart:convert';

import 'package:dartserver/storage/storage.dart';

class ProfileRoutes {
  final IDatabase db;

  ProfileRoutes(this.db);

  Future<void> handleRequest(HttpRequest request) async {
    switch (request.uri.path) {
      case "/profile": // +
        await _infoAboutUser(request);
        break;
      case "/profile/save": // +
        await _saveDataAboutUser(request);
        break;
      case "/profile/delete": // +
        await _deleteUser(request);
        break;
    }
  }

  Future<void> _infoAboutUser(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];

        final result = await db.execute('''Select u.last_name, u.name, u.avatar
                       from users u 
                       where u.email=@email''', params: {"email": email});

        final List<Map<String, dynamic>> formattedResults = result.map((row) {
          return {
            "last_name": row[0],
            "name": row[1],
            "avatar": row[2],
          };
        }).toList();

        final jsonResponse = jsonEncode(formattedResults);
        request.response
          ..write(jsonResponse)
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Method not allowed')
          ..close();
      }
    } catch (e) {
      request.response
        ..write('Ошибка при обработке запроса: $e')
        ..close();
    }
  }

  Future<void> _saveDataAboutUser(HttpRequest request) async {
    try {
      if (request.method == "PUT") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];
        final name = jsonData['name'];
        final lastName = jsonData['lastName'];
        final avatar = jsonData['avatar'];
        try {
          await db.execute('''update users 
              set last_name=@last_name, name=@name, avatar=@avatar 
              where email=@email''', params: {
            "last_name": lastName,
            "name": name,
            "avatar": avatar,
            "email": email
          });
          request.response
            ..write('true')
            ..close();
        } catch (e) {
          request.response
            ..write('Ошибка при обновлении данных')
            ..close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Method not allowed')
          ..close();
      }
    } catch (e) {
      request.response
        ..write('Ошибка при обработке запроса: $e')
        ..close();
    }
  }

  Future<void> _deleteUser(HttpRequest request) async {
    try {
      if (request.method == "DELETE") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];
        try {
          await db.execute('delete from users where email=@email',
              params: {"email": email});

          request.response
            ..write('true')
            ..close();
        } catch (e) {
          request.response
            ..write('false $e')
            ..close();
        }
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Method not allowed')
          ..close();
      }
    } catch (e) {
      request.response
        ..write('Ошибка при обработке запроса: $e')
        ..close();
    }
  }
}
