// lib/screens/session_list_screen.dart
import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/learning_result.dart'; // LearningResult 모델 import
import 'report_screen.dart'; // ReportScreen import

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({Key? key}) : super(key: key);

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  Future<List<Map<String, dynamic>>>? _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = DBHelper.getSessions(); // 모든 세션 불러오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("학습 세션 목록"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('세션을 불러오는 중 오류 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('저장된 학습 세션이 없습니다.'));
          } else {
            final sessions = snapshot.data!;
            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final sessionId = session['id'] as int;
                final userName = session['user_name'] as String;
                final language = session['selected_language'] as String;
                final mode = session['learning_mode'] as String;
                final level = session['level'] as String; // 레벨 정보 가져오기
                final sessionDate = session['session_date'] as String;
                final sessionTime = session['session_time'] as String;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      "$userName님의 학습 세션",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("언어: $language"),
                        Text("모드: $mode"),
                        // 레벨이 'N/A'가 아닐 때만 표시
                        if (level != 'N/A') Text("레벨: $level"),
                        Text("날짜: $sessionDate $sessionTime"),
                      ],
                    ),
                    onTap: () async {
                      // 로딩 다이얼로그 표시
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 10),
                                Text("결과 불러오는 중..."),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        // 해당 세션의 학습 결과 불러오기
                        final resultsMapList = await DBHelper.getResultsForSession(sessionId);
                        final learningResults = resultsMapList
                            .map((map) => LearningResult.fromMap(map))
                            .toList();

                        // 로딩 다이얼로그 닫기
                        Navigator.of(context).pop();

                        // ReportScreen으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportScreen(
                              results: learningResults,
                              userName: userName,
                              language: language,
                              mode: mode,
                              level: level,
                            ),
                          ),
                        );
                      } catch (e) {
                        // 로딩 다이얼로그 닫기
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('세션 결과를 불러오는 중 오류 발생: $e')),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}