import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/delivery_address/delivery_address_models.dart';
import '../../providers/delivery_address_provider.dart';

/// 배송지 등록/수정 폼 화면 (기획 13-1)
class DeliveryAddressFormScreen extends ConsumerStatefulWidget {
  final DeliveryAddress? initial;

  const DeliveryAddressFormScreen({super.key, this.initial});

  @override
  ConsumerState<DeliveryAddressFormScreen> createState() =>
      _DeliveryAddressFormScreenState();
}

class _DeliveryAddressFormScreenState
    extends ConsumerState<DeliveryAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _phoneCtrl;

  String _countryCode = 'KR';
  bool _isDefault = false;
  bool _loading = false;

  static const _countries = ['KR', 'US', 'JP'];

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _nameCtrl = TextEditingController(text: d?.recipientName ?? '');
    _emailCtrl = TextEditingController(text: d?.email ?? '');
    _addressCtrl = TextEditingController(text: d?.address ?? '');
    _postalCtrl = TextEditingController(text: d?.postalCode ?? '');
    _phoneCtrl = TextEditingController(text: d?.phone ?? '');
    _countryCode = d?.countryCode ?? 'KR';
    _isDefault = d?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _postalCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final input = DeliveryAddressInput(
      recipientName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      countryCode: _countryCode,
      address: _addressCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim().isEmpty ? null : _postalCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      isDefault: _isDefault,
    );

    try {
      final ds = await ref.read(deliveryAddressRemoteDataSourceProvider.future);
      DeliveryAddress saved;
      if (widget.initial != null) {
        saved = await ds.updateDeliveryAddress(
            id: widget.initial!.id, input: input);
      } else {
        saved = await ds.createDeliveryAddress(input);
      }
      ref.invalidate(myDeliveryAddressesProvider);
      if (mounted) Navigator.of(context).pop(saved.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('배송지 삭제'),
        content: const Text('이 배송지를 삭제할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      final ds = await ref.read(deliveryAddressRemoteDataSourceProvider.future);
      await ds.deleteDeliveryAddress(id: widget.initial!.id);
      ref.invalidate(myDeliveryAddressesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDeco(String label, {bool required = true}) =>
      InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: AppTextStyles.body3.copyWith(color: AppColors.gray600),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(color: AppColors.primaryMain, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          isEdit ? '배송지 수정' : '배송지 등록',
          style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
        ),
        backgroundColor: AppColors.gray100,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 수령자 이름
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDeco('수령자 이름'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '수령자 이름을 입력해 주세요' : null,
            ),
            const SizedBox(height: 14),
            // 이메일
            TextFormField(
              controller: _emailCtrl,
              decoration: _inputDeco('이메일'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '이메일을 입력해 주세요';
                final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                return ok ? null : '올바른 이메일 형식이 아닙니다';
              },
            ),
            const SizedBox(height: 14),
            // 국가 코드
            DropdownButtonFormField<String>(
              initialValue: _countryCode,
              decoration: _inputDeco('국가'),
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _countryCode = v);
              },
            ),
            const SizedBox(height: 14),
            // 주소
            TextFormField(
              controller: _addressCtrl,
              decoration: _inputDeco('주소'),
              maxLines: 2,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '주소를 입력해 주세요' : null,
            ),
            const SizedBox(height: 14),
            // 우편번호 (optional)
            TextFormField(
              controller: _postalCtrl,
              decoration: _inputDeco('우편번호', required: false),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            // 연락처 (optional)
            TextFormField(
              controller: _phoneCtrl,
              decoration: _inputDeco('연락처', required: false),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            // 기본 배송지 스위치
            SwitchListTile(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: Text(
                '기본 배송지로 설정',
                style: AppTextStyles.body3.copyWith(color: AppColors.darkBlue),
              ),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primaryMain,
            ),
            const SizedBox(height: 24),
            // 저장 버튼
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMain,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.gray200,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusLg),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('저장', style: AppTextStyles.buttonLarge),
              ),
            ),
            // 삭제 버튼 (수정 모드)
            if (isEdit) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : _delete,
                child: Text(
                  '배송지 삭제',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.error),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
