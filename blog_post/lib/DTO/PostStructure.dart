import 'package:image/image.dart' as img;

class UserData {
  final img.Image? _imageAvatar;
  final String _email;
  final String _password;
  final String _lastName;
  final String _name;

  UserData(this._imageAvatar, this._email, this._password, this._lastName,
      this._name);
}

class PostStructure {
  final DateTime _datePublicationPost;
  final img.Image? _imageInPost;
  final String _headline;
  final UserData _userData;
  final int _countLike;
  final String _textPost;

  PostStructure(this._datePublicationPost, this._imageInPost, this._headline,
      this._userData, this._countLike, this._textPost);
}

class PostDraft {
  final img.Image? _imageInPost;
  final String? _headline;
  final UserData _userData;
  final String? _textPost;

  PostDraft(this._imageInPost, this._headline, this._userData, this._textPost);
}

class CommentsStructure {
  final DateTime _datePublicationComment;
  final UserData _userDataCommentator;
  final String _textComment;
  final PostStructure _postData;

  CommentsStructure(this._datePublicationComment, this._userDataCommentator,
      this._textComment, this._postData);
}
