// lib/services/pronunciation_service.dart
import 'package:string_similarity/string_similarity.dart'; // string_similarity 패키지만 사용

class PronunciationService {
  /// 전처리 규칙: 유사 발음을 하나로 치환
  // 언어에 따라 전처리 규칙을 다르게 적용하기 위해 selectedLanguage 매개변수 추가
  static String preprocess(String text, String selectedLanguage) {
    String processedText = text.toLowerCase().trim(); // 기본적인 소문자 변환 및 공백 제거 유지

    // 살라맛 계열 통일 (기존 로직 유지)
    processedText = processedText
        .replaceAll('살나맛', '살라맛')
        .replaceAll('살나맏', '살라맛')
        .replaceAll('살나맡', '살라맛')
        .replaceAll('살라맏', '살라맛')
        .replaceAll('살라맡', '살라맛');

    // 된소리 ↔ 평음 허용 (기존 로직 유지, 의도된 양방향 치환으로 판단)
    processedText = processedText
        .replaceAll('따', '타')
        .replaceAll('타', '따')
        .replaceAll('뿌', '푸')
        .replaceAll('푸', '뿌')
        .replaceAll('꾸', '쿠')
        .replaceAll('쿠', '꾸')
        .replaceAll('뽀', '포')
        .replaceAll('포', '뽀')
        .replaceAll('꼬', '코')
        .replaceAll('코', '꼬')
        .replaceAll('토', '또')
        .replaceAll('또', '토');

    // 받침 ㄴ ↔ ㅁ (기존 로직 유지)
    processedText = processedText
        .replaceAll('낭', '남')
        .replaceAll('남', '낭');

    // 받침 ㄷ ↔ ㅌ (기존 로직 유지)
    processedText = processedText
        .replaceAll('맏', '맛')
        .replaceAll('맡', '맛')
        .replaceAll('맛', '맏');

    // ㄹ ↔ ㄴ (라 ↔ 나) (기존 로직 유지)
    processedText = processedText
        .replaceAll('라', '나')
        .replaceAll('나', '라');

    // 모음 유사 (기존 로직 유지)
    processedText = processedText
        .replaceAll('아', '어')
        .replaceAll('어', '아')
        .replaceAll('오', '우')
        .replaceAll('우', '오')
        .replaceAll('이', '에')
        .replaceAll('에', '이');

    // 중복 음절 처리 (언어별 조건부 적용)
    processedText = processedText.replaceAll('빠빠', '빠');

    // '오오' 처리 로직: 언어에 따라 다르게 적용
    if (selectedLanguage == 'Tagalog') {
      processedText = processedText.replaceAll('오오', '오');
    }

    return processedText;
  }

  /// 레벤슈타인 유사도 계산
  // 언어에 따라 전처리 규칙을 다르게 적용하기 위해 selectedLanguage 매개변수 추가
  static double compareLevenshtein(String correctPronunciation, String recognizedPronunciation, String selectedLanguage) {
    // 전처리된 문자열로 유사도 계산
    final preprocessedCorrect = preprocess(correctPronunciation, selectedLanguage);
    final preprocessedRecognized = preprocess(recognizedPronouncedPronunciation, selectedLanguage); // 오타 수정: preprocessedPronounced -> preprocessedRecognized

    // string_similarity 패키지의 similarityTo 메서드는 0.0 ~ 1.0 사이의 유사도 점수를 직접 반환합니다.
    return preprocessedRecognized.similarityTo(preprocessedCorrect);
  }
}