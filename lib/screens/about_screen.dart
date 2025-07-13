import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart'; // package_info_plus 패키지 추가

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appName = 'StudyApp';
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = info.appName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("앱 정보"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/mission.png', // 앱 로고 또는 아이콘 이미지 (필요시 경로 수정)
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 20),
              Text(
                _appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "버전: $_version (빌드: $_buildNumber)",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Text(
                "온사랑교회가 함께 하는 필리핀 언어 학습 앱입니다.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "이 앱은 수원온사랑교회 2025년 장년 필리핀 단기 선교사님만을 위한 것으로 목적외 사용금지 함",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "성공적인 선교를 기원합니다!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              const Text(
                "개발자 정보: AI & 박 집사",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const Text(
                "문의: xhpark@naver.com",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}