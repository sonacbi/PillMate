// models/pill.dart

class Pill {
  int id;
  String name;
  int count;

  Pill({
    required this.id,
    required this.name,
    required this.count,
  });

  // 복제용 (deep copy)
  Pill copy() => Pill(id: id, name: name, count: count);

  // JSON 변환 (저장용)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'count': count,
      };

  // JSON 역변환 (불러오기용)
  factory Pill.fromJson(Map<String, dynamic> json) => Pill(
        id: json['id'],
        name: json['name'],
        count: json['count'],
      );
}
