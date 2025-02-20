<h1 align="center">Тестовое задание "мобильное приложение BlogPost"</h1>
<h2 align="center">Описание</h2>
Данное приложение представляет из себя ленту постов как от автора, так и от других пользователей. Пользователь сможет читать, оценивать и комментировать посты, а также создавать свои, сохранять их в черновиках или публиковать для общего доступа, но для этого ему необходимо заполнить данные о себе.

<h2 align="center">Технологии и инструменты разработки</h2>

- Dart
- PostgreSQL
- Flutter (С использованием ChangeNotifier)

<h2 align="center">Зависимости</h2>
<h3 align="center">Клиент</h3>
Для работы приложения необходимо в pubspec.yaml добавить: provider, email_validator, image_picker, image, http, intl, local_auth, pin_code_fields, shared_preferences и запустить команду в консоли 'pub get'

<h3 align="center">Сервер</h3>
Для работы приложения необходимо в pubspec.yaml добавить: postgres, http, intl и запустить команду в консоли 'pub get'

<h2 align="center">Как запустить</h2>
Чтобы запустить проект необходимо в бд иметь 4 таблицы для users, posts, comments, post_like. Для их создания есть скрипт в ветке localserver в ./scripts/create_db.sql (написан для роли postgres). Запустить можно из самой папки в cmd  psql -U postgres -f create_db.sql. Также нужно создать файл в ./lib/configure/config.data и дополнить его конфигурационной информацией о бд (host, database = blogpost, port, username, password) и запустить код из ./bin/dartserver.dart. Сервер запустится на порту 8888. 

В ветке master не хватает файлов, configs/config.dart из-за этого приложение не запускается. В нём необходимо прописать: class MyIP {static const String ipAddress = "your_ip_address где запустили сервер";}. После уже можно запускать проект, главное чтобы сервер и клиент были подключены к одной локальной сети.

<h2 align="center">Основные возможности</h2>

- Авторизация / регистрация через email
- Вход без регистрации 
- Установка и повторный вход через Пин-код или использовать биометрию (отпечаток пальца)
- Просматривать свои посты как опубликованные так и черновики, если авторизован
- Просматривать все посты всех пользователей, которые опубликованы
- Добавить новый пост (черновик или опубликовать)
- Редактировать черновик
- Удалить черновик
- Выбрать фото для поста и профиля из галереи
- Изменить и сохранить профиль
- Настроить уведомления о новых постах, о комментариях и о лайках
- Удалить аккаунт
- Оставлять комментарий

Вход в систему:
![image](https://github.com/user-attachments/assets/3c3e22de-255a-44f0-935b-0a8fd4736046)

Добавление нового поста:
![image](https://github.com/user-attachments/assets/96e155f6-175d-413c-b0b0-cead4e69f07f)

Просмотр ленты постов:
![image](https://github.com/user-attachments/assets/d90f394b-acc2-4857-8dbb-148befe77c34)

