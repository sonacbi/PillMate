// models/mapping.dart


import 'pill.dart';

class Mapping {
  String user;
  List<Pill> pills;
  bool breakfast;
  bool lunch;
  bool dinner;

  Mapping({
    required this.user,
    required this.pills,
    this.breakfast = false,
    this.lunch = false,
    this.dinner = false,
  });

  // 식사별 상태 맵
  Map<String, bool> get meals => {
        "breakfast": breakfast,
        "lunch": lunch,
        "dinner": dinner,
      };

  // 식사 토글 메서드
  void toggleMeal(String meal) {
    switch (meal) {
      case "breakfast":
        breakfast = !breakfast;
        break;
      case "lunch":
        lunch = !lunch;
        break;
      case "dinner":
        dinner = !dinner;
        break;
    }
  }

  // 복제 (deep copy)
  Mapping copy() => Mapping(
        user: user,
        pills: pills.map((p) => p.copy()).toList(),
        breakfast: breakfast,
        lunch: lunch,
        dinner: dinner,
      );

  // JSON 변환
  Map<String, dynamic> toJson() => {
        'user': user,
        'pills': pills.map((p) => p.toJson()).toList(),
        'breakfast': breakfast,
        'lunch': lunch,
        'dinner': dinner,
      };

  // JSON 역변환
  factory Mapping.fromJson(Map<String, dynamic> json) => Mapping(
        user: json['user'],
        pills: (json['pills'] as List).map((e) => Pill.fromJson(e)).toList(),
        breakfast: json['breakfast'] ?? false,
        lunch: json['lunch'] ?? false,
        dinner: json['dinner'] ?? false,
      );
}
