import 'dart:io';

import 'storage/storage.dart';
import 'controllers/auth_routes.dart';
import 'controllers/comments_routes.dart';
import 'controllers/post_routes.dart';
import 'controllers/profile_routes.dart';

void main() async {
  final db = FactoryDatabase.createDatatabase();
  await db.connect();

  try {
    print('Подключение к базе данных установлено');

    var server = await HttpServer.bind(InternetAddress.anyIPv6, 8888);
    print("Сервер запущен...");

    final authRoutes = AuthRoutes(db);
    final commentsRoutes = CommentsRoutes(db);
    final postRoute = PostsRoutes(db);
    final profileRoute = ProfileRoutes(db);

    server.listen((HttpRequest request) async {
      if (request.uri.path.startsWith("/auth")) {
        await authRoutes.handleRequest(request);
      } else if (request.uri.path.startsWith("/comments")) {
        await commentsRoutes.handleRequest(request);
      } else if (request.uri.path.startsWith("/post")) {
        await postRoute.handleRequest(request);
      } else if (request.uri.path.startsWith("/profile")) {
        await profileRoute.handleRequest(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not found')
          ..close();
      }
    });
  } catch (e) {
    print('Ошибка подключения к базе данных: $e');
  }
}
