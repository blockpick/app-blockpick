import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
// dart:io는 웹에서 지원하지 않으므로 조건부로 사용
import 'dart:io' if (dart.library.html) 'package:blockpick_flutter/utils/platform_stub.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// SC-002: 권한설정 화면
///
/// 앱 최초 실행 시 1회 노출
/// - 필수 접근 권한: 기기 및 저장공간
/// - 선택 접근 권한: 알림, 문자, 카메라
class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  static const String _permissionShownKey = 'permission_screen_shown';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      // 제목
                      Text(
                        '앱 접근 권한 안내',
                        style: AppTextStyles.heading1.copyWith(color: AppColors.darkBlue),
                      ),
                      SizedBox(height: 12),
                      // 안내 문구
                      Text(
                        '블록픽은 더 나은 서비스를 위해\n아래와 같은 권한이 필요해요.',
                        style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
                      ),
                      const SizedBox(height: 40),

                      // 필수 접근 권한
                      _buildSectionTitle('필수 접근 권한', isRequired: true),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.storage_rounded,
                        title: '기기 및 저장공간',
                        description: '서비스 최적화 및 오류 확인',
                        color: AppColors.blue,
                      ),
                      const SizedBox(height: 32),

                      // 선택 접근 권한
                      _buildSectionTitle('선택 접근 권한', isRequired: false),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.notifications_rounded,
                        title: '알림',
                        description: '마케팅 알림, 배송 관련 알림',
                        color: AppColors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionItem(
                        icon: Icons.sms_rounded,
                        title: '문자',
                        description: '본인 인증 및 당첨 문자 수신',
                        color: AppColors.green500,
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionItem(
                        icon: Icons.camera_alt_rounded,
                        title: '카메라',
                        description: '프로필 사진, 상품 후기, QR코드 촬영',
                        color: AppColors.pink,
                      ),
                      SizedBox(height: 24),

                      // 안내 문구
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        ),
                        child: Text(
                          '선택 접근 권한은 관련 기능 이용 시 동의가 필요하며, 미동의 시에도 해당 기능 외 서비스는 이용 가능합니다.',
                          style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // 앱 종료 버튼
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _exitApp,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gray600,
                            side: BorderSide(color: AppColors.gray300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                            ),
                          ),
                          child: const Text(
                            '앱 종료',
                            style: AppTextStyles.title2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 동의하고 계속 버튼
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _continueToOnboarding,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '동의하고 계속',
                            style: AppTextStyles.title2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool isRequired}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isRequired
                ? AppColors.blue.withValues(alpha: 0.1)
                : AppColors.gray200,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Text(
            isRequired ? '필수' : '선택',
            style: AppTextStyles.caption2,
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
        ),
      ],
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body3.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  Future<void> _continueToOnboarding() async {
    // 실제 디바이스 권한 요청
    await _requestPermissions();

    // 권한 화면 표시 완료 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionShownKey, true);

    if (!mounted) return;

    // 온보딩 화면으로 이동
    context.go('/onboarding');
  }

  /// 실제 디바이스 권한 요청
  Future<void> _requestPermissions() async {
    // 알림 권한 요청
    await Permission.notification.request();

    // 카메라 권한 요청
    await Permission.camera.request();

    // Android에서만 SMS 권한 요청
    if (Platform.isAndroid) {
      await Permission.sms.request();
    }

    // iOS에서는 사진 라이브러리 권한도 요청
    if (Platform.isIOS) {
      await Permission.photos.request();
    }
  }
}
