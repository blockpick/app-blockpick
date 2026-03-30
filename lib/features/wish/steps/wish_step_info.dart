import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Step 2: 상품 정보 확인/수정
class WishStepInfo extends StatefulWidget {
  final String productName;
  final int productPrice;
  final String? productImageUrl;
  final String storeName;
  final void Function(String name, int price, String? imageUrl) onNext;

  const WishStepInfo({
    super.key,
    required this.productName,
    required this.productPrice,
    this.productImageUrl,
    required this.storeName,
    required this.onNext,
  });

  @override
  State<WishStepInfo> createState() => _WishStepInfoState();
}

class _WishStepInfoState extends State<WishStepInfo> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  String? _imageUrl;
  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productName);
    _priceController = TextEditingController(
      text: widget.productPrice > 0 ? widget.productPrice.toString() : '',
    );
    _imageUrl = widget.productImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _validate() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim().replaceAll(',', '');
    final price = int.tryParse(priceText) ?? 0;

    setState(() {
      _nameError = name.length < 2 ? '상품명을 2자 이상 입력해주세요' : null;
      _priceError = price < 1000
          ? '1,000원 이상 입력해주세요'
          : price > 2000000
              ? '2,000,000원 이하로 입력해주세요'
              : null;
    });

    if (_nameError == null && _priceError == null) {
      widget.onNext(name, price, _imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상품 정보를 확인해주세요',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 24),
          // 상품 이미지
          Center(
            child: GestureDetector(
              onTap: () {
                // TODO: 이미지 선택 (갤러리/카메라)
              },
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: _imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _imagePlaceholder(),
                        ),
                      )
                    : _imagePlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '📷 탭하여 이미지 변경',
              style: TextStyle(fontSize: 12, color: AppColors.gray400),
            ),
          ),
          const SizedBox(height: 24),
          // 상품명
          const Text(
            '상품명 *',
            style: AppTextStyles.title3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '상품명을 입력해주세요',
              hintStyle: const TextStyle(color: AppColors.gray400),
              errorText: _nameError,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          // 상품 가격
          const Text(
            '상품 가격 *',
            style: AppTextStyles.title3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: const TextStyle(color: AppColors.gray400),
              errorText: _priceError,
              suffixText: '원',
              suffixStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 1,000원 ~ 2,000,000원',
            style: TextStyle(fontSize: 12, color: AppColors.gray400),
          ),
          const SizedBox(height: 12),
          // 구매처
          if (widget.storeName.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store, size: 14, color: AppColors.gray600),
                  const SizedBox(width: 6),
                  Text(
                    '구매처: ${widget.storeName}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 40),
          // 다음 버튼
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

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.gray400),
        const SizedBox(height: 4),
        const Text('이미지 추가', style: TextStyle(fontSize: 12, color: AppColors.gray400)),
      ],
    );
  }
}
