// lib/services/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/learning_result.dart'; // LearningResult 모델 import 확인

class DBHelper {
  static Database? _database;
  // 테이블 이름을 상수로 정의하고 const를 추가합니다.
  static const String _sessionTableName = 'sessions';
  static const String _learningResultsTableName = 'learning_results';

  // 데이터베이스 인스턴스를 비동기적으로 가져오는 getter
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  // 데이터베이스 초기화 및 열기/생성
  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'learning_app.db');
    return await openDatabase(
      path,
      version: 1, // 데이터베이스 버전
      onCreate: _onCreate, // 데이터베이스 생성 시 호출될 함수
      onOpen: _onOpen, // 데이터베이스 열릴 때 호출될 함수 (선택 사항, 마이그레이션 등에 활용)
    );
  }

  // 데이터베이스 테이블 생성
  static Future<void> _onCreate(Database db, int version) async {
    // sessions 테이블 생성
    await db.execute('''
      CREATE TABLE $_sessionTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_name TEXT,
        selected_language TEXT,
        learning_mode TEXT,
        level TEXT,
        session_date TEXT, -- YYYY-MM-DD 형식
        session_time TEXT  -- HH:MM:SS 형식
      )
    ''');
    // learning_results 테이블 생성
    // LearningResult 모델의 모든 필드를 반영합니다.
    await db.execute('''
      CREATE TABLE $_learningResultsTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        sentence_id TEXT, -- int -> TEXT로 변경 (_currentSentenceId가 String이므로)
        korean_meaning TEXT,
        correct_pronunciation TEXT,
        recognized_pronunciation TEXT,
        similarity_score REAL,
        is_correct INTEGER, -- SQLite에서 bool은 INTEGER (0: false, 1: true)
        FOREIGN KEY (session_id) REFERENCES $_sessionTableName (id) ON DELETE CASCADE
      )
    ''');
  }

  // 데이터베이스가 열릴 때 실행될 함수 (현재는 콘솔 로그만)
  static Future<void> _onOpen(Database db) async {
    print('Database opened at path: ${db.path}');
    // 향후 스키마 변경이 필요할 경우 여기에 마이그레이션 로직을 추가할 수 있습니다.
  }

  // 학습 세션과 그 결과를 저장하는 함수
  static Future<int> saveSession(
      String userName,
      String language,
      String mode,
      String level,
      List<LearningResult> results) async {
    final db = await database;
    // 세션 정보 저장
    int sessionId = await db.insert(
      _sessionTableName,
      {
        'user_name': userName,
        'selected_language': language,
        'learning_mode': mode,
        'level': level,
        'session_date': DateTime.now().toLocal().toString().split(' ')[0], // 날짜만 추출
        'session_time': DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8), // 시간만 추출
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // 충돌 시 대체
    );

    // 각 학습 결과 저장
    for (var result in results) {
      await db.insert(
        _learningResultsTableName,
        {
          'session_id': sessionId, // 생성된 세션 ID 연결
          'sentence_id': result.sentenceId,
          'korean_meaning': result.koreanMeaning,
          'correct_pronunciation': result.correctPronunciation,
          'recognized_pronunciation': result.recognizedPronunciation,
          'similarity_score': result.similarityScore,
          'is_correct': result.isCorrect ? 1 : 0, // bool을 INTEGER로 변환
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // 충돌 시 대체
      );
    }
    return sessionId; // 새로 저장된 세션의 ID 반환
  }

  // 저장된 모든 학습 세션을 가져오는 함수
  static Future<List<Map<String, dynamic>>> getSessions() async {
    final db = await database;
    return await db.query(
      _sessionTableName,
      orderBy: 'id DESC', // 최신 세션부터 가져오기
    );
  }

  // 특정 세션 ID에 해당하는 학습 결과들을 가져오는 함수
  static Future<List<Map<String, dynamic>>> getResultsForSession(int sessionId) async {
    final db = await database;
    return await db.query(
      _learningResultsTableName,
      where: 'session_id = ?', // session_id를 기준으로 필터링
      whereArgs: [sessionId],
    );
  }

  // (선택 사항) 모든 데이터를 초기화하는 개발/테스트용 함수
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_sessionTableName);
    await db.delete(_learningResultsTableName);
    print('All data cleared from $_sessionTableName and $_learningResultsTableName');
  }
}