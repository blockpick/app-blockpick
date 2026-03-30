import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 숫자 키패드로 가격을 입력하는 위젯
///
/// SC-009-18 디자인:
/// - 다크 헤더 "입찰가 입력"
/// - 가격 범위 안내
/// - 심플 가격 표시 박스
/// - 키패드: 1-9, 00, 0, AC
/// - 다크 확인 버튼 "N원에 입찰하기"
class PriceKeypadInput extends StatefulWidget {
  final int? initialPrice;
  final int minPrice;
  final int maxPrice;
  final int priceStep;
  final Function(int?) onPriceChanged;
  final Function()? onConfirm;
  final String? backgroundImageUrl;

  const PriceKeypadInput({
    super.key,
    this.initialPrice,
    required this.minPrice,
    required this.maxPrice,
    this.priceStep = 100,
    required this.onPriceChanged,
    this.onConfirm,
    this.backgroundImageUrl,
  });

  @override
  State<PriceKeypadInput> createState() => _PriceKeypadInputState();
}

class _PriceKeypadInputState extends State<PriceKeypadInput> {
  String _inputValue = '';
  bool _showError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialPrice != null) {
      _inputValue = widget.initialPrice.toString();
    }
  }

  void _handleNumberPress(String number) {
    setState(() {
      if (_inputValue.length < 10) {
        _inputValue += number;
        _validateAndNotify();
      }
    });
    HapticFeedback.selectionClick();
  }

  void _handleClear() {
    setState(() {
      _inputValue = '';
      _showError = false;
      widget.onPriceChanged(null);
    });
    HapticFeedback.mediumImpact();
  }

  void _validateAndNotify() {
    if (_inputValue.isEmpty) {
      _showError = false;
      widget.onPriceChanged(null);
      return;
    }

    final price = int.tryParse(_inputValue);
    if (price == null) {
      _showError = true;
      _errorMessage = '올바른 숫자를 입력하세요';
      widget.onPriceChanged(null);
      return;
    }

    if (price < widget.minPrice) {
      _showError = true;
      _errorMessage = '최소 ${_formatPrice(widget.minPrice)}';
      widget.onPriceChanged(null);
    } else if (price > widget.maxPrice) {
      _showError = true;
      _errorMessage = '최대 ${_formatPrice(widget.maxPrice)}';
      widget.onPriceChanged(null);
    } else {
      final adjustedPrice = _adjustToNearestStep(price);
      _showError = false;
      widget.onPriceChanged(adjustedPrice);
    }
  }

  int _adjustToNearestStep(int price) {
    final diff = price - widget.minPrice;
    final remainder = diff % widget.priceStep;
    if (remainder == 0) return price;
    if (remainder >= widget.priceStep / 2) {
      return price - remainder + widget.priceStep;
    } else {
      return price - remainder;
    }
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }

  String get _displayValue {
    if (_inputValue.isEmpty) return '0';
    final price = int.tryParse(_inputValue);
    if (price == null) return _inputValue;
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  int? get _currentPrice {
    if (_inputValue.isEmpty) return null;
    return int.tryParse(_inputValue);
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _inputValue.isNotEmpty && !_showError;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 다크 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            decoration: BoxDecoration(
              color: AppColors.textBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '입찰가 입력',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '입찰 가능 금액 : ${_formatPrice(widget.minPrice)} ~ ${_formatPrice(widget.maxPrice)}',
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.gray400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // 가격 표시
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _showError ? AppColors.red : AppColors.gray200,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$_displayValue원',
                      style: AppTextStyles.display1.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _showError ? AppColors.red : AppColors.textBlack,
                      ),
                    ),
                  ),
                ),
                if (_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage,
                      style: AppTextStyles.body4.copyWith(
                        color: AppColors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 키패드 그리드 (1-9, 00, 0, AC)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Column(
              children: [
                // Row 1: 1, 2, 3
                _buildKeypadRow(['1', '2', '3']),
                const SizedBox(height: 8),
                // Row 2: 4, 5, 6
                _buildKeypadRow(['4', '5', '6']),
                const SizedBox(height: 8),
                // Row 3: 7, 8, 9
                _buildKeypadRow(['7', '8', '9']),
                SizedBox(height: 8),
                // Row 4: 00, 0, AC
                _buildKeypadRow(['00', '0', 'AC']),
              ],
            ),
          ),

          // 확인 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canConfirm ? widget.onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textBlack,
                  disabledBackgroundColor: AppColors.gray200,
                  foregroundColor: AppColors.white,
                  disabledForegroundColor: AppColors.gray400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  canConfirm
                      ? '${_formatPrice(_currentPrice!)}에 입찰하기'
                      : '가격을 입력하세요',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        final isSpecial = key == 'AC';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  if (key == 'AC') {
                    _handleClear();
                  } else {
                    _handleNumberPress(key);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: isSpecial ? 16 : 22,
                      fontWeight: isSpecial ? FontWeight.w600 : FontWeight.w500,
                      color: isSpecial ? AppColors.gray600 : AppColors.textBlack,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
