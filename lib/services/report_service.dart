// lib/services/report_service.dart
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import '../models/learning_result.dart';
import 'package:csv/csv.dart'; // 이 줄을 추가합니다.

class ReportService {
  Future<File> generateCsvReport(
      List<LearningResult> results,
      String userName,
      String language,
      String mode,
      String level) async {
    // CSV 데이터를 저장할 리스트를 선언합니다.
    final List<List<dynamic>> csvData = [];

    // CSV 헤더 (메타데이터) 추가
    csvData.add(['발음 비교 결과 (임계치 0.7)']);
    csvData.add(['Similarity threshold', '0.7']);
    csvData.add([]); // 구분용 빈 줄

    // 컬럼 헤더 추가
    csvData.add([
      'Sentence ID',
      'Korean Meaning',
      'Correct Pronunciation',
      'Recognized Pronunciation',
      'Similarity Score',
      'Is Correct'
    ]);

    // 학습 결과 데이터를 추가합니다.
    for (var result in results) {
      csvData.add([
        result.sentenceId,
        result.koreanMeaning,
        result.correctPronunciation,
        result.recognizedPronunciation,
        result.similarityScore.toStringAsFixed(2), // 소수점 두 자리로 포매팅
        result.isCorrect ? "O" : "X" // O/X로 표시
      ]);
    }

    // ListToCsvConverter를 사용하여 CSV 문자열을 생성합니다.
    // 이 컨버터는 데이터 내의 특수 문자(쉼표, 따옴표 등)를 자동으로 이스케이프 처리하여
    // CSV 파일 형식을 올바르게 유지합니다.
    final String csv = const ListToCsvConverter().convert(csvData);

    // 파일 경로 설정 및 파일 생성
    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/report_${userName}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(filePath);

    // CSV 문자열을 파일에 기록합니다.
    return file.writeAsString(csv, flush: true);
  }
}