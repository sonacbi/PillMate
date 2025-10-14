// pages/guide_page.dart
import 'package:flutter/material.dart';
import 'manage_page.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 420,
            minWidth: 360,
            maxHeight: 844,
            minHeight: 700,
          ),
          child: Column(
            children: [
              // 상단 패널
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE94844),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(200),
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: const Text(
                    "사용자 가이드",
                    style: TextStyle(
                      fontSize: 48, // StartPage PILL과 동일
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),

              // 하단 패널 (알약 모양)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(200),
                    ),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24), // 천장과 글씨 사이 여백
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "1. 앱과 약통(HC-06)을 블루투스로 연결하세요.",
                                style: TextStyle(fontSize: 16, height: 1.6),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "2. 사용자별로 약 정보를 등록하세요.",
                                style: TextStyle(fontSize: 16, height: 1.6),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "3. 앱에서 복용 여부를 확인하고 관리할 수 있습니다.",
                                style: TextStyle(fontSize: 16, height: 1.6),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "4. 연결이 끊어지면 자동으로 재연결 시도합니다.",
                                style: TextStyle(fontSize: 16, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              minimumSize: const Size(160, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "뒤로가기",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80), // 하단 여백 StartPage와 동일
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
