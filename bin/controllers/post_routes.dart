import 'dart:io';
import 'dart:convert';

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
      case "/post/delete":
        await _deletePost(request);
        break;
      case "/post":
        await _getAllPosts(request);
        break;
      case "/post/user":
        await _getUserPosts(request);
        break;
      case "/post/info":
        await _getInfoPost(request);
        break;
      case "/post/like":
        await _likePost(request);
        break;
      case "/post/find":
        await _getFoundPosts(request);
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
        dynamic isQueryPost;
        if (postExists.isNotEmpty) {
          isQueryPost = await db.execute('''UPDATE posts 
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
          isQueryPost = await db.execute('''INSERT INTO posts 
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

        if (isQueryPost.isNotEmpty) {
          await db.execute('''INSERT INTO post_likes 
          (id_post, count_like) 
          values (@id_post, 0)''', params: {"id_post": isQueryPost.first[0]});
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

  Future<void> _deletePost(HttpRequest request) async {
    try {
      if (request.method == "DELETE") {
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
      if (request.method == "GET") {
        final postsQuery = await db.execute(
            '''Select u.last_name, u.name, u.avatar, 
                      p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                      pl.count_like,
                      (select count(*) from comments c where c.id_post = p.id_post) as count_comments
                      from posts p 
                      left join users u On p.id_user_creator=u.id_user 
                      left join post_likes pl on pl.id_post=p.id_post 
                      where p.state=@state 
                      order by date_published desc''',
            params: {"state": 'published'});

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

        final postsQuery =
            await db.execute(''' Select u.last_name, u.name, u.avatar, 
                  p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                  pl.count_like,
                  (SELECT COUNT(*) FROM comments c WHERE c.id_post = p.id_post) as count_comments,
                  p.state
                  from posts p 
                  left join users u On p.id_user_creator=u.id_user 
                  left join post_likes pl on pl.id_post=p.id_post 
                  where p.id_user_creator=@id_user_creator
                ''', params: {"id_user_creator": userQuery.first[0]});

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
  }

  Future<void> _getInfoPost(HttpRequest request) async {
    try {
      if (request.method == "POST") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final idPost = jsonData['idPost'];

        final postsQuery =
            await db.execute('''Select u.last_name, u.name, u.avatar, 
                  p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                  pl.count_like, 
                  (SELECT COUNT(*) FROM comments c WHERE c.id_post = @id_post) as count_comments
                  from posts p 
                  left join users u On p.id_user_creator=u.id_user 
                  left join post_likes pl on pl.id_post=p.id_post 
                  where p.id_post=@id_post''', params: {"id_post": idPost});

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
  }

  Future<void> _likePost(HttpRequest request) async {
    try {
      if (request.method == "PUT") {
        final body = await utf8.decodeStream(request);
        final jsonData = jsonDecode(body);

        final idPost = jsonData['idPost'];
        final state = jsonData['state'];
        print("$idPost + $state");
        final infoCountLikes = await db.execute('''select pl.count_like 
                      from post_likes pl 
                      where pl.id_post=@id_post''',
            params: {"id_post": idPost});
        int countLike = int.parse(infoCountLikes.first[0].toString());
        print(countLike);

        int countLikeLocal = countLike;
        print(countLikeLocal);

        if (state.toString() == "true") {
          countLikeLocal = countLikeLocal + 1;
          print("true + $countLikeLocal");

          await db.execute('''update post_likes 
                        set count_like=@count_like 
                        where id_post=@id_post''',
              params: {"count_like": (countLikeLocal), "id_post": idPost});

          print("await work + $countLikeLocal");
        } else {
          if (countLike > 0) {
            countLikeLocal = countLikeLocal - 1;
            await db.execute('''update post_likes 
                          set count_like=@count_like 
                          where id_post=@id_post''',
                params: {"count_like": (countLikeLocal), "id_post": idPost});
          }
        }
        final postsQuery = await db.execute('''
                     select pl.count_like
                      from  post_likes pl  
                      where pl.id_post=@id_post 
            ''', params: {"id_post": idPost});

        final List<Map<String, dynamic>> formattedResults =
            postsQuery.map((row) {
          return {'count_like': row[0]};
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
      if (request.method == "GET") {
        final queryParam = request.uri.queryParameters;
        final searchRequest = queryParam["searchRequest"];

        final searchResult = await db.execute(
            '''Select u.last_name, u.name, u.avatar, 
                      p.id_post, p.headline, p.photo_post, p.text_post, p.date_published, 
                      pl.count_like 
                      (select count(*) from comments c where c.id_post = p.id_post) as count_comments
                      from posts p 
                      left join users u On p.id_user_creator=u.id_user left 
                      join post_likes pl on pl.id_post=p.id_post 
                      where Lower(p.headline) like '%' || Lower(@searchRequest) || '%' 
                            and p.state like @state''',
            params: {"searchRequest": searchRequest, "state": "published"});

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
            'count_comments': row[9],
          };
        }).toList();

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
  }
}
