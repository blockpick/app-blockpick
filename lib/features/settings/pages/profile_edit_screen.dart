import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/domain/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// SC-011-02: 내 정보 수정 화면
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            '내 정보 수정',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 24),

                  // 프로필 이미지 & 닉네임
                  _buildProfileSection(user),

                  const SizedBox(height: 32),

                  // 메뉴 리스트
                  _buildMenuList(context, user),
                ],
              ),
            ),

            // 하단 로그아웃 & 회원탈퇴
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  /// 프로필 섹션 (이미지 + 닉네임 + 닉네임 변경)
  Widget _buildProfileSection(dynamic user) {
    final profileImageUrl = user?.profileImageUrl;
    final hasProfileImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

    return Column(
      children: [
        // 프로필 이미지
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            shape: BoxShape.circle,
            image: hasProfileImage
                ? DecorationImage(
                    image: NetworkImage(profileImageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasProfileImage
              ? null
              : Center(
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.gray400,
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // 닉네임
        Text(
          user?.nickname ?? user?.email?.split('@').first ?? '사용자',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),

        SizedBox(height: 8),

        // 닉네임 변경 버튼
        GestureDetector(
          onTap: () => _showNicknameChangeDialog(context, user),
          child: Text(
            '닉네임 변경',
            style: AppTextStyles.title3.copyWith(color: AppColors.blue, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  /// 메뉴 리스트
  Widget _buildMenuList(BuildContext context, dynamic user) {
    final email = user?.email ?? '';
    // 휴대폰 번호 마스킹 처리
    // TODO: 휴대폰 번호는 User 스키마에서 제거됨 - 별도 API 필요
    final phone = _maskPhoneNumber(null);

    return Column(
      children: [
        _buildMenuItem(
          title: '이메일 변경',
          value: email,
          onTap: () => context.push('/settings/profile/email'),
        ),
        _buildDivider(),
        _buildMenuItem(
          title: '휴대폰 번호 변경',
          value: phone,
          onTap: () => context.push('/settings/profile/phone'),
        ),
        _buildDivider(),
        _buildMenuItem(
          title: '비밀번호 변경',
          onTap: () => context.push('/settings/password'),
        ),
        _buildDivider(),
        _buildMenuItem(
          title: '프로필 사진 변경',
          onTap: () => _handleProfileImageChange(),
        ),
      ],
    );
  }

  /// 휴대폰 번호 마스킹
  String _maskPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return '';
    }

    // +82 10-1234-5678 형식이면 마스킹
    // +82 ····· 5678 형태로 변환
    if (phone.length >= 4) {
      final lastFour = phone.substring(phone.length - 4);
      if (phone.startsWith('+82')) {
        return '+82 ····· $lastFour';
      } else if (phone.startsWith('010')) {
        return '010-····-$lastFour';
      }
      return '····· $lastFour';
    }
    return phone;
  }

  /// 메뉴 아이템
  Widget _buildMenuItem({
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(
                title,
                style: AppTextStyles.body2.copyWith(color: AppColors.darkBlue),
              ),
              const Spacer(),
              if (value != null && value.isNotEmpty) ...[
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.gray100,
    );
  }

  /// 하단 액션 (로그아웃 & 회원탈퇴)
  Widget _buildBottomActions(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _handleLogout(context),
              child: Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '|',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray300,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _handleWithdrawal(context),
              child: Text(
                '회원탈퇴',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 닉네임 변경 다이얼로그
  void _showNicknameChangeDialog(BuildContext context, dynamic user) {
    final controller = TextEditingController(text: user?.nickname ?? '');
    String? errorText;
    bool isValid = false;
    bool isChecked = false; // 중복 확인 완료 여부

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            ),
            title: Text(
              '닉네임 변경',
              style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 닉네임 입력 필드 + 확인 버튼
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: '닉네임을 입력해 주세요.',
                          hintStyle: TextStyle(color: AppColors.gray400),
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
                            borderSide: BorderSide(color: AppColors.darkBlue),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            borderSide: BorderSide(color: AppColors.red),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            isChecked = false; // 입력 변경 시 확인 초기화
                            if (value.length >= 3 && value.length <= 20) {
                              isValid = true;
                              errorText = null;
                            } else {
                              isValid = false;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isValid && !isChecked
                            ? () {
                                // TODO: 닉네임 중복 확인 API 호출
                                setDialogState(() {
                                  // 예시: 성공 시
                                  isChecked = true;
                                  errorText = null;
                                  // 예시: 중복일 경우
                                  // errorText = '이미 있는 닉네임입니다. 다시 입력해 주세요.';
                                  // isChecked = false;
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.gray300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('확인'),
                      ),
                    ),
                  ],
                ),

                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorText!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.red,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // 안내 문구
                Text(
                  '• 최소 3자, 최대 20자까지 입력 가능합니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• 최초 1회만 변경 가능하오니 신중히 등록해주세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkBlue,
                        side: BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isChecked
                          ? () {
                              // TODO: 닉네임 변경 API 호출
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('닉네임이 변경되었습니다.'),
                                  backgroundColor: AppColors.darkBlue,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.gray300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('변경'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// 프로필 이미지 변경
  void _handleProfileImageChange() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusBottomSheet)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 갤러리에서 이미지 선택
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 카메라로 촬영
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.red),
                title: Text(
                  '프로필 사진 삭제',
                  style: TextStyle(color: AppColors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 프로필 사진 삭제
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 로그아웃
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        title: Text(
          '로그아웃 하시겠어요?',
          style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
        ),
        content: const Text(
          '로그아웃 하시면 재 로그인 전까지\n블록픽 이벤트에 응모할 수 없어요.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray700,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkBlue,
                    side: BorderSide(color: AppColors.gray300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref.read(authProvider.notifier).signOut();
                    context.go('/');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('로그아웃'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 회원탈퇴 화면으로 이동
  void _handleWithdrawal(BuildContext context) {
    context.push('/settings/withdrawal');
  }
}
