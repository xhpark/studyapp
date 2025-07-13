// lib/screens/report_screen.dart
import 'package:flutter/material.dart';
import '../models/learning_result.dart'; // LearningResult 모델을 사용하므로 import가 필요합니다.

class ReportScreen extends StatelessWidget {
  final List<LearningResult> results; // 학습 결과 리스트
  final String userName; // 사용자 이름
  final String language; // 선택된 언어
  final String mode; // 학습 모드 (예: 'Flashcard')
  final String level; // 학습 레벨

  ReportScreen({
    Key? key,
    required this.results,
    required this.userName,
    required this.language,
    required this.mode,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("학습 결과 보고서"),
        backgroundColor: Theme.of(context).primaryColor, // 앱바 배경색을 테마 기본색으로 설정
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('사용자: $userName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('언어: $language', style: const TextStyle(fontSize: 16)),
            Text('모드: $mode', style: const TextStyle(fontSize: 16)),
            Text('레벨: $level', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text('학습 결과 상세:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3, // 카드에 그림자 효과 추가
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('의미: ${result.koreanMeaning}', style: const TextStyle(fontSize: 16)),
                          Text('정답 발음: ${result.correctPronunciation}', style: const TextStyle(fontSize: 16)),
                          Text('내 발음: ${result.recognizedPronunciation}', style: const TextStyle(fontSize: 16)),
                          Text('유사도: ${(result.similarityScore * 100).toStringAsFixed(2)}%',
                              style: TextStyle(
                                  color: result.isCorrect ? Colors.green[700] : Colors.red[700],
                                  fontWeight: FontWeight.bold)),
                          Text(result.isCorrect ? '정확!' : '다름!',
                              style: TextStyle(
                                  color: result.isCorrect ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 이전 화면으로 돌아가기 (보통 MainMenuScreen)
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('돌아가기', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}