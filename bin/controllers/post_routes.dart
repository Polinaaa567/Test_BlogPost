import 'dart:io';
import 'dart:convert';

import 'package:intl/intl.dart';

import '../storage/storage.dart';

class PostsRoutes {
  final IDatabase db;

  PostsRoutes(this.db);

  Future<void> handleRequest(HttpRequest request) async {
    switch (request.uri.path) {
      case "/post/new/published":
        await _publishPost(request);
        break;
      case "/post/new/draft":
        await _saveDraft(request);
        break;
      case "/post": // +
        await _getAllPosts(request);
        break;
      case "/post/user": // +
        await _getUserPosts(request);
        break;
      case "/post/info": // +
        await _getInfoPost(request);
        break;
      case "/post/like": // +
        await _likePost(request);
        break;
      case "/post/find": // +
        await _getFoundPosts(request);
        break;
      case "/post/count/like":
        await _getCountLikes(request);
        break;
      case "/post/count/posts":
        await _getCountNewPost(request);
        break;
    }
  }

  Future<void> _publishPost(HttpRequest request) async {
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

        final postExists = await db.execute('''Select id_user_creator 
                      from posts 
                      where id_post=@id_post''', params: {"id_post": idPost});

        final userQuery = await db.execute('''Select u.id_user 
                  from users u 
                  where u.email=@email''', params: {"email": email});

        final row = userQuery.first;

        if (postExists.isNotEmpty) {
          await db.execute('''UPDATE posts 
              SET headline=@headline, photo_post=@photo_post, 
              text_post=@text_post, state=@state, 
              date_published=@date_published 
              WHERE id_post=@id_post 
              returning id_post''', params: {
            "id_post": idPost,
            "headline": headline,
            "photo_post": photoPost,
            "text_post": textPost,
            "state": state,
            "date_published": datePublished
          });
        } else {
          await db.execute('''INSERT INTO posts 
              (headline, photo_post, text_post, id_user_creator, state, date_published) 
              VALUES (@headline, @photo_post, @text_post, @id_user_creator, @state, @date_published) 
              returning id_post''', params: {
            "headline": headline,
            "photo_post": photoPost,
            "text_post": textPost,
            "id_user_creator": row[0],
            "state": state,
            "date_published": datePublished
          });
        }

        request.response.close();
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
  }

  Future<void> _saveDraft(HttpRequest request) async {
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

        final postExists = await db.execute('''Select * 
                from posts 
                where id_post=@id_post''', params: {"id_post": idPost});

        final userQuery = await db.execute('''Select u.id_user 
                      from users u 
                      where u.email=@email''', params: {"email": email});

        final row = userQuery.first;

        if (postExists.isNotEmpty) {
          await db.execute('''UPDATE posts 
                    SET headline=@headline, photo_post=@photo_post, text_post=@text_post, 
                        state=@state, date_published=@date_published 
                    WHERE id_post=@id_post''', params: {
            "id_post": idPost,
            "headline": headline,
            "photo_post": photoPost,
            "text_post": textPost,
            "state": state,
            "date_published": dateEditing
          });
        } else {
          await db.execute('''INSERT INTO posts
                    (headline, photo_post, text_post, id_user_creator, state, date_published) 
                    VALUES (@headline, @photo_post, @text_post, @id_user_creator, 
                            @state, @date_published)''', params: {
            "headline": headline,
            "photo_post": photoPost,
            "text_post": textPost,
            "id_user_creator": row[0],
            "state": state,
            "date_published": dateEditing
          });
        }

        request.response.close();
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

  Future<void> _getAllPosts(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];
        Object? idUser;

        if (email != null) {
          final userQuery = await db.execute('''
            SELECT id_user FROM users WHERE email=@email''',
              params: {"email": email});
          idUser = userQuery.first[0];
        }

        final params = {"state": 'published'};
        if (idUser != null) {
          params["id_user"] = "$idUser";
        }

        final postsQuery = await db.execute('''
        SELECT u.last_name, u.name, u.avatar, 
        p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
        (SELECT COUNT(*) FROM post_likes pl WHERE pl.id_post = p.id_post) AS count_like,
        (SELECT COUNT(*) FROM comments c WHERE c.id_post = p.id_post) AS count_comments
        ${idUser != null ? ', (SELECT COUNT(*) FROM post_likes pl WHERE pl.id_user = @id_user AND pl.id_post=p.id_post) AS state_like' : ''}
        FROM posts p 
        LEFT JOIN users u ON p.id_user_creator=u.id_user 
        WHERE p.state=@state 
        ORDER BY date_published DESC''', params: params);

        final formattedResults = postsQuery.map((row) {
          final map = {
            'last_name': row[0],
            'name': row[1],
            'avatar': row[2],
            'id_post': row[3],
            'headline': row[4],
            'photo_post': row[5],
            'text_post': row[6],
            'date_published':
                DateFormat("dd-MM-yyyy").format(row[7] as DateTime),
            'count_like': row[8],
            'count_comments': row[9],
          };
          if (idUser != null) {
            map['state_like'] = row[10];
          }
          return map;
        }).toList();

        final resultJSON = jsonEncode(formattedResults);
        request.response
          ..write(resultJSON)
          ..close();
      }  else if (request.method == "DELETE") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];
        final idPost = jsonData['idPost'];

        final userQuery = await db.execute('''Select u.id_user 
                      from users u 
                      where u.email=@email''', params: {"email": email});

        await db.execute('''delete from posts 
                  where id_user_creator=@id_user_creator and id_post=@id_post''',
            params: {"id_user_creator": userQuery.first[0], "id_post": idPost});

        request.response
          ..write('true')
          ..close();
      }else {
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

  Future<void> _getUserPosts(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final email = jsonData['email'];

        final userQuery = await db.execute('''Select u.id_user 
                  from users u 
                  where email=@email''', params: {"email": email});

        final postsQuery = await db
            .execute(''' Select u.last_name, u.name, u.avatar, 
                  p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                  (SELECT COUNT(*) FROM post_likes pl WHERE pl.id_post = p.id_post) as count_like,
                  (SELECT COUNT(*) FROM comments c WHERE c.id_post = p.id_post) as count_comments,
                  (select count(*) from post_likes pl where pl.id_user = @id_user and pl.id_post=p.id_post) as state_like,
                  p.state
                  from posts p 
                  left join users u On p.id_user_creator=u.id_user 
                  where p.id_user_creator=@id_user_creator
                  order by date_published desc
                ''', params: {
          "id_user_creator": userQuery.first[0],
          "id_user": userQuery.first[0]
        });

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
            'date_published':
                DateFormat("dd-MM-yyyy").format(row[7] as DateTime),
            'count_like': row[8],
            'count_comments': row[9],
            'state_like': row[10],
            'state': row[11],
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
  }

  Future<void> _getInfoPost(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);
        final email = jsonData["email"];
        final idPost = jsonData['idPost'];

        Object? idUser;

        if (email != null) {
          final userQuery = await db.execute('''
            SELECT id_user FROM users WHERE email=@email''',
              params: {"email": email});
          idUser = userQuery.first[0];
        }

        final params = {"id_post": idPost};
        if (idUser != null) {
          params["id_user"] = "$idUser";
        }

        final postsQuery =
            await db.execute('''Select u.last_name, u.name, u.avatar, 
                  p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                  (select count(*) from post_likes pl where pl.id_post = @id_post) as count_like, 
                  (SELECT COUNT(*) FROM comments c WHERE c.id_post = @id_post) as count_comments
                  ${idUser != null ? ', (SELECT COUNT(*) FROM post_likes pl WHERE pl.id_user = @id_user AND pl.id_post=p.id_post) AS state_like' : ''}
                  from posts p 
                  left join users u On p.id_user_creator=u.id_user 
                  where p.id_post=@id_post''', params: params);

        final formattedResults = postsQuery.map((row) {
          final map = {
            'last_name': row[0],
            'name': row[1],
            'avatar': row[2],
            'id_post': row[3],
            'headline': row[4],
            'photo_post': row[5],
            'text_post': row[6],
            'date_published':
                DateFormat("dd-MM-yyyy").format(row[7] as DateTime),
            'count_like': row[8],
            'count_comments': row[9],
          };
          if (idUser != null) {
            map['state_like'] = row[10];
          }
          return map;
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
  }

  Future<void> _likePost(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final idPost = jsonData['idPost'];
        final email = jsonData['email'];
        final state = jsonData['state'];

        print("$idPost + $state");

        final userQuery = await db.execute('''Select u.id_user 
                  from users u 
                  where email=@email''', params: {"email": email});

        if (state.toString() == "true") {
          await db.execute('''
                          insert into post_likes (id_user, id_post) values (
                          @id_user, @id_post)''',
              params: {"id_user": userQuery.first[0], "id_post": idPost});
        } else {
          await db.execute('''delete from post_likes 
                          where id_post=@id_post And id_user=@id_user''',
              params: {"id_user": userQuery.first[0], "id_post": idPost});
        }
        final postsQuery = await db.execute('''
                     SELECT COUNT(*) AS count_like,
                     SUM(CASE WHEN pl.id_user = @id_user THEN 1 ELSE 0 END) AS state_like
                     FROM post_likes pl 
                     WHERE pl.id_post = @id_post;
            ''', params: {"id_post": idPost, "id_user": userQuery.first[0]});

        final List<Map<String, dynamic>> formattedResults =
            postsQuery.map((row) {
          return {'count_like': row[0], 'state_like': row[1]};
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
  }

  Future<void> _getFoundPosts(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final tabPost = jsonData["tabPost"];
        final email = jsonData["email"];
        final searchRequest = jsonData["searchRequest"];

        print("$tabPost, $email, $searchRequest");

        Object? idUser;

        if (email != null) {
          final userQuery = await db.execute('''
            SELECT id_user FROM users WHERE email=@email''',
              params: {"email": email});
          idUser = userQuery.first[0];
        }
        final params = {"state": 'published', "searchRequest": searchRequest};
        if (idUser != null) {
          params["id_user"] = "$idUser";
        }

        if (tabPost.toString().contains("All")) {
          final searchResult =
              await db.execute('''Select u.last_name, u.name, u.avatar, 
                          p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                          (Select COUNT(*) FROM post_likes c WHERE c.id_post = p.id_post) as count_like,
                          (select count(*) from comments c where c.id_post = p.id_post) as count_comments
                          ${idUser != null ? ', (SELECT COUNT(*) FROM post_likes pl WHERE pl.id_user = @id_user AND pl.id_post=p.id_post) AS state_like' : ''}
                          from posts p 
                          left join users u On p.id_user_creator=u.id_user 
                          where Lower(p.headline) like '%' || Lower(@searchRequest) || '%' 
                                and p.state like @state
                          order by date_published desc''', params: params);

          final formattedResults = searchResult.map((row) {
            final map = {
              'last_name': row[0],
              'name': row[1],
              'avatar': row[2],
              'id_post': row[3],
              'headline': row[4],
              'photo_post': row[5],
              'text_post': row[6],
              'date_published':
                  DateFormat("dd-MM-yyyy").format(row[7] as DateTime),
              'count_like': row[8],
              'count_comments': row[9],
            };
            if (idUser != null) {
              map['state_like'] = row[10];
            }
            return map;
          }).toList();
          final String resultJSON = jsonEncode(formattedResults);

          request.response
            ..write(resultJSON)
            ..close();
        } else {
          final searchResult =
              await db.execute(''' Select u.last_name, u.name, u.avatar, 
                  p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                  (SELECT COUNT(*) FROM post_likes pl WHERE pl.id_post = p.id_post) as count_like,
                  (SELECT COUNT(*) FROM comments c WHERE c.id_post = p.id_post) as count_comments,
                  (select count(*) from post_likes pl where pl.id_user = @id_user and pl.id_post=p.id_post) as state_like,
                  p.state
                  from posts p 
                  left join users u On p.id_user_creator=u.id_user 
                  where Lower(p.headline) like '%' || Lower(@searchRequest) || '%' 
                        and p.id_user_creator=@id_user_creator
                  order by date_published desc''', params: {
            "id_user": idUser,
            "searchRequest": searchRequest,
            "id_user_creator": idUser,
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
              'date_published':
                  DateFormat("dd-MM-yyyy").format(row[7] as DateTime),
              'count_like': row[8],
              'count_comments': row[9],
              'state_like': row[10],
              'state': row[11]
            };
          }).toList();

          final String resultJSON = jsonEncode(formattedResults);

          request.response
            ..write(resultJSON)
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

  Future<void> _getCountLikes(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);
        final email = jsonData["email"];

        Object? idUser;

        if (email != null) {
          final userQuery = await db.execute('''
            SELECT id_user FROM users WHERE email=@email''',
              params: {"email": email});
          idUser = userQuery.first[0];
        }

        final postsQuery = await db.execute('''
          select count(*) as count_like
          from post_likes pl 
          left join posts p on pl.id_post = p.id_post
          left join users u on p.id_user_creator = u.id_user
          where u.id_user = @id_user
        ''', params: {"id_user": idUser});

        final formattedResults = postsQuery.map((row) {
          final map = {
            'count_like': row[0],
          };
          return map;
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
  }

  Future<void> _getCountNewPost(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);
        final email = jsonData["email"];

        Object? idUser;

        if (email != null) {
          final userQuery = await db.execute('''
            SELECT id_user FROM users WHERE email=@email''',
              params: {"email": email});
          idUser = userQuery.first[0];
        }

        final postsQuery = await db.execute('''
          select count(*) as count_posts
          from posts p 
          left join users u on p.id_user_creator = u.id_user
          where u.id_user != @id_user
          and p.state = @state
        ''', params: {"id_user": idUser, "state": "published"});

        final formattedResults = postsQuery.map((row) {
          final map = {
            'count_posts': row[0],
          };
          return map;
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
  }
}
