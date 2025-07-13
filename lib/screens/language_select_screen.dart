// lib/screens/language_select_screen.dart
import 'package:flutter/material.dart';
import 'learning_mode_select_screen.dart';

class LanguageSelectScreen extends StatelessWidget {
  final String userName;

  const LanguageSelectScreen({super.key, required this.userName});

  // 언어 목록을 따갈로그어와 세부아노어만 포함하도록 수정합니다.
  final List<String> _languages = const [
    '따갈로그어',
    '세부아노어',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("언어 선택"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$userName님, 학습할 언어를 선택해주세요.",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        language,
                        style: const TextStyle(fontSize: 18),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LearningModeSelectScreen(
                              userName: userName,
                              selectedLanguage: language,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}