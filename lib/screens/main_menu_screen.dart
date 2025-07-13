// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'language_select_screen.dart';
import 'session_list_screen.dart'; // 세션 목록 화면 import
import 'about_screen.dart'; // AboutScreen import를 추가합니다.

class MainMenuScreen extends StatelessWidget {
  final String userName; // userName을 필수로 받도록 추가

  const MainMenuScreen({super.key, required this.userName}); // 생성자 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("메인 메뉴")), // const 추가
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "환영합니다, $userName님!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // const 추가
            ),
            const SizedBox(height: 30), // const 추가
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectScreen(userName: userName), // userName 전달
                  ),
                );
              },
              child: const Text("학습 시작"), // const 추가
            ),
            const SizedBox(height: 10), // const 추가
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SessionListScreen()), // const 추가, 세션 목록 화면으로 이동
                );
              },
              child: const Text("학습 기록 보기"), // const 추가
            ),
            const SizedBox(height: 10), // const 추가
            ElevatedButton(
              onPressed: () {
                // 앱 정보 화면으로 이동 TODO 처리
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()), // const 추가, AboutScreen으로 이동
                );
              },
              child: const Text("앱 정보"), // const 추가
            ),
          ],
        ),
      ),
    );
  }
}