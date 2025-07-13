// lib/models/learning_result.dart
class LearningResult {
  final int sessionId; // <-- 이 줄이 추가되어야 합니다.
  final String sentenceId; // int에서 String으로 변경
  final String koreanMeaning;
  final String correctPronunciation;
  final String recognizedPronunciation;
  final double similarityScore;
  final bool isCorrect;

  LearningResult({
    required this.sessionId, // <-- 여기에 추가
    required this.sentenceId, // 타입 변경
    required this.koreanMeaning,
    required this.correctPronunciation,
    required this.recognizedPronunciation,
    required this.similarityScore,
    required this.isCorrect,
  });

  // LearningResult 객체를 Map 형태로 변환 (데이터베이스 저장용)
  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId, // <-- 여기에 추가
      'sentence_id': sentenceId, // String 타입으로 사용
      'korean_meaning': koreanMeaning,
      'correct_pronunciation': correctPronunciation,
      'recognized_pronunciation': recognizedPronunciation,
      'similarity_score': similarityScore,
      'is_correct': isCorrect ? 1 : 0, // SQLite는 bool 타입을 직접 지원하지 않으므로 0 또는 1로 변환
    };
  }

  // Map 형태의 데이터를 LearningResult 객체로 변환 (데이터베이스 조회용)
  factory LearningResult.fromMap(Map<String, dynamic> map) {
    return LearningResult(
      sessionId: map['session_id'] as int, // <-- 여기에 추가
      sentenceId: map['sentence_id'] as String, // String으로 캐스팅
      koreanMeaning: map['korean_meaning'] as String,
      correctPronunciation: map['correct_pronunciation'] as String,
      recognizedPronunciation: map['recognized_pronunciation'] as String,
      similarityScore: map['similarity_score'] as double,
      isCorrect: map['is_correct'] == 1, // 0 또는 1 값을 bool로 다시 변환
    );
  }
}