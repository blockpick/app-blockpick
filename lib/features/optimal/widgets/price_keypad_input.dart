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
  final Function(int?) onPriceChanged;
  final Function()? onConfirm; // 확인 버튼 콜백 추가
  final String? backgroundImageUrl;

  const PriceKeypadInput({
    super.key,
    this.initialPrice,
    required this.minPrice,
    required this.maxPrice,
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
      _showError = false;
      widget.onPriceChanged(price);
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
      children: [
        // 가격 입력 디스플레이
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 입력된 가격 표시
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
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
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 가격 텍스트
                      Text(
                        _displayValue,
                        style: AppTextStyles.display.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: _showError
                              ? AppColors.red
                              : AppColors.darkBlue,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // "원" 단위
                      Text(
                        '원',
                        style: AppTextStyles.medium.copyWith(
                          fontSize: 24,
                          color: AppColors.grayBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                // 에러 메시지
                if (_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.alertCircle,
                          size: 16,
                          color: AppColors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _errorMessage,
                          style: AppTextStyles.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 가격 범위 힌트
                if (!_showError && _inputValue.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '${_formatPrice(widget.minPrice)} ~ ${_formatPrice(widget.maxPrice)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grayBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 숫자 키패드
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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
            children: [
              // 키패드 그리드 (3x4)
              ...List.generate(4, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: List.generate(3, (col) {
                      final index = row * 3 + col;

                      // 마지막 줄 처리 (C, 0, ⌫)
                      if (row == 3) {
                        if (col == 0) {
                          return _buildKeypadButton(
                            label: 'C',
                            icon: LucideIcons.delete,
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
                            icon: LucideIcons.delete,
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: isSpecial
              ? AppColors.grayBlue.withOpacity(0.1)
              : AppColors.deepWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 64,
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(
                      icon,
                      size: 28,
                      color: isSpecial
                          ? AppColors.grayBlue
                          : AppColors.darkBlue,
                    )
                  : Text(
                      label,
                      style: AppTextStyles.large.copyWith(
                        fontSize: 28,
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
      height: 56,
      decoration: BoxDecoration(
        gradient: enabled
            ? AppColors.gradientBluePurplePink
            : AppColors.gradientDisable,
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? widget.onConfirm : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  enabled ? LucideIcons.check : LucideIcons.lock,
                  size: 20,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  enabled ? '확인' : '가격을 입력하세요',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.white,
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
