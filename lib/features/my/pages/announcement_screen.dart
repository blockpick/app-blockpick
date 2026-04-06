import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 공지사항 화면
class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 공지사항 API 연동
    final announcements = _mockAnnouncements;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: Text(
            '공지사항',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: announcements.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: AppColors.gray400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '공지사항이 없습니다',
                      style: AppTextStyles.body2.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return _AnnouncementItem(announcement: announcement);
                },
              ),
      ),
    );
  }
}

class _AnnouncementItem extends StatefulWidget {
  final Map<String, dynamic> announcement;

  const _AnnouncementItem({required this.announcement});

  @override
  State<_AnnouncementItem> createState() => _AnnouncementItemState();
}

class _AnnouncementItemState extends State<_AnnouncementItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isImportant = widget.announcement['important'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: isImportant
            ? Border.all(color: AppColors.red.withValues(alpha: 0.3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isImportant) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        child: Text(
                          '중요',
                          style: AppTextStyles.caption4.copyWith(color: AppColors.red),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        widget.announcement['title'] as String,
                        style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray400,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.announcement['date'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: AppColors.gray100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.announcement['content'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray700,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 임시 데이터
final _mockAnnouncements = [
  {
    'id': '1',
    'title': '[공지] 서비스 점검 안내',
    'date': '2025.01.05',
    'content':
        '안녕하세요, BlockPick입니다.\n\n서비스 안정화를 위한 점검이 예정되어 있습니다.\n\n• 점검 일시: 2025년 1월 10일 02:00 ~ 06:00\n• 점검 내용: 서버 업그레이드 및 보안 패치\n\n점검 시간 동안 서비스 이용이 제한됩니다.\n불편을 드려 죄송합니다.',
    'important': true,
  },
  {
    'id': '2',
    'title': '신규 게임 오픈 안내',
    'date': '2025.01.03',
    'content':
        'BlockPick에 새로운 게임이 추가되었습니다!\n\n• 바이브 게임: 감각적인 선택으로 당첨 기회를!\n• 데일리 게임: 매일 새로운 기회\n\n많은 참여 부탁드립니다.',
    'important': false,
  },
  {
    'id': '3',
    'title': '개인정보처리방침 변경 안내',
    'date': '2025.01.01',
    'content':
        '개인정보처리방침이 아래와 같이 변경됩니다.\n\n• 시행일: 2025년 1월 15일\n• 변경 내용: 마케팅 정보 수집 항목 추가\n\n자세한 내용은 개인정보처리방침을 확인해주세요.',
    'important': false,
  },
];
