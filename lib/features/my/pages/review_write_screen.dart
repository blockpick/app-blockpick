import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/winner_model.dart';

/// SC-011-18/19: 리뷰쓰기 화면
class ReviewWriteScreen extends StatefulWidget {
  final String productName;
  final String? productImageUrl;
  final String eventType;
  final String participatedAt;
  final String? existingReview;

  const ReviewWriteScreen({
    super.key,
    required this.productName,
    this.productImageUrl,
    required this.eventType,
    required this.participatedAt,
    this.existingReview,
  });

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  late final TextEditingController _reviewController;
  bool _isValid = false;

  static const int _minLength = 10;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.existingReview);
    _isValid = (_reviewController.text.length >= _minLength);
    _reviewController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _reviewController.removeListener(_onTextChanged);
    _reviewController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final valid = _reviewController.text.length >= _minLength;
    if (valid != _isValid) {
      setState(() => _isValid = valid);
    }
  }

  EventType? _parseEventType(String type) {
    for (final e in EventType.values) {
      if (e.name == type || e.displayName == type) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            isEditing ? '리뷰수정' : '리뷰쓰기',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildProductInfo(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildReviewInput(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// 당첨 상품 정보
  Widget _buildProductInfo() {
    final eventType = _parseEventType(widget.eventType);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(widget.productImageUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (eventType != null) ...[
                    _buildEventBadge(eventType),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.participatedAt,
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.productName,
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 상품 이미지
  Widget _buildProductImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        width: 72,
        height: 72,
        color: AppColors.gray100,
        child: imageUrl != null
            ? Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.card_giftcard_rounded,
        size: 32,
        color: AppColors.gray400,
      ),
    );
  }

  /// 이벤트 타입 배지
  Widget _buildEventBadge(EventType type) {
    Color badgeColor;
    switch (type) {
      case EventType.daily:
        badgeColor = AppColors.blue;
      case EventType.select:
        badgeColor = AppColors.purple;
      case EventType.vibe:
        badgeColor = AppColors.pink;
      case EventType.prime:
        badgeColor = AppColors.yellow500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        type.displayName.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          height: 1.2,
        ),
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.gray200,
    );
  }

  /// 리뷰 입력 필드
  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '리뷰 작성',
          style: AppTextStyles.body3.copyWith(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 8,
            minLines: 6,
            decoration: InputDecoration(
              hintText:
                  '블록픽을 이용한 소감 또는 상품 당첨에 대한 소감을 솔직하게 남겨주세요. (10자 이상)',
              hintStyle: AppTextStyles.body3.copyWith(
                color: AppColors.gray400,
                height: 1.6,
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
            style: AppTextStyles.body3.copyWith(
              color: AppColors.darkBlue,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_reviewController.text.length}자',
            style: AppTextStyles.body4.copyWith(
              color: _isValid ? AppColors.blue : AppColors.gray400,
            ),
          ),
        ),
      ],
    );
  }

  /// 완료 버튼
  Widget _buildSubmitButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isValid ? _handleSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isValid ? AppColors.darkBlue : AppColors.gray300,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.gray300,
              disabledForegroundColor: AppColors.gray500,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
              ),
            ),
            child: Text(
              '완료',
              style: AppTextStyles.buttonLarge.copyWith(
                color: _isValid ? AppColors.white : AppColors.gray500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 리뷰 제출 처리
  void _handleSubmit() {
    final reviewText = _reviewController.text.trim();
    if (reviewText.length < _minLength) return;

    // TODO: API 연동 - GraphQL mutation으로 리뷰 저장
    // mutation CreateReview($input: CreateReviewInput!) {
    //   createReview(input: $input) { id }
    // }

    final isEditing = widget.existingReview != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? '리뷰가 수정되었어요.' : '리뷰가 등록되었어요.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    context.pop(reviewText);
  }
}
