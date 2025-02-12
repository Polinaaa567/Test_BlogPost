import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'configure/config.dart';

void main() async {
  final conn = await Connection.open(
    Endpoint(
      host: LocalDataAboutDB.host,
      database: LocalDataAboutDB.database,
      port: LocalDataAboutDB.port,
      username: LocalDataAboutDB.username,
      password: LocalDataAboutDB.password,
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  try {
    print('Подключение к базе данных установлено');

    var server = await HttpServer.bind(InternetAddress.anyIPv6, 8888);
    print("Сервер запущен...");

    String query;
    Map<String, dynamic> parameters;

    server.listen((HttpRequest request) async {
      switch (request.uri.path) {
        //----------------------------------------------------------------
        case "/auth/register": //зарегистрироваться
          try {
            if (request.method == "POST") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];
              final password = jsonData['password'];

              final results = await conn.execute(
                  Sql.named('Select id_user from users where email=@email'),
                  parameters: {"email": email});

              if (results.isNotEmpty) {
                request.response
                  ..write('false')
                  ..close();
              } else {
                await conn.execute(
                    Sql.named(
                        'INSERT INTO users (email, password) VALUES (@email, @password)'),
                    parameters: {"email": email, "password": password});

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
              ..write('EROOR user при обработке запроса: $e')
              ..close();
          }

        //----------------------------------------------------------------
        case "/auth/login": //вход в систему
          try {
            if (request.method == "POST") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];
              final password = jsonData['password'];

              final result = await conn.execute(
                  Sql.named('Select password from users where email=@email'),
                  parameters: {"email": email});

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

        //----------------------------------------------------------------
        case "/profile/info": //отправить инфу о пользователе
          try {
            if (request.method == "POST") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];

              final result = await conn.execute(
                  Sql.named(
                      'Select u.last_name, u.name, u.avatar from users u where u.email=@email'),
                  parameters: {"email": email});

              final List<Map<String, dynamic>> formattedResults =
                  result.map((row) {
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

        //----------------------------------------------------------------
        case "/profile/save": //сохранить данные о пользователе
          try {
            if (request.method == "PUT") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];
              final name = jsonData['name'];
              final lastName = jsonData['lastName'];
              final avatar = jsonData['avatar'];
              try {
                await conn.execute(
                    Sql.named(
                        'update users set last_name=@last_name, name=@name, avatar=@avatar where email=@email'),
                    parameters: {
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

        //----------------------------------------------------------------
        case "/profile/delete": // удалить учётную запись
          try {
            if (request.method == "DELETE") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];
              try {
                await conn.execute(
                    Sql.named('delete from users where email=@email'),
                    parameters: {"email": email});

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

        //----------------------------------------------------------------
        case "/post/new/published": // опубликовать пост
          if (request.method == "POST") {
            try {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];
              final idPost = jsonData['idPost'];
              final headline = jsonData['headline'];
              final photoPost = jsonData['photoPost'];
              final textPost = jsonData['textPost'];

              final state = "published";
              DateTime datePublished = DateTime.now();

              final postExists = await conn.execute(
                  Sql.named(
                      'Select id_user_creator from posts where id_post=@id_post'),
                  parameters: {"id_post": idPost});

              final userQuery = await conn.execute(
                  Sql.named(
                      'Select u.id_user from users u where u.email=@email'),
                  parameters: {"email": email});

              final row = userQuery.first;

              if (postExists.isNotEmpty) {
                query =
                    'UPDATE posts SET headline=@headline, photo_post=@photo_post, text_post=@text_post, state=@state, date_published=@date_published WHERE id_post=@id_post returning id_post';
                parameters = {
                  "id_post": idPost,
                  "headline": headline,
                  "photo_post": photoPost,
                  "text_post": textPost,
                  "state": state,
                  "date_published": datePublished
                };
              } else {
                query =
                    'INSERT INTO posts (headline, photo_post, text_post, id_user_creator, state, date_published) VALUES (@headline, @photo_post, @text_post, @id_user_creator, @state, @date_published) returning id_post';
                parameters = {
                  "headline": headline,
                  "photo_post": photoPost,
                  "text_post": textPost,
                  "id_user_creator": row[0],
                  "state": state,
                  "date_published": datePublished
                };
              }

              final isQueryPost =
                  await conn.execute(Sql.named(query), parameters: parameters);
              if (isQueryPost.isNotEmpty) {
                await conn.execute(Sql.named(
                    "INSERT INTO post_likes (id_post, count_like) values (${isQueryPost.first[0]}, 0)"));
              }
              request.response
                ..write('true')
                ..close();
            } catch (e) {
              request.response
                ..write('Ошибка при обработке запроса: $e')
                ..close();
            }
          } else {
            request.response
              ..statusCode = HttpStatus.methodNotAllowed
              ..write('Method not allowed')
              ..close();
          }

        //----------------------------------------------------------------
        case "/post/find":
          try {
            if (request.method == "GET") {
              final queryParam = request.uri.queryParameters;
              final searchRequest = queryParam["searchRequest"];

              final searchResult = await conn.execute(
                  Sql.named(
                      "Select u.last_name, u.name, u.avatar, p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, pl.count_like from posts p left join users u On p.id_user_creator=u.id_user left join post_likes pl on pl.id_post=p.id_post where Lower(p.headline) like '%' || Lower(@searchRequest) || '%' and p.state like @state"),
                  parameters: {
                    "searchRequest": searchRequest,
                    "state": "published"
                  });

              final List<Map<String, dynamic>> formattedResults =
                  searchResult.map((row) {
                return {
                  'last_name': row[0],
                  'name': row[1],
                  'avatar': row[2],
                  'id_post': row[3],
                  'headline': row[4],
                  'photo_post': row[5],
                  'text_post': row[6],
                  'date_published': (row[7] as DateTime).toIso8601String(),
                  'count_like': row[8],
                };
              }).toList();
              // final Map<String, dynamic> data = {'data': formattedResults};

              final String resultJSON = jsonEncode(formattedResults);

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
              ..write('Ошибка при обработке запроса: $e')
              ..close();
          }

        //----------------------------------------------------------------
        case "/post/new/draft": //сохранить черновик
          try {
            if (request.method == "POST") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];
              final idPost = jsonData['idPost'];
              final headline = jsonData['headline'];
              final photoPost = jsonData['photoPost'];
              final textPost = jsonData['textPost'];
              final state = "draft";
              DateTime dateEditing = DateTime.now();

              final postExists = await conn.execute(
                  Sql.named('Select * from posts where id_post=@id_post'),
                  parameters: {"id_post": idPost});

              final userQuery = await conn.execute(
                  Sql.named(
                      'Select u.id_user from users u where u.email=@email'),
                  parameters: {"email": email});

              final row = userQuery.first;

              if (postExists.isNotEmpty) {
                query =
                    'UPDATE posts SET headline=@headline, photo_post=@photo_post, text_post=@text_post, state=@state, date_published=@date_published WHERE id_post=@id_post';
                parameters = {
                  "id_post": idPost,
                  "headline": headline,
                  "photo_post": photoPost,
                  "text_post": textPost,
                  "state": state,
                  "date_published": dateEditing
                };
              } else {
                query =
                    'INSERT INTO posts (headline, photo_post, text_post, id_user_creator, state, date_published) VALUES (@headline, @photo_post, @text_post, @id_user_creator, @state, @date_published)';
                parameters = {
                  "headline": headline,
                  "photo_post": photoPost,
                  "text_post": textPost,
                  "id_user_creator": row[0],
                  "state": state,
                  "date_published": dateEditing
                };
              }

              await conn.execute(Sql.named(query), parameters: parameters);
              request.response
                ..write('true')
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

        //----------------------------------------------------------------
        case "/post/delete": // удалить черновик
          try {
            if (request.method == "DELETE") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];
              final idPost = jsonData['idPost'];

              final userQuery = await conn.execute(
                  Sql.named(
                      'Select u.id_user from users u where u.email=@email'),
                  parameters: {"email": email});

              await conn.execute(Sql.named(
                  'delete from posts where id_user_creator=${userQuery.first[0]} and id_post=$idPost'));

              request.response
                ..write('true')
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

        //----------------------------------------------------------------
        case "/posts": //получить все посты, сортированные по дате.
          try {
            if (request.method == "GET") {
              final postsQuery = await conn.execute(
                  Sql.named('''Select u.last_name, u.name, u.avatar, 
                      p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                      pl.count_like,
                      (SELECT COUNT(*) FROM comments c WHERE c.id_post = p.id_post) as count_comments
                      from posts p 
                      left join users u On p.id_user_creator=u.id_user 
                      left join post_likes pl on pl.id_post=p.id_post 
                      where p.state=@state 
                      order by date_published desc'''),
                  parameters: {"state": 'published'});

              final List<Map<String, dynamic>> formattedResults =
                  postsQuery.map((row) {
                return {
                  'last_name': row[0],
                  'name': row[1],
                  'avatar': row[2],
                  'id_post': row[3],
                  'headline': row[4],
                  'photo_post': row[5],
                  'text_post': row[6],
                  'date_published': (row[7] as DateTime).toIso8601String(),
                  'count_like': row[8],
                  'count_comments': row[9]
                };
              }).toList();

              final resultJSON = jsonEncode(formattedResults);

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
              ..write('Ошибка при обработке запроса: $e')
              ..close();
          }

        //----------------------------------------------------------------
        case "/posts/user": //получить все посты пользователя. КОЛ-ВО КОММЕНТАРИЕВ!!!!!!
          try {
            if (request.method == "POST") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final email = jsonData['email'];

              final userQuery = await conn.execute(
                  Sql.named('Select u.id_user from users u where email=@email'),
                  parameters: {"email": email});

              final postsQuery = await conn
                  .execute(Sql.named(''' Select u.last_name, u.name, u.avatar, 
                  p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                  pl.count_like,
                  (SELECT COUNT(*) FROM comments c WHERE c.id_post = p.id_post) as count_comments,
                  p.state
                  from posts p 
                  left join users u On p.id_user_creator=u.id_user 
                  left join post_likes pl on pl.id_post=p.id_post 
                  where p.id_user_creator=@id_user_creator
                '''), parameters: {"id_user_creator": userQuery.first[0]});

              final List<Map<String, dynamic>> formattedResults =
                  postsQuery.map((row) {
                return {
                  'last_name': row[0],
                  'name': row[1],
                  'avatar': row[2],
                  'id_post': row[3],
                  'headline': row[4],
                  'photo_post': row[5],
                  'text_post': row[6],
                  'date_published': (row[7] as DateTime).toIso8601String(),
                  'count_like': row[8],
                  'count_comments': row[9],
                  'state': row[10],
                };
              }).toList();

              final resultJSON = jsonEncode(formattedResults);

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
              ..write('Ошибка при обработке запроса: $e')
              ..close();
          }

        //----------------------------------------------------------------
        case "/post/info": //получить подробную инфу о посте. КОЛ-ВО КОММЕНТАРИЕВ!!!!!!
          try {
            if (request.method == "POST") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final idPost = jsonData['idPost'];

              final postsQuery = await conn.execute(
                  Sql.named('''Select u.last_name, u.name, u.avatar, 
                  p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                  pl.count_like, 
                  (SELECT COUNT(*) FROM comments c WHERE c.id_post = @id_post) as count_comments
                  from posts p 
                  left join users u On p.id_user_creator=u.id_user 
                  left join post_likes pl on pl.id_post=p.id_post 
                  where p.id_post=@id_post'''),
                  parameters: {"id_post": idPost});

              final List<Map<String, dynamic>> formattedResults =
                  postsQuery.map((row) {
                return {
                  'last_name': row[0],
                  'name': row[1],
                  'avatar': row[2],
                  'id_post': row[3],
                  'headline': row[4],
                  'photo_post': row[5],
                  'text_post': row[6],
                  'date_published': (row[7] as DateTime).toIso8601String(),
                  'count_like': row[8],
                  'count_comments': row[9]
                };
              }).toList();

              final resultJSON = jsonEncode(formattedResults);

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

        //----------------------------------------------------------------
        case "/post/liked": //поставить лайк
          try {
            if (request.method == "PUT") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final idPost = jsonData['idPost'];
              final state = jsonData['state'];
              print("$idPost + $state");
              final infoCountLikes = await conn.execute(
                  Sql.named(
                      'select pl.count_like from post_likes pl where pl.id_post=@id_post'),
                  parameters: {"id_post": idPost});
              int countLike = int.parse(infoCountLikes.first[0].toString());
              print(countLike);

              int countLikeLocal = countLike;
              print(countLikeLocal);

              if (state.toString() == "true") {
                countLikeLocal = countLikeLocal + 1;
                print("true + $countLikeLocal");

                await conn.execute(
                    Sql.named(
                        'update post_likes set count_like=@count_like where id_post=@id_post'),
                    parameters: {
                      "count_like": (countLikeLocal),
                      "id_post": idPost
                    });

                
                print("await work + $countLikeLocal");
              } else {
                if (countLike > 0) {
                  countLikeLocal = countLikeLocal - 1;
                  await conn.execute(
                      Sql.named(
                          'update post_likes set count_like=@count_like where id_post=@id_post'),
                      parameters: {
                        "count_like": (countLikeLocal),
                        "id_post": idPost
                      });
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
              ..write('Ошибка при обработке запроса')
              ..close();
          }

        // ----------------------------------------------------------------
        case "/comments/new": //оставить новый комментарий
          try {
            if (request.method == "POST") {
              final body = await utf8.decodeStream(request);
              final jsonData = jsonDecode(body);

              final idPost = jsonData['idPost'];
              final email = jsonData['email'];
              final textComment = jsonData['textComment'];
              DateTime dateEditing = DateTime.now();

              final userQuery = await conn.execute(
                  Sql.named(
                      'Select u.id_user from users u where u.email=@email'),
                  parameters: {"email": email});

              await conn.execute(
                  Sql.named(
                      "insert into comments (id_user_comment, id_post, text_comment, date_creator) values (@id_user_comment, @id_post, @text_comment, @date_creator)"),
                  parameters: {
                    "id_user_comment": userQuery.first[0],
                    "text_comment": textComment,
                    "date_creator": dateEditing,
                    "id_post": idPost
                  });
              request.response
                ..write("true")
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

        // ----------------------------------------------------------------
        case "/comments": //получить все комментарии
          try {
            if (request.method == "GET") {
              final queryParam = request.uri.queryParameters;
              final idPost = queryParam["idPost"];

              final commentsInPost = await conn.execute(Sql.named(
                  "Select c.text_comment, c.date_creator, u.last_name, u.name, u.avatar from comments c join users u on c.id_user_comment = u.id_user where c.id_post=$idPost"));

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

              final resultJSON = jsonEncode(formattedResults);

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

        default:
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not found')
            ..close();
          break;
      }
    });
  } catch (e) {
    print('Ошибка подключения к базе данных: $e');
  }
}
