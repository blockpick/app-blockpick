import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 쿠폰 화면
class CouponScreen extends ConsumerStatefulWidget {
  const CouponScreen({super.key});

  @override
  ConsumerState<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends ConsumerState<CouponScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _couponCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: const Text(
            '쿠폰',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.darkBlue,
            unselectedLabelColor: AppColors.gray500,
            indicatorColor: AppColors.blue,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: '보유 쿠폰'),
              Tab(text: '쿠폰 등록'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCouponList(),
            _buildCouponRegister(),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponList() {
    // TODO: 실제 쿠폰 목록 API 연동
    final coupons = _mockCoupons;

    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              '보유한 쿠폰이 없습니다',
              style: AppTextStyles.body2.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return _CouponItem(coupon: coupon);
      },
    );
  }

  Widget _buildCouponRegister() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '쿠폰 코드 입력',
            style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _couponCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: '쿠폰 코드를 입력하세요',
                    hintStyle: TextStyle(color: AppColors.gray400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.gray200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 쿠폰 등록 API 연동
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('쿠폰이 등록되었습니다'),
                          backgroundColor: AppColors.green500,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '등록',
                      style: AppTextStyles.title2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponItem extends StatelessWidget {
  final Map<String, dynamic> coupon;

  const _CouponItem({required this.coupon});

  @override
  Widget build(BuildContext context) {
    final isExpired = DateTime.parse(coupon['expiry'] as String)
        .isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isExpired
            ? Border.all(color: AppColors.gray300)
            : Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? AppColors.gray200
                            : AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        coupon['type'] as String,
                        style: AppTextStyles.caption4.copyWith(color: isExpired ? AppColors.gray500 : AppColors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  coupon['name'] as String,
                  style: AppTextStyles.title2.copyWith(color: isExpired ? AppColors.gray400 : AppColors.darkBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  coupon['discount'] as String,
                  style: AppTextStyles.heading1.copyWith(color: isExpired ? AppColors.gray400 : AppColors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  '${coupon['expiry']}까지',
                  style: TextStyle(
                    fontSize: 12,
                    color: isExpired ? AppColors.red : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          if (isExpired)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gray400,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '만료',
                  style: AppTextStyles.caption4.copyWith(color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 임시 데이터
final _mockCoupons = [
  {
    'id': '1',
    'name': '신규 가입 환영 쿠폰',
    'type': '게임',
    'discount': '3,000원',
    'expiry': '2025-02-28',
  },
  {
    'id': '2',
    'name': '쇼핑몰 할인 쿠폰',
    'type': '쇼핑',
    'discount': '10%',
    'expiry': '2025-01-31',
  },
];
