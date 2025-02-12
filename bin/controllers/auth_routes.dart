import 'dart:io';
import 'dart:convert';

import '../storage/storage.dart';

class AuthRoutes {
  final IDatabase db;

  AuthRoutes(this.db);

  Future<void> handleRequest(HttpRequest request) async {
    switch (request.uri.path) {
      case "/auth/register":
        await _register(request);
        break;
      case "/auth/login":
        await _login(request);
        break;
    }
  }

  Future<void> _register(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];
        final password = jsonData['password'];

        final results = await db.execute('''Select id_user 
              from users 
              where email=@email''', params: {"email": email});

        if (results.isNotEmpty) {
          request.response
            ..write('Пользователь с таким email существует')
            ..close();
        } else {
          await db.execute('''INSERT INTO users 
                        (email, password) 
                        VALUES (@email, @password)''',
              params: {"email": email, "password": password});

          request.response
            ..write('true')
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
        ..write('Ошибка при обработке запроса _register: $e')
        ..close();
    }
  }

  Future<void> _login(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];
        final password = jsonData['password'];

        final result = await db.execute('''Select password 
                  from users 
                  where email=@email''', params: {"email": email});

        if (result.isEmpty) {
          request.response
            ..write('Пользователя с таким email не существует')
            ..close();
        } else {
          final row = result.first;
          if (row[0] == password) {
            request.response
              ..write('true')
              ..close();
          } else {
            request.response
              ..write('Неправильный пароль')
              ..close();
          }
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
