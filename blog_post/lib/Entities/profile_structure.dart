import 'dart:typed_data';

class ProfileInfo {
  final String? lastName;
  final String? name;
  final Uint8List avatar;

  ProfileInfo(
      {required this.lastName, required this.name, required this.avatar});

  factory ProfileInfo.fromList(Map<String, dynamic> json) {
    List<int> avatarList = json['avatar'] != null
        ? (json['avatar'] as List<dynamic>).map((e) => e as int).toList()
        : [];
    return ProfileInfo(
        lastName: json['last_name'],
        name: json['name'],
        avatar: Uint8List.fromList(avatarList));
  }
}
