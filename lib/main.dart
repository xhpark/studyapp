// lib/main.dart
import 'package:flutter/material.dart';
import 'package:studyapp/screens/main_menu_screen.dart';
import 'package:studyapp/screens/user_name_input_screen.dart';
import 'package:studyapp/services/user_preferences.dart'; // UserPreferences import

void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화 (runApp 호출 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 사용자 이름 로드
  final String? initialUsername = await UserPreferences.getUsername();

  runApp(MyApp(initialUsername: initialUsername));
}

class MyApp extends StatefulWidget {
  final String? initialUsername;

  const MyApp({Key? key, required this.initialUsername}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _username;

  @override
  void initState() {
    super.initState();
    _username = widget.initialUsername;
  }

  // 사용자 이름이 설정될 때 호출될 콜백 함수
  void _onUsernameSet(String newUsername) {
    setState(() {
      _username = newUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _username == null || _username!.isEmpty
          ? UserNameInputScreen(onUsernameSet: _onUsernameSet)
          : MainMenuScreen(userName: _username!),
    );
  }
}