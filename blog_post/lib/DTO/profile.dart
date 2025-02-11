import 'dart:typed_data';

class ProfileInfo {
  final String? lastName;
  final String? name;
  final Uint8List? avatar;

  ProfileInfo(
      {required this.lastName, required this.name, required this.avatar});

  factory ProfileInfo.fromList(List<dynamic> data) {
    return ProfileInfo(lastName: data[0], name: data[1], avatar: Uint8List.fromList(List<int>.from(data[2])));
  }
}
