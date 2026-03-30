import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Step 3: 한줄평 작성
class WishStepOneliner extends StatefulWidget {
  final String initialText;
  final void Function(String text) onNext;

  const WishStepOneliner({
    super.key,
    required this.initialText,
    required this.onNext,
  });

  @override
  State<WishStepOneliner> createState() => _WishStepOnelinerState();
}

class _WishStepOnelinerState extends State<WishStepOneliner> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate() {
    final text = _controller.text.trim();
    if (text.length < 5) {
      setState(() => _errorText = '5자 이상 입력해주세요');
      return;
    }
    if (text.length > 100) {
      setState(() => _errorText = '100자 이하로 입력해주세요');
      return;
    }
    widget.onNext(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 상품이 왜 갖고 싶은지\n한줄로 표현해주세요! ✍️',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: '진심을 담아 한줄평을 작성해주세요',
              hintStyle: const TextStyle(color: AppColors.gray400),
              errorText: _errorText,
              filled: true,
              fillColor: AppColors.gray100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
          ),
          const SizedBox(height: 16),
          // 팁
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Tip: 진심이 담긴 한줄평은 더 많은 공감을 받아요!',
                  style: AppTextStyles.caption2.copyWith(color: AppColors.primary),
                ),
                SizedBox(height: 10),
                Text(
                  '예시:',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
                SizedBox(height: 4),
                Text(
                  '• "결혼 10주년 아내에게 선물하고 싶어요"\n• "이 드라이어 유튜브에서 봤는데 대박!"\n• "학교 졸업 선물로 딱인 노트북!"',
                  style: TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.6),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                '다음 →',
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
