import 'dart:typed_data';

abstract class IProfile {
  String? get lastName;
  String? get name;
  Uint8List get avatar;

  factory IProfile.fromList(Map<String, dynamic> json) {
    return Profile.fromList(json);
  }
}

class Profile implements IProfile {
  @override
  final String? lastName;
  @override
  final String? name;
  @override
  final Uint8List avatar;

  Profile({
    required this.lastName,
    required this.name,
    required this.avatar,
  });

  factory Profile.fromList(Map<String, dynamic> json) {
    List<int> avatarList = json['avatar'] != null
        ? (json['avatar'] as List<dynamic>).map((e) => e as int).toList()
        : [];
    return Profile(
        lastName: json['last_name'],
        name: json['name'],
        avatar: Uint8List.fromList(avatarList));
  }
}
