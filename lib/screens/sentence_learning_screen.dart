// lib/screens/sentence_learning_screen.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Future 사용을 위해 추가
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/pronunciation_service.dart'; // PronunciationService import
import '../services/db_helper.dart';
import '../models/learning_result.dart';
import 'report_screen.dart';

class SentenceLearningScreen extends StatefulWidget {
  final String userName;
  final String selectedLanguage;
  // 문장 학습에는 레벨 구분이 없으므로 level 인자는 제거하거나 N/A 처리합니다.
  // 이 화면에서는 사용하지 않지만, ReportScreen으로 전달해야 할 수 있으므로 임시로 추가합니다.
  final String? level; // 명시적으로 null 허용 또는 제거

  const SentenceLearningScreen({
    Key? key,
    required this.userName,
    required this.selectedLanguage,
    this.level, // ReportScreen 전달을 위해 필요하다면 추가 (초기엔 제거 권장)
  }) : super(key: key);

  @override
  _SentenceLearningScreenState createState() => _SentenceLearningScreenState();
}

class _SentenceLearningScreenState extends State<SentenceLearningScreen> {
  String? _currentCorrectPronunciation;
  String? _currentRecognizedPronunciation;
  String? _currentSentenceKoreanMeaning;
  String? _currentSentenceOriginal;
  String? _currentSentenceId; // CSV 첫 번째 컬럼 (id)

  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isListening = false;
  bool _speechToTextAvailable = false;
  List<List<dynamic>> _sentences = [];
  int _currentSentenceIndex = 0;
  List<LearningResult> _learningResults = [];
  int? _currentSessionId; // 현재 세션 ID (saveSession에서 반환될 값)

  double? _similarity;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _loadSentences();
    // _startNewSession()은 이제 여기서 DB에 세션을 시작하지 않습니다.
    // 세션 ID는 모든 결과가 모인 후 _endSession에서 saveSession 호출 시 받습니다.
  }

  Future<void> _initSpeechToText() async {
    _speechToTextAvailable = await _speechToText.initialize(
      onStatus: (status) => setState(() => _isListening = _speechToText.isListening),
    );
    setState(() {});
  }

  Future<void> _loadSentences() async {
    final rawCsv = await rootBundle.loadString('assets/data.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawCsv);

    // 필터링: 선택된 언어의 데이터만 로드 (문장 학습에는 레벨 구분이 없으므로 언어만 필터링)
    _sentences = csvTable.where((row) {
      // CSV 구조: id, language, level, original_sentence, korean_meaning, correct_pronunciation
      // row[1] == language
      return row[1] == widget.selectedLanguage;
    }).toList();

    if (_sentences.isNotEmpty) {
      _loadNextSentence();
    } else {
      // 데이터가 없는 경우 처리
      setState(() {
        _currentSentenceKoreanMeaning = "해당 언어의 문장이 없습니다.";
        _currentSentenceOriginal = "데이터 없음"; // 추가
      });
    }
  }

  void _loadNextSentence() {
    if (_currentSentenceIndex < _sentences.length) {
      final sentence = _sentences[_currentSentenceIndex];
      setState(() {
        _currentSentenceId = sentence[0].toString(); // id는 String으로 처리
        _currentSentenceOriginal = sentence[3].toString(); // 원문
        _currentSentenceKoreanMeaning = sentence[4].toString(); // 한국어 의미
        _currentCorrectPronunciation = sentence[5].toString(); // 올바른 발음 (로마자)
        _currentRecognizedPronunciation = null; // 인식된 발음 초기화
        _similarity = null;
        _isCorrect = null;
      });
    } else {
      // 모든 문장 학습 완료
      _endSession(); // 세션 종료
    }
  }

  // _startNewSession 메서드는 이제 DB 저장을 하지 않습니다.
  // 이 메서드는 initState에서 호출될 필요가 없어졌습니다.
  // 이전 _startNewSession 로직은 제거됩니다.
  // DB에 세션 시작을 기록하는 부분은 _endSession에서 saveSession으로 통합됩니다.

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
      'Sentence', // 학습 모드는 'Sentence'로 고정
      widget.level ?? 'N/A', // SentenceLearningScreen에서 level이 필요하다면 전달 (없으면 'N/A')
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
          mode: 'Sentence', // mode 인자 전달
          level: widget.level ?? 'N/A', // level 인자 전달 (없으면 'N/A')
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
    if (_currentSentenceOriginal != null) {
      final audioFileName = _currentSentenceOriginal!
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
          sentenceId: _currentSentenceId!, // String 타입으로 사용
          koreanMeaning: _currentSentenceKoreanMeaning!,
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
        title: Text("문장 학습 (${widget.selectedLanguage})"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _currentSentenceOriginal ?? '로딩 중...',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _currentSentenceKoreanMeaning ?? '',
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
                  _isCorrect! ? "정답!" : "발음이 조금 달라요",
                  style: TextStyle(
                    color: _isCorrect! ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],

              ElevatedButton.icon(
                onPressed: _currentRecognizedPronunciation != null && !_isListening
                    ? () {
                    _currentSentenceIndex++;
                    _loadNextSentence();
                  } : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("다음 문장으로", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}