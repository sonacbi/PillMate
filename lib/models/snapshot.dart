// models/snapshot.dart

import 'mapping.dart';

class Snapshot {
  List<String> users;
  List<Mapping> mapping;

  Snapshot({
    required this.users,
    required this.mapping,
  });

  // 유저 존재 여부 확인
  bool hasUser(String name) => users.contains(name);

  // 새로운 유저 추가
  void addUser(String name) {
    if (!users.contains(name)) {
      users.add(name);
      mapping.add(Mapping(user: name, pills: []));
    }
  }

  // 유저 삭제
  void removeUser(String name) {
    users.remove(name);
    mapping.removeWhere((m) => m.user == name);
  }

  // JSON 변환
  Map<String, dynamic> toJson() => {
        'users': users,
        'mapping': mapping.map((m) => m.toJson()).toList(),
      };

  // JSON 역변환
  factory Snapshot.fromJson(Map<String, dynamic> json) => Snapshot(
        users: List<String>.from(json['users']),
        mapping: (json['mapping'] as List).map((e) => Mapping.fromJson(e)).toList(),
      );
}
