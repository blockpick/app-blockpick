import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/notification/notification_models.dart';
import '../../providers/notification_provider.dart';

/// 알림 설정 화면 (기획서 11-3)
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationSetting? _draft;
  bool _isSaving = false;

  Future<void> _save() async {
    if (_draft == null) return;
    setState(() => _isSaving = true);
    try {
      final ds = await ref.read(notificationRemoteDataSourceProvider.future);
      await ds.updateNotificationSetting(
        pushWinning: _draft!.pushWinning,
        pushReward: _draft!.pushReward,
        pushReferral: _draft!.pushReferral,
        pushDeadline: _draft!.pushDeadline,
        pushMarketing: _draft!.pushMarketing,
      );
      ref.invalidate(notificationSettingProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('알림 설정이 저장되었어요'),
            backgroundColor: AppColors.green500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetToDefault() {
    setState(() {
      _draft = const NotificationSetting(
        pushWinning: true,
        pushReward: true,
        pushReferral: true,
        pushDeadline: true,
        pushMarketing: false,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("기본값으로 되돌렸어요. '저장'을 눌러 적용하세요"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingAsync = ref.watch(notificationSettingProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: AppColors.gray100,
        foregroundColor: AppColors.textBlack,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: settingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '알림 설정을 불러오지 못했어요',
                style: TextStyle(color: AppColors.gray600),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(notificationSettingProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (setting) {
          _draft ??= setting;
          final draft = _draft!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _buildTile(
                      title: '당첨 알림',
                      subtitle: '당첨 결과를 즉시 알려드려요',
                      value: draft.pushWinning,
                      onChanged: (v) => setState(() {
                        _draft = NotificationSetting(
                          pushWinning: v,
                          pushReward: draft.pushReward,
                          pushReferral: draft.pushReferral,
                          pushDeadline: draft.pushDeadline,
                          pushMarketing: draft.pushMarketing,
                        );
                      }),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildTile(
                      title: '보상 지급 알림',
                      subtitle: '참여권/포인트 지급을 알려드려요',
                      value: draft.pushReward,
                      onChanged: (v) => setState(() {
                        _draft = NotificationSetting(
                          pushWinning: draft.pushWinning,
                          pushReward: v,
                          pushReferral: draft.pushReferral,
                          pushDeadline: draft.pushDeadline,
                          pushMarketing: draft.pushMarketing,
                        );
                      }),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildTile(
                      title: '친구 초대 성공 알림',
                      subtitle: '친구가 참여하면 알려드려요',
                      value: draft.pushReferral,
                      onChanged: (v) => setState(() {
                        _draft = NotificationSetting(
                          pushWinning: draft.pushWinning,
                          pushReward: draft.pushReward,
                          pushReferral: v,
                          pushDeadline: draft.pushDeadline,
                          pushMarketing: draft.pushMarketing,
                        );
                      }),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildTile(
                      title: '마감 임박 알림',
                      subtitle: '참여 가능한 블록픽 마감을 알려드려요',
                      value: draft.pushDeadline,
                      onChanged: (v) => setState(() {
                        _draft = NotificationSetting(
                          pushWinning: draft.pushWinning,
                          pushReward: draft.pushReward,
                          pushReferral: draft.pushReferral,
                          pushDeadline: v,
                          pushMarketing: draft.pushMarketing,
                        );
                      }),
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildTile(
                      title: '마케팅 알림',
                      subtitle: '이벤트/혜택 소식을 받아볼 수 있어요',
                      value: draft.pushMarketing,
                      onChanged: (v) => setState(() {
                        _draft = NotificationSetting(
                          pushWinning: draft.pushWinning,
                          pushReward: draft.pushReward,
                          pushReferral: draft.pushReferral,
                          pushDeadline: draft.pushDeadline,
                          pushMarketing: v,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMain,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: AppColors.gray200,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusLg),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text(
                                  '저장',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isSaving ? null : _resetToDefault,
                        child: Text(
                          '기본값으로 되돌리기',
                          style: TextStyle(color: AppColors.gray600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textBlack,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primaryMain,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
