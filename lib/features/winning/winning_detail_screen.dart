import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/winning/winning_models.dart';
import '../../data/delivery_address/delivery_address_models.dart';
import '../../providers/winning_provider.dart';
import '../../providers/delivery_address_provider.dart';
import 'delivery_address_form_screen.dart';

/// 당첨 상세 화면 (기획 13-1)
class WinningDetailScreen extends ConsumerStatefulWidget {
  final WinningRecord winning;

  const WinningDetailScreen({super.key, required this.winning});

  @override
  ConsumerState<WinningDetailScreen> createState() =>
      _WinningDetailScreenState();
}

class _WinningDetailScreenState extends ConsumerState<WinningDetailScreen> {
  bool _claiming = false;

  WinningRecord get _w => widget.winning;

  String get _prizeShortId => _w.blockpickPrizeId.length >= 8
      ? _w.blockpickPrizeId.substring(0, 8)
      : _w.blockpickPrizeId;

  bool get _showDeliverySection => const {
        WinningStatus.claimRequired,
        WinningStatus.processing,
        WinningStatus.delivered,
        WinningStatus.completed,
      }.contains(_w.status);

  Future<void> _onClaim(DeliveryAddress? defaultAddr) async {
    if (defaultAddr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지를 먼저 등록해 주세요')),
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DeliveryAddressFormScreen(),
        ),
      );
      return;
    }

    setState(() => _claiming = true);
    try {
      final ds = await ref.read(winningRemoteDataSourceProvider.future);
      await ds.claimWinning(
        winningId: _w.id,
        deliveryAddressId: defaultAddr.id,
      );
      ref.invalidate(myWinningsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  Widget _buildStatusBadge(WinningStatus status) {
    final (label, color) = switch (status) {
      WinningStatus.pending => ('대기 중', AppColors.gray500),
      WinningStatus.claimRequired => ('정보 입력 필요', AppColors.orange),
      WinningStatus.processing => ('처리 중', AppColors.blue),
      WinningStatus.delivered => ('배송 완료', AppColors.green500),
      WinningStatus.completed => ('수령 완료', AppColors.green500),
      WinningStatus.failed => ('실패', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption2.copyWith(color: color),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(label,
                  style: AppTextStyles.body3.copyWith(color: AppColors.gray600)),
            ),
            Expanded(
              child: Text(value,
                  style: AppTextStyles.body3.copyWith(color: AppColors.darkBlue)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(myDeliveryAddressesProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          '당첨 상세',
          style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
        ),
        backgroundColor: AppColors.gray100,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('불러오기 실패: $e',
              style: AppTextStyles.body3.copyWith(color: AppColors.error)),
        ),
        data: (addresses) {
          final linkedAddr = _w.deliveryAddressId != null
              ? addresses
                  .where((a) => a.id == _w.deliveryAddressId)
                  .firstOrNull
              : null;
          final defaultAddr =
              addresses.where((a) => a.isDefault).firstOrNull ??
                  (addresses.isNotEmpty ? addresses.first : null);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // 1. 당첨 정보 카드
                    _sectionCard(children: [
                      Text(
                        '블록픽 보상 #$_prizeShortId',
                        style: AppTextStyles.title2
                            .copyWith(color: AppColors.darkBlue),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '당첨일: ${_w.issuedAt.length >= 10 ? _w.issuedAt.substring(0, 10) : _w.issuedAt}',
                        style: AppTextStyles.caption1
                            .copyWith(color: AppColors.gray600),
                      ),
                      const SizedBox(height: 10),
                      _buildStatusBadge(_w.status),
                      // 쿠폰 코드
                      if (_w.couponCode != null) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Text('쿠폰 코드',
                            style: AppTextStyles.caption1
                                .copyWith(color: AppColors.gray600)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _w.couponCode!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: AppColors.primaryMain,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: _w.couponCode!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('쿠폰 코드가 복사되었습니다')),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('복사'),
                            ),
                          ],
                        ),
                      ],
                    ]),

                    // 2. 배송 정보 섹션
                    if (_showDeliverySection)
                      _sectionCard(children: [
                        Text(
                          '배송 정보',
                          style: AppTextStyles.title3
                              .copyWith(color: AppColors.darkBlue),
                        ),
                        const SizedBox(height: 12),
                        if (linkedAddr != null) ...[
                          _infoRow('수령자', linkedAddr.recipientName),
                          _infoRow('주소', linkedAddr.address),
                          if (linkedAddr.phone != null)
                            _infoRow('전화번호', linkedAddr.phone!),
                          if (linkedAddr.postalCode != null)
                            _infoRow('우편번호', linkedAddr.postalCode!),
                        ] else ...[
                          Text(
                            '등록된 배송지가 없습니다',
                            style: AppTextStyles.body3
                                .copyWith(color: AppColors.gray600),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DeliveryAddressFormScreen(),
                                ),
                              );
                            },
                            child: const Text('배송지 등록하기'),
                          ),
                        ],
                      ]),

                    // 3. 배송 안내 (정적)
                    _sectionCard(children: [
                      Text(
                        '배송 안내',
                        style: AppTextStyles.title3
                            .copyWith(color: AppColors.darkBlue),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• 배송 가능 국가: KR, US, JP\n'
                        '• 배송비: 파트너 부담\n'
                        '• 관세/통관: 당첨자 부담',
                        style: AppTextStyles.body3
                            .copyWith(color: AppColors.gray600, height: 1.8),
                      ),
                    ]),
                  ],
                ),
              ),

              // 하단 CTA
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _w.status == WinningStatus.claimRequired
                        ? ElevatedButton(
                            onPressed: _claiming
                                ? null
                                : () => _onClaim(defaultAddr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMain,
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor: AppColors.gray200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusLg),
                              ),
                            ),
                            child: _claiming
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text('수령 정보 제출',
                                    style: AppTextStyles.buttonLarge),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('준비 중입니다')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusLg),
                              ),
                            ),
                            child: Text('문의하기',
                                style: AppTextStyles.buttonLarge
                                    .copyWith(color: AppColors.gray800)),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
