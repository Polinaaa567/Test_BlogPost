import 'dart:convert';
import 'dart:io';

import '../storage/storage.dart';

class CommentsRoutes {
  final IDatabase db;

  CommentsRoutes(this.db);

  Future<void> handleRequest(HttpRequest request) async {
    switch (request.uri.path) {
      case "/comments":
        await _commentsInfo(request);
        break;
      case "/comments/new":
        await _createNewComment(request);
        break;
    }
  }

  Future<void> _commentsInfo(HttpRequest request) async {
    try {
      if (request.method == "GET") {
        final queryParam = request.uri.queryParameters;
        final idPost = queryParam["idPost"];

        final commentsInPost =
            await db.execute('''Select c.text_comment, c.date_creator, 
            u.last_name, u.name, u.avatar 
            from comments c 
            join users u on c.id_user_comment = u.id_user 
            where c.id_post=@id_post''', params: {"id_post": idPost});

        final List<Map<String, dynamic>> formattedResults =
            commentsInPost.map((row) {
          return {
            'text_comment': row[0],
            'date_creator': (row[1] as DateTime).toIso8601String(),
            'last_name': row[2],
            'name': row[3],
            'avatar': row[4],
          };
        }).toList();

        final resultJSON = json.encode(formattedResults);

        request.response
          ..write(resultJSON)
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Method not allowed')
          ..close();
      }
    } catch (e) {
      request.response
        ..write('Ошибка при обработке запроса')
        ..close();
    }
  }

  Future<void> _createNewComment(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final idPost = jsonData['idPost'];
        final email = jsonData['email'];
        final textComment = jsonData['textComment'];
        DateTime dateEditing = DateTime.now();

        final userQuery = await db.execute('''Select u.id_user 
              from users u 
              where u.email=@email''', params: {"email": email});

        await db.execute('''insert into comments 
                (id_user_comment, id_post, text_comment, date_creator) 
                values (@id_user_comment, @id_post, @text_comment, @date_creator)''',
            params: {
              "id_user_comment": userQuery.first[0],
              "text_comment": textComment,
              "date_creator": dateEditing,
              "id_post": idPost
            });

        final commentsInPost =
            await db.execute('''Select c.text_comment, c.date_creator, 
            u.last_name, u.name, u.avatar 
            from comments c 
            join users u on c.id_user_comment = u.id_user 
            where c.id_post=@id_post''', params: {"id_post": idPost});

        final List<Map<String, dynamic>> formattedResults =
            commentsInPost.map((row) {
          return {
            'text_comment': row[0],
            'date_creator': (row[1] as DateTime).toIso8601String(),
            'last_name': row[2],
            'name': row[3],
            'avatar': row[4],
          };
        }).toList();

        final resultJSON = json.encode(formattedResults);

        request.response
          ..write(resultJSON)
          ..close();
      } else {
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Method not allowed')
          ..close();
      }
    } catch (e) {
      request.response
        ..write('Ошибка при обработке запроса + $e')
        ..close();
    }
  }
}
