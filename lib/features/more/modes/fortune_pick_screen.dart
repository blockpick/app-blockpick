import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import 'dart:math';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Fortune Pick - 운명의 질문에 답하고 좌표 받기
class FortunePickScreen extends StatefulWidget {
  const FortunePickScreen({super.key});

  @override
  State<FortunePickScreen> createState() => _FortunePickScreenState();
}

class _FortunePickScreenState extends State<FortunePickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.primaryLight;
  static const int gridSize = 1000;

  int _currentQuestion = 0;
  final Map<int, int> _answers = {};

  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _mysteryController;
  late Animation<double> _mysteryAnimation;

  final List<_FortuneQuestion> _questions = [
    _FortuneQuestion(
      question: 'How are you feeling today?',
      emoji: '✨',
      options: ['Amazing!', 'Good', 'So-so', 'Tired'],
      optionEmojis: ['🌟', '😊', '😐', '😴'],
    ),
    _FortuneQuestion(
      question: 'Pick your favorite season',
      emoji: '🌸',
      options: ['Spring', 'Summer', 'Fall', 'Winter'],
      optionEmojis: ['🌷', '☀️', '🍂', '❄️'],
    ),
    _FortuneQuestion(
      question: 'Choose your element',
      emoji: '🔮',
      options: ['Fire', 'Water', 'Earth', 'Air'],
      optionEmojis: ['🔥', '💧', '🌍', '💨'],
    ),
    _FortuneQuestion(
      question: 'What draws you?',
      emoji: '💫',
      options: ['Stars', 'Moon', 'Sun', 'Clouds'],
      optionEmojis: ['⭐', '🌙', '🌞', '☁️'],
    ),
    _FortuneQuestion(
      question: 'Pick a lucky symbol',
      emoji: '🎴',
      options: ['Clover', 'Heart', 'Diamond', 'Star'],
      optionEmojis: ['🍀', '❤️', '💎', '🌟'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
    _cardController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _mysteryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _mysteryAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      _mysteryController,
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _glowController.dispose();
    _mysteryController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    HapticFeedback.mediumImpact();

    setState(() {
      _answers[_currentQuestion] = answerIndex;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentQuestion < _questions.length - 1) {
        _cardController.reset();
        setState(() {
          _currentQuestion++;
        });
        _cardController.forward();
      } else {
        _calculateResult();
      }
    });
  }

  void _calculateResult() {
    HapticFeedback.heavyImpact();

    final answerString = _answers.values.join('-');
    final hash =
        sha256.convert(utf8.encode(answerString + DateTime.now().toString()));
    final hashString = hash.toString();

    final row =
        (int.parse(hashString.substring(0, 8), radix: 16) % gridSize) + 1;
    final col =
        (int.parse(hashString.substring(8, 16), radix: 16) % gridSize) + 1;

    final fortuneMessage = _generateFortune();

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Fortune',
      modeColor: modeColor,
      subtitle: fortuneMessage,
      onRetry: _resetQuestions,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  String _generateFortune() {
    final messages = [
      '✨ A special luck awaits you!',
      '💫 Good news is coming!',
      '🌟 Your choice will shine!',
      '🍀 Fortune favors you today!',
      '💝 Happiness fills your day!',
    ];
    final index =
        _answers.values.fold(0, (sum, v) => sum + v) % messages.length;
    return messages[index];
  }

  void _resetQuestions() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentQuestion = 0;
      _answers.clear();
    });
    _cardController.forward(from: 0);
  }

  void _goBack() {
    if (_currentQuestion > 0) {
      HapticFeedback.lightImpact();
      _cardController.reset();
      setState(() {
        _currentQuestion--;
      });
      _cardController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'FORTUNE',
        emoji: '🎭',
        accentColor: modeColor,
        actions: [
          if (_currentQuestion > 0)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusBottomSheet),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'BACK',
                      style: AppTextStyles.caption2.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: false,
        child: Stack(
          children: [
            // 미스터리 배경 이펙트
            AnimatedBuilder(
              animation: _mysteryAnimation,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _MysteryBackgroundPainter(
                    rotation: _mysteryAnimation.value,
                    color: modeColor,
                  ),
                );
              },
            ),

            // 메인 컨텐츠
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                child: Column(
                  children: [
                    // 진행도 표시
                    _buildProgressIndicator(progress),

                    const SizedBox(height: 32),

                    // 질문 카드
                    Expanded(
                      child: AnimatedBuilder(
                        animation:
                            Listenable.merge([_cardAnimation, _glowAnimation]),
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _cardAnimation.value,
                            child: Opacity(
                              opacity: _cardAnimation.value,
                              child: _buildQuestionCard(question),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Column(
      children: [
        // 카드 아이콘들
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_questions.length, (index) {
            final isCompleted = index < _currentQuestion;
            final isCurrent = index == _currentQuestion;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: isCurrent ? 40 : 30,
              height: isCurrent ? 50 : 40,
              decoration: BoxDecoration(
                gradient: isCompleted || isCurrent
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          modeColor,
                          modeColor.withValues(alpha: 0.6),
                        ],
                      )
                    : null,
                color: !isCompleted && !isCurrent
                    ? Colors.white.withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(
                  color: isCurrent
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.2),
                  width: isCurrent ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: modeColor.withValues(alpha: 0.5),
                          blurRadius: 15,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  isCompleted
                      ? '✓'
                      : isCurrent
                          ? _questions[index].emoji
                          : '?',
                  style: TextStyle(
                    fontSize: isCurrent ? 18 : 14,
                    color: Colors.white.withValues(alpha: isCompleted || isCurrent ? 1 : 0.3),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // 진행 바
        Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    modeColor,
                    AppColors.pink,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: modeColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(_FortuneQuestion question) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                modeColor.withValues(alpha: 0.2),
                AppColors.pink.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
            border: Border.all(
              color: modeColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: modeColor.withValues(alpha: 0.2 * _glowAnimation.value),
                blurRadius: 30 * _glowAnimation.value,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // 이모지 & 질문
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      modeColor.withValues(alpha: 0.4),
                      modeColor.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: modeColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    question.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),

              SizedBox(height: 24),

              Text(
                question.question,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(color: Colors.white),
              ),

              SizedBox(height: 8),

              Text(
                'Question ${_currentQuestion + 1} of ${_questions.length}',
                style: AppTextStyles.body4.copyWith(color: Colors.white.withValues(alpha: 0.5)),
              ),

              const SizedBox(height: 32),

              // 답변 옵션들
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(question.options.length, (index) {
                    final isSelected = _answers[_currentQuestion] == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionButton(
                        option: question.options[index],
                        emoji: question.optionEmojis[index],
                        index: index,
                        isSelected: isSelected,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String option,
    required String emoji,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    modeColor,
                    AppColors.pink,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: modeColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: AppTextStyles.title1,
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _FortuneQuestion {
  final String question;
  final String emoji;
  final List<String> options;
  final List<String> optionEmojis;

  _FortuneQuestion({
    required this.question,
    required this.emoji,
    required this.options,
    required this.optionEmojis,
  });
}

class _MysteryBackgroundPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _MysteryBackgroundPainter({
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 미스터리 원들
    for (int i = 0; i < 3; i++) {
      final radius = 150.0 + i * 80;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.03 - i * 0.01)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final path = Path();
      for (double angle = 0; angle < 2 * pi; angle += pi / 30) {
        final wobble = sin(angle * 3 + rotation + i) * 10;
        final x = center.dx + (radius + wobble) * cos(angle + rotation * 0.5);
        final y = center.dy + (radius + wobble) * sin(angle + rotation * 0.5);

        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // 별들
    final starPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 1.0 + random.nextDouble() * 2;
      final twinkle = sin(rotation * 2 + i) * 0.5 + 0.5;

      canvas.drawCircle(
        Offset(x, y),
        starSize * twinkle,
        starPaint..color = color.withValues(alpha: 0.1 + twinkle * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MysteryBackgroundPainter oldDelegate) => true;
}
