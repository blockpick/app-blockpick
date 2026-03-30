import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/wish_provider.dart';

/// Step 1: 구매 URL 입력
class WishStepUrl extends ConsumerStatefulWidget {
  final String initialUrl;
  final void Function(String url, String? name, int? price, String? imageUrl, String? storeName) onNext;

  const WishStepUrl({
    super.key,
    required this.initialUrl,
    required this.onNext,
  });

  @override
  ConsumerState<WishStepUrl> createState() => _WishStepUrlState();
}

class _WishStepUrlState extends ConsumerState<WishStepUrl> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      setState(() => _errorText = null);
    }
  }

  Future<void> _parseAndContinue() async {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      setState(() => _errorText = 'URL을 입력해주세요');
      return;
    }

    if (!_isValidUrl(url)) {
      setState(() => _errorText = 'http:// 또는 https://로 시작하는 URL을 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final notifier = ref.read(wishCreateProvider.notifier);
      final result = await notifier.parseUrl(url);

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.isValid) {
          widget.onNext(
            url,
            result.productName,
            result.price,
            result.imageUrl,
            result.storeName,
          );
        } else {
          // 파싱 실패해도 수동 입력으로 진행
          widget.onNext(url, null, null, null, result.storeName);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // 에러 시에도 수동 입력으로 진행
        widget.onNext(url, null, null, null, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '갖고 싶은 상품의\n구매 링크를 붙여넣어주세요 📋',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 24),
          // URL 입력 필드
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'https://',
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _controller.clear();
                        setState(() => _errorText = null);
                      },
                      icon: const Icon(Icons.clear, size: 18, color: AppColors.gray400),
                    )
                  : null,
            ),
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() => _errorText = null),
          ),
          const SizedBox(height: 12),
          // 클립보드 붙여넣기 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.content_paste, size: 16),
              label: const Text('클립보드에서 붙여넣기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray600,
                side: const BorderSide(color: AppColors.gray200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 안내 텍스트
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '쿠팡, 네이버, 11번가, G마켓, 아마존 등의\n상품 링크를 넣어주세요',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 다음 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _parseAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.gray200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.white),
                      ),
                    )
                  : const Text(
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
