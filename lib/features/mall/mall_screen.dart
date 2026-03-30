import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../components/common/common_app_bar.dart';

/// 토스 스타일 쇼핑 화면
class MallScreen extends StatefulWidget {
  const MallScreen({super.key});

  @override
  State<MallScreen> createState() => _MallScreenState();
}

class _MallScreenState extends State<MallScreen> {
  int _selectedCategoryIndex = 0;
  final Set<int> _favorites = {}; // 찜한 상품 인덱스

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.hotel_rounded, 'label': '호텔'},
    {'icon': Icons.checkroom_rounded, 'label': '패션'},
    {'icon': Icons.devices_rounded, 'label': '전자기기'},
    {'icon': Icons.card_giftcard_rounded, 'label': '상품권'},
    {'icon': Icons.restaurant_rounded, 'label': '맛집'},
    {'icon': Icons.sports_esports_rounded, 'label': '레저'},
  ];

  final List<Map<String, dynamic>> _allProducts = [
    // 호텔 (category: 0)
    {
      'name': '[나트랑] JW 메리어트 깜란 베이 리조트 & 스파',
      'location': '베트남 나트랑',
      'originalPrice': 320000,
      'price': 240000,
      'discount': 25,
      'rating': 4.8,
      'reviews': 2847,
      'tag': 'HOT',
      'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
      'category': 0,
    },
    {
      'name': '[다낭] 퓨전 리조트 앤 빌라',
      'location': '베트남 다낭',
      'originalPrice': 380000,
      'price': 299000,
      'discount': 21,
      'rating': 4.9,
      'reviews': 1523,
      'tag': 'BEST',
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
      'category': 0,
    },
    {
      'name': '[푸켓] 반얀트리 푸켓 풀빌라',
      'location': '태국 푸켓',
      'originalPrice': 550000,
      'price': 450000,
      'discount': 18,
      'rating': 4.7,
      'reviews': 892,
      'tag': null,
      'image': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400&h=300&fit=crop',
      'category': 0,
    },
    {
      'name': '[발리] 아야나 리조트 & 스파',
      'location': '인도네시아 발리',
      'originalPrice': 420000,
      'price': 380000,
      'discount': 10,
      'rating': 4.8,
      'reviews': 3241,
      'tag': 'NEW',
      'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400&h=300&fit=crop',
      'category': 0,
    },
    {
      'name': '[몰디브] 콘래드 몰디브 랑갈리 아일랜드',
      'location': '몰디브',
      'originalPrice': 1500000,
      'price': 1200000,
      'discount': 20,
      'rating': 4.9,
      'reviews': 456,
      'tag': 'PREMIUM',
      'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=400&h=300&fit=crop',
      'category': 0,
    },
    {
      'name': '[세부] 샹그릴라 막탄 리조트',
      'location': '필리핀 세부',
      'originalPrice': 280000,
      'price': 220000,
      'discount': 21,
      'rating': 4.6,
      'reviews': 1876,
      'tag': null,
      'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&h=300&fit=crop',
      'category': 0,
    },
    // 패션 (category: 1)
    {
      'name': '나이키 에어맥스 97 실버불릿',
      'location': '스포츠웨어',
      'originalPrice': 199000,
      'price': 159000,
      'discount': 20,
      'rating': 4.9,
      'reviews': 3421,
      'tag': 'HOT',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop',
      'category': 1,
    },
    {
      'name': '구찌 마몽 벨트백',
      'location': '명품가방',
      'originalPrice': 1850000,
      'price': 1650000,
      'discount': 11,
      'rating': 4.8,
      'reviews': 892,
      'tag': 'PREMIUM',
      'image': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&h=300&fit=crop',
      'category': 1,
    },
    {
      'name': '캐나다구스 익스페디션 파카',
      'location': '아우터',
      'originalPrice': 1890000,
      'price': 1590000,
      'discount': 16,
      'rating': 4.7,
      'reviews': 567,
      'tag': 'BEST',
      'image': 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400&h=300&fit=crop',
      'category': 1,
    },
    // 전자기기 (category: 2)
    {
      'name': '애플 맥북 프로 14인치 M3 Pro',
      'location': '노트북',
      'originalPrice': 2990000,
      'price': 2690000,
      'discount': 10,
      'rating': 4.9,
      'reviews': 2341,
      'tag': 'NEW',
      'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&h=300&fit=crop',
      'category': 2,
    },
    {
      'name': '소니 WH-1000XM5 헤드폰',
      'location': '오디오',
      'originalPrice': 499000,
      'price': 399000,
      'discount': 20,
      'rating': 4.8,
      'reviews': 4521,
      'tag': 'HOT',
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=300&fit=crop',
      'category': 2,
    },
    {
      'name': '삼성 갤럭시 Z 폴드6',
      'location': '스마트폰',
      'originalPrice': 2099000,
      'price': 1899000,
      'discount': 10,
      'rating': 4.7,
      'reviews': 1876,
      'tag': 'BEST',
      'image': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=300&fit=crop',
      'category': 2,
    },
    // 상품권 (category: 3)
    {
      'name': '신세계 상품권 50만원권',
      'location': '백화점',
      'originalPrice': 500000,
      'price': 475000,
      'discount': 5,
      'rating': 5.0,
      'reviews': 8923,
      'tag': 'BEST',
      'image': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=300&fit=crop',
      'category': 3,
    },
    {
      'name': '스타벅스 e-기프트카드 10만원',
      'location': '카페',
      'originalPrice': 100000,
      'price': 95000,
      'discount': 5,
      'rating': 4.9,
      'reviews': 12456,
      'tag': 'HOT',
      'image': 'https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=400&h=300&fit=crop',
      'category': 3,
    },
    // 맛집 (category: 4)
    {
      'name': '정식당 런치코스 2인',
      'location': '서울 강남',
      'originalPrice': 320000,
      'price': 280000,
      'discount': 13,
      'rating': 4.9,
      'reviews': 1234,
      'tag': 'PREMIUM',
      'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&h=300&fit=crop',
      'category': 4,
    },
    {
      'name': '오마카세 스시 12피스 코스',
      'location': '서울 청담',
      'originalPrice': 250000,
      'price': 220000,
      'discount': 12,
      'rating': 4.8,
      'reviews': 876,
      'tag': 'BEST',
      'image': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&h=300&fit=crop',
      'category': 4,
    },
    // 레저 (category: 5)
    {
      'name': '에버랜드 연간 이용권',
      'location': '경기도 용인',
      'originalPrice': 280000,
      'price': 220000,
      'discount': 21,
      'rating': 4.7,
      'reviews': 5623,
      'tag': 'HOT',
      'image': 'https://images.unsplash.com/photo-1513889961551-628c1e5e2ee9?w=400&h=300&fit=crop',
      'category': 5,
    },
    {
      'name': '제주 스쿠버다이빙 체험',
      'location': '제주도',
      'originalPrice': 150000,
      'price': 120000,
      'discount': 20,
      'rating': 4.9,
      'reviews': 2341,
      'tag': 'NEW',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop',
      'category': 5,
    },
  ];

  /// 선택된 카테고리에 따라 필터링된 상품 리스트 반환
  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts
        .where((product) => product['category'] == _selectedCategoryIndex)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 앱바
            SliverToBoxAdapter(
              child: CommonAppBar(
                title: 'Shopping',
                trailing: NotificationButton(
                  hasNotification: true,
                  onTap: () => context.push('/notifications'),
                ),
              ),
            ),

            // 검색바
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),

            // 카테고리
            SliverToBoxAdapter(
              child: _buildCategories(),
            ),

            // 프로모션 배너
            SliverToBoxAdapter(
              child: _buildPromoBanner(),
            ),

            // 섹션 헤더
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                _getSectionTitle(),
                _getSectionSubtitle(),
              ),
            ),

            // 상품 그리드
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: _filteredProducts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: AppColors.gray300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '해당 카테고리에 상품이 없습니다',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildProductCard(_filteredProducts[index], index),
                        childCount: _filteredProducts.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: () {
          // 검색 화면으로 이동 (추후 구현 시 /search로 변경)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('검색 기능 준비 중입니다'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 22,
                color: AppColors.gray400,
              ),
              const SizedBox(width: 12),
              Text(
                '여행지, 호텔, 상품 검색',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_categories.length, (index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.darkBlue.withValues(alpha: 0.1)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    size: 24,
                    color: isSelected ? AppColors.darkBlue : AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.darkBlue : AppColors.gray600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue,
            AppColors.darkBlue.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '첫 구매 혜택',
                    style: AppTextStyles.caption2.copyWith(color: AppColors.white),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '신규 회원 최대\n50% 할인',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1월 31일까지',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              size: 40,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리별 섹션 타이틀
  String _getSectionTitle() {
    switch (_selectedCategoryIndex) {
      case 0:
        return '추천 호텔 상품';
      case 1:
        return '인기 패션 아이템';
      case 2:
        return '최신 전자기기';
      case 3:
        return '인기 상품권';
      case 4:
        return '맛집 추천';
      case 5:
        return '레저 & 체험';
      default:
        return '추천 상품';
    }
  }

  /// 카테고리별 서브타이틀
  String _getSectionSubtitle() {
    switch (_selectedCategoryIndex) {
      case 0:
        return '엄선된 리조트 & 호텔';
      case 1:
        return '트렌디한 패션 컬렉션';
      case 2:
        return '최고의 테크 제품';
      case 3:
        return '다양한 상품권 혜택';
      case 4:
        return '검증된 맛집 리스트';
      case 5:
        return '특별한 경험을 선물하세요';
      default:
        return '다양한 상품을 만나보세요';
    }
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.luggage_rounded,
              size: 18,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlue,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.body4.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    final tag = product['tag'] as String?;
    final imageUrl = product['image'] as String?;
    final isFavorite = _favorites.contains(index);

    return GestureDetector(
      onTap: () {
        // 상품 상세 페이지로 이동 (추후 구현 시 /product/{id}로 변경)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name']}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 영역
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // 네트워크 이미지
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: AppColors.gray400,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_rounded,
                                size: 40,
                                color: AppColors.gray300,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 40,
                            color: AppColors.gray300,
                          ),
                        ),
                ),
                // 태그
                if (tag != null)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTagColor(tag),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: _getTagColor(tag).withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                // 찜하기
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isFavorite) {
                          _favorites.remove(index);
                        } else {
                          _favorites.add(index);
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isFavorite ? '찜 목록에서 제거했습니다' : '찜 목록에 추가했습니다'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavorite ? AppColors.red : AppColors.gray500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 콘텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 위치
                  Text(
                    product['location'] as String,
                    style: AppTextStyles.caption4.copyWith(color: AppColors.gray500),
                  ),
                  SizedBox(height: 4),
                  // 상품명
                  Text(
                    product['name'] as String,
                    style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 평점
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${product['rating']}',
                        style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                      ),
                      Text(
                        ' (${_formatReviews(product['reviews'] as int)})',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  // 가격
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${product['discount']}%',
                          style: AppTextStyles.caption3.copyWith(color: AppColors.red),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatPrice(product['price'] as int)}원',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'HOT':
        return AppColors.red;
      case 'BEST':
        return AppColors.blue;
      case 'NEW':
        return AppColors.green500;
      case 'PREMIUM':
        return AppColors.darkBlue;
      default:
        return AppColors.gray500;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatReviews(int reviews) {
    if (reviews >= 1000) {
      return '${(reviews / 1000).toStringAsFixed(1)}k';
    }
    return reviews.toString();
  }
}
