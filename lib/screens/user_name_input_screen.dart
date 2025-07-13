import 'package:flutter/material.dart';
import '../services/user_preferences.dart'; // 이 import는 그대로 유지합니다.
import 'main_menu_screen.dart';

class UserNameInputScreen extends StatefulWidget {
  // 이미 const가 잘 적용되어 있습니다.
  const UserNameInputScreen({Key? key}) : super(key: key);

  @override
  _UserNameInputScreenState createState() => _UserNameInputScreenState();
}

class _UserNameInputScreenState extends State<UserNameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // 에러 메시지를 표시하기 위한 변수

  // 허용된 사용자 목록 (여기에 허용할 사용자 이름을 추가하세요)
  // List가 런타임에 변경되지 않는다면, const 키워드를 추가하여 컴파일 타임 상수로 만들 수 있습니다.
  final List<String> _allowedUsers = const [ // 여기에 const 추가
    '박상환',
    '최봉규',
    '신지욱',
    '조윤하',
    '한명선',
    '권조인',
    '김민섭',
    '김수경',
    '김순옥',
    '김시년',
    '김용묵',
    '김정선',
    '남일우',
    '김경순',
    '미영',
    '박영진',
    '배명희',
    '서성자',
    '서종원',
    '심덕용',
    '안영희',
    '안옥경',
    '안현옥',
    '엄지선',
    '유병준',
    '유영동',
    '이미경',
    '이성록',
    '이완식',
    '이혜금',
    '임창현',
    '정미용',
    '정효숙',
    '조복례',
    '조성미',
    '최현찬',
    '황경호',
    '황해붕',
    'Park sam', // 예시 사용자 이름,
    // 필요한 사용자 이름을 여기에 계속 추가하세요.
  ];

  // 공통 비밀번호
  // 이미 문자열 리터럴이므로 'const'를 붙일 필요는 없습니다. (성능 영향 미미)
  final String _commonPassword = '0821';

  void _authenticateAndSaveUserName() async {
    final String enteredName = _nameController.text.trim();
    final String enteredPassword = _passwordController.text.trim();

    setState(() {
      _errorMessage = null; // 이전 에러 메시지 초기화
    });

    // 1. 이름 유효성 검사
    if (enteredName.isEmpty || !_allowedUsers.contains(enteredName)) {
      setState(() {
        _errorMessage = '허용되지 않은 사용자 이름입니다.';
      });
      return;
    }

    // 2. 비밀번호 유효성 검사
    if (enteredPassword.isEmpty || enteredPassword != _commonPassword) {
      setState(() {
        _errorMessage = '비밀번호가 올바르지 않습니다.';
      });
      return;
    }

    // 모든 검증 통과 시
    await UserPreferences.saveUserName(enteredName);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainMenuScreen(userName: enteredName)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("사용자 인증")), // const가 잘 적용되어 있습니다.
      body: Padding(
        padding: const EdgeInsets.all(16), // const가 잘 적용되어 있습니다.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration( // const가 잘 적용되어 있습니다.
                labelText: "이름을 입력하세요",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16), // const가 잘 적용되어 있습니다.
            TextField(
              controller: _passwordController,
              obscureText: true, // 비밀번호 숨김
              decoration: const InputDecoration( // const가 잘 적용되어 있습니다.
                labelText: "비밀번호를 입력하세요",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20), // const가 잘 적용되어 있습니다.
            if (_errorMessage != null) // 에러 메시지가 있을 경우에만 표시
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0), // const가 잘 적용되어 있습니다.
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14), // const가 잘 적용되어 있습니다.
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _authenticateAndSaveUserName,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // const가 잘 적용되어 있습니다.
                textStyle: const TextStyle(fontSize: 18), // const가 잘 적용되어 있습니다.
              ),
              child: const Text("로그인"), // const가 잘 적용되어 있습니다.
            ),
          ],
        ),
      ),
    );
  }
}