import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wish_model.dart';

/// 소원쓰기 리스트
class EmpathyCommentList extends StatefulWidget {
  final List<WishEmpathy> empathies;

  const EmpathyCommentList({super.key, required this.empathies});

  @override
  State<EmpathyCommentList> createState() => _EmpathyCommentListState();
}

class _EmpathyCommentListState extends State<EmpathyCommentList> {
  bool _showAll = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _showAll
        ? widget.empathies
        : widget.empathies.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 소원쓰기 입력
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '나도 이거 갖고 싶어요! 소원을 남겨주세요 ✨',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_commentController.text.trim().isNotEmpty) {
                  // TODO: 소원쓰기 등록 API 호출
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ 소원이 등록되었어요!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  _commentController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: const Icon(Icons.send, size: 18, color: AppColors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 소원 목록
        if (widget.empathies.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                '아직 소원이 없어요. 첫 소원을 남겨보세요!',
                style: TextStyle(fontSize: 13, color: AppColors.gray400),
              ),
            ),
          )
        else ...[
          ...displayList.map((e) => _CommentCard(empathy: e)),
          if (!_showAll && widget.empathies.length > 3)
            GestureDetector(
              onTap: () => setState(() => _showAll = true),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '더 보기 (${widget.empathies.length - 3}개)',
                  style: AppTextStyles.body4.copyWith(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// 소원쓰기 카드
class _CommentCard extends StatelessWidget {
  final WishEmpathy empathy;
  const _CommentCard({required this.empathy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gray200,
            child: Text(
              empathy.userName.isNotEmpty ? empathy.userName[0] : '?',
              style: AppTextStyles.title3.copyWith(color: AppColors.gray600),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${empathy.userName}',
                      style: AppTextStyles.caption2.copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(empathy.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.gray400),
                    ),
                  ],
                ),
                if (empathy.comment != null && empathy.comment!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    empathy.comment!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray800,
                      height: 1.4,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  const Text(
                    '🙏 나도 갖고 싶어요!',
                    style: TextStyle(fontSize: 12, color: AppColors.gray400),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dt.month}/${dt.day}';
  }
}
