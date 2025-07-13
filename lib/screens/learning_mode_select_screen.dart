// lib/screens/learning_mode_select_screen.dart
import 'package:flutter/material.dart';
import 'flashcard_level_select_screen.dart'; // 플래시카드 레벨 선택 화면
import 'sentence_learning_screen.dart';     // 문장 학습 화면

class LearningModeSelectScreen extends StatelessWidget {
  final String userName;
  final String selectedLanguage;

  const LearningModeSelectScreen({
    super.key,
    required this.userName,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("학습 모드 선택"), // const 추가
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$userName님, 어떤 방식으로 학습하시겠어요?",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // const 추가
              textAlign: TextAlign.center,
            ),
            Text(
              "선택 언어: $selectedLanguage",
              style: const TextStyle(fontSize: 18), // const 추가
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30), // const 추가
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardLevelSelectScreen(
                      userName: userName,
                      selectedLanguage: selectedLanguage,
                    ),
                  ),
                );
              },
              child: const Text("플래시카드 학습"), // const 추가
            ),
            const SizedBox(height: 20), // const 추가
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SentenceLearningScreen(
                      userName: userName,
                      selectedLanguage: selectedLanguage,
                    ),
                  ),
                );
              },
              child: const Text("문장 학습"), // const 추가
            ),
          ],
        ),
      ),
    );
  }
}