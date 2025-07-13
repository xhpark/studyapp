// lib/services/user_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  // 이미 static const로 잘 정의되어 있으며, 명시적으로 타입을 지정합니다.
  static const String _userNameKey = 'userName'; // String 타입 명시 (선택 사항)

  // 사용자 이름을 SharedPreferences에 저장합니다.
  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  // SharedPreferences에서 사용자 이름을 가져옵니다.
  // 저장된 이름이 없으면 null을 반환합니다.
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }
}