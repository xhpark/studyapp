import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // CSV 파일 공유를 위해 필요
// 파일 저장을 위해 필요
import 'learning_result.dart';
import '../services/report_service.dart'; // ReportService import

class ReportScreen extends StatefulWidget {
  final List<LearningResult> results;
  final String userName;
  final String language;
  final String mode;
  final String level; // 플래시카드 학습에서만 유효

  const ReportScreen({
    Key? key,
    required this.results,
    required this.userName,
    required this.language,
    required this.mode,
    required this.level,
  }) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _csvFilePath;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _generateAndSaveReport();
  }

  Future<void> _generateAndSaveReport() async {
    setState(() {
      _isGenerating = true;
    });
    try {
      final reportService = ReportService();
      final file = await reportService.generateCsvReport(
        widget.results,
        widget.userName,
        widget.language,
        widget.mode,
        widget.level,
      );
      setState(() {
        _csvFilePath = file.path;
        _isGenerating = false;
      });
      print('보고서 저장 경로: $_csvFilePath');
    } catch (e) {
      print('보고서 생성 오류: $e');
      setState(() {
        _isGenerating = false;
        _csvFilePath = 'Error: 보고서 생성 실패';
      });
    }
  }

  Future<void> _shareReport() async {
    if (_csvFilePath != null && _csvFilePath!.startsWith('/')) { // 유효한 파일 경로인지 확인
      try {
        final XFile file = XFile(_csvFilePath!);
        await Share.shareXFiles([file], text: '나의 학습 보고서입니다.');
      } catch (e) {
        print('보고서 공유 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('보고서를 공유할 수 없습니다: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보고서 파일이 아직 생성되지 않았거나 경로가 유효하지 않습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 총 문장 수와 정답/오답 개수 계산
    final int totalSentences = widget.results.length;
    final int correctCount = widget.results.where((r) => r.isCorrect).length;
    final int incorrectCount = totalSentences - correctCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("학습 결과 보고서"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('사용자: ${widget.userName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('학습 언어: ${widget.language}', style: const TextStyle(fontSize: 16)),
                    Text('학습 모드: ${widget.mode}', style: const TextStyle(fontSize: 16)),
                    if (widget.mode == 'Flashcard') Text('레벨: ${widget.level}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text('총 학습 문장 수: $totalSentences', style: const TextStyle(fontSize: 18)),
                    Text('정답: $correctCount', style: const TextStyle(fontSize: 18, color: Colors.green)),
                    Text('오답: $incorrectCount', style: const TextStyle(fontSize: 18, color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.results.length,
                itemBuilder: (context, index) {
                  final result = widget.results[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${result.koreanMeaning} (${result.correctPronunciation})'),
                      subtitle: Text('내 발음: ${result.recognizedPronunciation} (유사도: ${result.similarityScore.toStringAsFixed(2)})'),
                      trailing: Icon(
                        result.isCorrect ? Icons.check_circle : Icons.cancel,
                        color: result.isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _isGenerating
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _shareReport,
                    icon: const Icon(Icons.share),
                    label: const Text("보고서 공유 (CSV)"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // 메인 메뉴로 돌아가기
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text("메인 메뉴로 돌아가기"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}