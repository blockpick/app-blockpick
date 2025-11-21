import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 숫자 키패드로 가격을 입력하는 위젯
class PriceKeypadInput extends StatefulWidget {
  final int? initialPrice;
  final int minPrice;
  final int maxPrice;
  final int priceStep; // 호가 단위 추가
  final Function(int?) onPriceChanged;
  final Function()? onConfirm; // 확인 버튼 콜백 추가
  final String? backgroundImageUrl;

  const PriceKeypadInput({
    super.key,
    this.initialPrice,
    required this.minPrice,
    required this.maxPrice,
    this.priceStep = 100, // 기본값 100원
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
      // 최대 10자리까지만 입력 가능
      if (_inputValue.length < 10) {
        _inputValue += number;
        _validateAndNotify();
      }
    });

    // 햅틱 피드백
    HapticFeedback.selectionClick();
  }

  void _handleBackspace() {
    setState(() {
      if (_inputValue.isNotEmpty) {
        _inputValue = _inputValue.substring(0, _inputValue.length - 1);
        _validateAndNotify();
      }
    });

    HapticFeedback.lightImpact();
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
      // 호가 단위에 맞게 조정된 가격 계산
      final adjustedPrice = _adjustToNearestStep(price);
      _showError = false;
      widget.onPriceChanged(adjustedPrice);
    }
  }

  /// 입력된 가격을 호가 단위에 맞게 조정 (가장 가까운 유효 가격으로)
  int _adjustToNearestStep(int price) {
    // 최소 가격으로부터의 차이 계산
    final diff = price - widget.minPrice;

    // 호가 단위로 나눈 나머지
    final remainder = diff % widget.priceStep;

    if (remainder == 0) {
      // 이미 호가 단위에 맞음
      return price;
    }

    // 반올림: 나머지가 호가 단위의 절반 이상이면 올림, 아니면 내림
    if (remainder >= widget.priceStep / 2) {
      // 올림
      return price - remainder + widget.priceStep;
    } else {
      // 내림
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

  @override
  Widget build(BuildContext context) {
    final canConfirm = _inputValue.isNotEmpty && !_showError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 가격 입력 디스플레이
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 입력된 가격 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _showError
                        ? AppColors.red.withOpacity(0.5)
                        : AppColors.purple.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_showError ? AppColors.red : AppColors.purple)
                          .withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 가격 텍스트
                    Text(
                      _displayValue,
                      style: AppTextStyles.display.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _showError
                            ? AppColors.red
                            : AppColors.darkBlue,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 4),
                    // "원" 단위
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '원',
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 16,
                          color: AppColors.grayBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 에러 메시지
              if (_showError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        size: 12,
                        color: AppColors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _errorMessage,
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 11,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),

              // 가격 범위 힌트
              if (!_showError && _inputValue.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Text(
                        '${_formatPrice(widget.minPrice)} ~ ${_formatPrice(widget.maxPrice)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grayBlue,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '호가 단위: ${_formatPrice(widget.priceStep)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grayBlue.withOpacity(0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // 숫자 키패드
        Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 키패드 그리드 (3x4)
              ...List.generate(4, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: List.generate(3, (col) {
                      final index = row * 3 + col;

                      // 마지막 줄 처리 (AC, 0, ⌫)
                      if (row == 3) {
                        if (col == 0) {
                          return _buildKeypadButton(
                            label: 'AC',
                            onPressed: _handleClear,
                            isSpecial: true,
                          );
                        } else if (col == 1) {
                          return _buildKeypadButton(
                            label: '0',
                            onPressed: () => _handleNumberPress('0'),
                          );
                        } else {
                          return _buildKeypadButton(
                            label: '⌫',
                            onPressed: _handleBackspace,
                            isSpecial: true,
                          );
                        }
                      }

                      // 숫자 버튼 (1-9)
                      final number = index + 1;
                      return _buildKeypadButton(
                        label: number.toString(),
                        onPressed: () => _handleNumberPress(number.toString()),
                      );
                    }),
                  ),
                );
              }),

              // 확인 버튼
              if (widget.onConfirm != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildConfirmButton(canConfirm),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadButton({
    required String label,
    IconData? icon,
    required VoidCallback onPressed,
    bool isSpecial = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: isSpecial
              ? AppColors.grayBlue.withOpacity(0.1)
              : AppColors.deepWhite,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(
                      icon,
                      size: 24,
                      color: isSpecial
                          ? AppColors.grayBlue
                          : AppColors.darkBlue,
                    )
                  : Text(
                      label,
                      style: AppTextStyles.large.copyWith(
                        fontSize: 24,
                        color: isSpecial
                            ? AppColors.grayBlue
                            : AppColors.darkBlue,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  /// 확인 버튼
  Widget _buildConfirmButton(bool enabled) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: enabled
            ? AppColors.gradientBluePurplePink
            : AppColors.gradientDisable,
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? widget.onConfirm : null,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  enabled ? LucideIcons.check : LucideIcons.lock,
                  size: 18,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  enabled ? '확인' : '가격을 입력하세요',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
