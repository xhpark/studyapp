// lib/screens/flashcard_learning_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/pronunciation_service.dart';
import '../services/db_helper.dart'; // DBHelper import
import '../models/learning_result.dart'; // LearningResult 모델 import
import 'report_screen.dart'; // ReportScreen import

class FlashcardLearningScreen extends StatefulWidget {
  final String userName;
  final String selectedLanguage;
  final String level; // 'Beginner', 'Intermediate', 'Advanced'

  const FlashcardLearningScreen({
    Key? key,
    required this.userName,
    required this.selectedLanguage,
    required this.level,
  }) : super(key: key);

  @override
  _FlashcardLearningScreenState createState() => _FlashcardLearningScreenState();
}

class _FlashcardLearningScreenState extends State<FlashcardLearningScreen> {
  String? _currentKoreanMeaning;
  String? _currentOriginalSentence;
  String? _currentCorrectPronunciation;
  String? _currentRecognizedPronunciation;
  String? _currentSentenceId;

  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isListening = false;
  bool _speechToTextAvailable = false;
  List<List<dynamic>> _flashcards = [];
  int _currentFlashcardIndex = 0;
  List<LearningResult> _learningResults = [];
  int? _currentSessionId; // 현재 세션 ID (saveSession에서 반환될 값)

  double? _similarity;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _loadFlashcards();
    // _startNewSession()은 이제 여기서 DB에 세션을 시작하지 않습니다.
    // 세션 ID는 모든 결과가 모인 후 _endSession에서 saveSession 호출 시 받습니다.
  }

  Future<void> _initSpeechToText() async {
    _speechToTextAvailable = await _speechToText.initialize(
      onStatus: (status) => setState(() => _isListening = _speechToText.isListening),
    );
    setState(() {});
  }

  Future<void> _loadFlashcards() async {
    final rawCsv = await rootBundle.loadString('assets/data.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawCsv);

    // 필터링: 선택된 언어와 레벨에 맞는 데이터만 로드
    _flashcards = csvTable.where((row) {
      return row[1] == widget.selectedLanguage && row[2] == widget.level;
    }).toList();

    if (_flashcards.isNotEmpty) {
      _loadNextFlashcard();
    } else {
      // 데이터가 없는 경우 처리 (예: 메시지 표시)
      setState(() {
        _currentKoreanMeaning = "해당 언어 및 레벨의 플래시카드가 없습니다.";
        _currentOriginalSentence = "데이터 없음";
      });
    }
  }

  void _loadNextFlashcard() {
    if (_currentFlashcardIndex < _flashcards.length) {
      final flashcard = _flashcards[_currentFlashcardIndex];
      setState(() {
        _currentSentenceId = flashcard[0].toString();
        _currentOriginalSentence = flashcard[3].toString(); // 원문 (세부아노/따갈로그어)
        _currentKoreanMeaning = flashcard[4].toString(); // 한국어 의미
        _currentCorrectPronunciation = flashcard[5].toString(); // 올바른 발음 (로마자)
        _currentRecognizedPronunciation = null; // 인식된 발음 초기화
        _similarity = null;
        _isCorrect = null;
      });
    } else {
      // 모든 플래시카드 학습 완료
      _endSession(); // 세션 종료
    }
  }

  // _startNewSession 메서드는 이제 DB 저장을 하지 않습니다.
  // 이 메서드는 initState에서 호출될 필요가 없어졌습니다.
  void _startNewSession() {
    // 세션 시작에 대한 로직이 필요하다면 여기에 추가하지만,
    // 실제 DB 저장은 모든 학습 결과가 모이는 _endSession에서 처리합니다.
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _endSession() async {
    // DBHelper.saveSession을 호출하여 세션 정보와 수집된 모든 학습 결과를 한 번에 저장합니다.
    _currentSessionId = await DBHelper.saveSession(
      widget.userName,
      widget.selectedLanguage,
      'Flashcard', // 학습 모드는 'Flashcard'로 고정
      widget.level,
      _learningResults, // 수집된 모든 학습 결과 리스트를 전달
    );

    // 결과 보고서 화면으로 이동
    // ReportScreen에 필요한 모든 인자들을 정확하게 전달합니다.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(
          results: _learningResults,
          userName: widget.userName,
          language: widget.selectedLanguage,
          mode: 'Flashcard', // mode 인자 전달
          level: widget.level, // level 인자 전달
        ),
      ),
    );
  }

  Future<void> _startListening() async {
    if (_speechToTextAvailable) {
      setState(() {
        _isListening = true;
        _currentRecognizedPronunciation = null; // 새로운 녹음 시작 시 이전 인식 결과 초기화
      });
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _currentRecognizedPronunciation = result.recognizedWords;
          });
          if (result.finalResult) {
            _stopListening(); // 최종 결과 시 자동 정지
          }
        },
        listenFor: const Duration(seconds: 5), // 5초 동안 듣기
        pauseFor: const Duration(seconds: 3), // 3초 정지 시 종료
        localeId: 'ko_KR', // 한국어 인식 (음성 인식 언어는 사용 언어와 일치시켜야 할 수 있습니다)
      );
    } else {
      print('Speech recognition not available');
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    // 녹음이 중지되면 바로 발음 비교를 시도
    _comparePronunciation();
  }

  Future<void> _playPronunciation() async {
    if (_currentOriginalSentence != null) {
      final audioFileName = _currentOriginalSentence!
          .replaceAll(' ', '_')
          .toLowerCase();

      final audioPath = 'assets/audio/${widget.selectedLanguage.toLowerCase()}_$audioFileName.mp3';

      try {
        await _audioPlayer.play(AssetSource(audioPath));
      } catch (e) {
        print('Error playing audio: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오디오 재생 실패: $e\n파일 경로: $audioPath')),
        );
      }
    }
  }

  void _comparePronunciation() {
    if (_currentCorrectPronunciation != null && _currentRecognizedPronunciation != null) {
      final similarity = PronunciationService.compareLevenshtein(
        _currentCorrectPronunciation!,
        _currentRecognizedPronunciation!,
        widget.selectedLanguage, // selectedLanguage 인자 추가
      );
      final isCorrect = similarity >= 0.7; // 임계치 (Threshold) 설정

      // 결과 저장
      _learningResults.add(
        LearningResult(
          sessionId: _currentSessionId ?? -1, // _currentSessionId가 null일 경우 기본값 -1 (안전한 사용)
          sentenceId: _currentSentenceId!,
          koreanMeaning: _currentKoreanMeaning!,
          correctPronunciation: _currentCorrectPronunciation!,
          recognizedPronunciation: _currentRecognizedPronunciation!,
          similarityScore: similarity,
          isCorrect: isCorrect,
        ),
      );

      setState(() {
        _similarity = similarity;
        _isCorrect = isCorrect;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("플래시카드 학습 (${widget.level})"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 현재 플래시카드 정보
              Text(
                _currentOriginalSentence ?? '로딩 중...',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _currentKoreanMeaning ?? '',
                style: const TextStyle(fontSize: 20, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 발음 듣기 버튼
              ElevatedButton.icon(
                onPressed: _playPronunciation,
                icon: const Icon(Icons.volume_up),
                label: const Text("발음 듣기", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 20),

              // 발음 입력 (음성 인식)
              ElevatedButton.icon(
                onPressed: _speechToTextAvailable && !_isListening ? _startListening : null,
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                label: Text(
                  _isListening ? "듣는 중..." : "내 발음 녹음",
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // 인식된 발음 표시
              if (_currentRecognizedPronunciation != null) ...[
                Text(
                  "인식된 발음: \"$_currentRecognizedPronunciation\"",
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],

              // 유사도 및 정답 여부 표시
              if (_similarity != null && _isCorrect != null) ...[
                const SizedBox(height: 10),
                Text(
                  "정답 발음: \"$_currentCorrectPronunciation\"",
                  style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "유사도: ${(_similarity! * 100).toStringAsFixed(2)}%",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  _isCorrect! ? "정답! 발음이 거의 같습니다." : "발음이 조금 달라요",
                  style: TextStyle(
                    color: _isCorrect! ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 30),

              // 다음 플래시카드 버튼
              ElevatedButton.icon(
                onPressed: _currentRecognizedPronunciation != null && !_isListening
                    ? () {
                        _currentFlashcardIndex++;
                        _loadNextFlashcard();
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("다음 플래시카드", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}