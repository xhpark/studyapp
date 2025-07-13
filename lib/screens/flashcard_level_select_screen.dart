// lib/screens/flashcard_level_select_screen.dart
import 'package:flutter/material.dart';
import 'flashcard_learning_screen.dart'; // 플래시카드 학습 화면

class FlashcardLevelSelectScreen extends StatelessWidget {
  final String userName;
  final String selectedLanguage;

  const FlashcardLevelSelectScreen({
    super.key,
    required this.userName,
    required this.selectedLanguage,
  });

  // 레벨 목록을 const 리스트로 정의하여 불변성을 확보하고 성능을 최적화합니다.
  final List<String> _levels = const [ // 여기에 const 추가
    'Beginner', // 초급
    'Intermediate', // 중급
    'Advanced', // 고급
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("레벨 선택"), // const 추가
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$userName님, 플래시카드 학습 레벨을 선택해주세요.",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // const 추가
              textAlign: TextAlign.center,
            ),
            Text(
              "선택 언어: $selectedLanguage",
              style: const TextStyle(fontSize: 18), // const 추가
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30), // const 추가
            Expanded(
              child: ListView.builder(
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  // 사용자에게 보여줄 레벨 이름 (예: Beginner -> 초급)
                  String displayLevel;
                  switch (level) {
                    case 'Beginner':
                      displayLevel = '초급';
                      break;
                    case 'Intermediate':
                      displayLevel = '중급';
                      break;
                    case 'Advanced':
                      displayLevel = '고급';
                      break;
                    default:
                      displayLevel = level;
                  }

                  return Card(
                    // const 추가
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      // const 추가
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        displayLevel, // 사용자에게 보여줄 레벨 이름 사용
                        style: const TextStyle(fontSize: 18), // const 추가
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios), // const 추가
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashcardLearningScreen(
                              userName: userName,
                              selectedLanguage: selectedLanguage,
                              level: level, // 실제 데이터 필터링에 사용될 'Beginner' 등 전달
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