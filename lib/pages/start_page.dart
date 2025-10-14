// pages/start_page.dart
import 'package:flutter/material.dart';
import 'guide_page.dart';
import 'manage_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _pillOffsetAnimation;
  late final Animation<double> _pillOpacityAnimation;

  late final List<Animation<Offset>> _mateOffsetAnimations;
  late final List<Animation<double>> _mateOpacityAnimations;

  final letters = ["M", "A", "T", "E"];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // PILL 글자 애니메이션 (아래에서 위로)
    _pillOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8), // 1.0 = 아래쪽에서 시작
      end: Offset.zero,            // 원래 위치
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _pillOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );


    // MATE 글자별 애니메이션
    _mateOffsetAnimations = letters.asMap().entries.map((entry) {
      int i = entry.key;
      return Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.3 + i * 0.1, 1.0, curve: Curves.elasticOut),
        ),
      );
    }).toList();

    _mateOpacityAnimations = letters.asMap().entries.map((entry) {
      int i = entry.key;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.3 + i * 0.1, 1.0, curve: Curves.easeIn),
        ),
      );
    }).toList();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pillOpacityAnimation.value,
                        child: Transform.translate(
                          offset: _pillOffsetAnimation.value * 40,
                          child: const Text(
                            "PILL",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                      );
                    },
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
                      color: Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(letters.length, (i) {
                          return AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _mateOpacityAnimations[i].value,
                                child: Transform.translate(
                                  offset: _mateOffsetAnimations[i].value * 40,
                                  child: Text(
                                    letters[i],
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 6,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(140, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManagePage(
                                    onBack: () => Navigator.pop(context),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "시작하기",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              minimumSize: const Size(140, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GuidePage()),
                              );
                            },
                            child: const Text(
                              "사용자가이드",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
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
