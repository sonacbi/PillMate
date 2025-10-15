// lib/utils/storage_helper.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/snapshot.dart';

class StorageHelper {
  static const _key = 'pillmate_snapshot';

  // 저장
  static Future<void> saveSnapshot(Snapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonStr = jsonEncode(snapshot.toJson());
    await prefs.setString(_key, jsonStr);
  }

  // 불러오기
  static Future<Snapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_key);

    if (jsonStr == null) {
      // 저장된 게 없으면 초기 상태 리턴
      return Snapshot(users: [], mapping: []);
    }

    try {
      final data = jsonDecode(jsonStr);
      return Snapshot.fromJson(data);
    } catch (e) {
      print("❌ 불러오기 실패: $e");
      return Snapshot(users: [], mapping: []);
    }
  }

  // 전체 삭제 (초기화용)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
