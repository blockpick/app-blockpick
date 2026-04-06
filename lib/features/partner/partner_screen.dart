import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'partner_detail_screen.dart';
import '../../core/constants/app_constants.dart';

/// 파트너 이벤트 목록 화면
/// 시안 기반: 상단 배너 + 카테고리 탭 + 2열 그리드
class PartnerScreen extends ConsumerStatefulWidget {
  const PartnerScreen({super.key});

  @override
  ConsumerState<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends ConsumerState<PartnerScreen> {
  List<Map<String, dynamic>> _games = [];
  bool _isLoading = true;
  String? _error;
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': '전체', 'icon': Icons.apps_rounded},
    {'label': '가전', 'icon': Icons.devices_rounded},
    {'label': '패션', 'icon': Icons.checkroom_rounded},
    {'label': '여행', 'icon': Icons.flight_rounded},
    {'label': '맛집', 'icon': Icons.restaurant_rounded},
    {'label': '기프트카드', 'icon': Icons.card_giftcard_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 인증 불필요 - 직접 HTTP 호출
      const endpoint = 'https://api-dev.blockpick.net/graphql';
      const query = '''
        query GetGames {
          getGames {
            success
            games {
              id
              title
              description
              mainProductName
              type
              gameType
              category
              status
              hasInstantPrize
              maxEntries
              maxEntriesPerUser
              entryFee
              startTime
              endTime
              gameProducts {
                product {
                  name
                  brand
                  defaultImage
                  price
                }
              }
            }
          }
        }
      ''';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode != 200) {
        debugPrint('[Partner] HTTP 에러: ${response.statusCode}');
        setState(() {
          _error = '게임 목록을 불러올 수 없습니다';
          _isLoading = false;
        });
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final games = (data['data']?['getGames']?['games'] as List? ?? [])
          .where((g) =>
              (g['status'] == 'IN_PROGRESS' || g['status'] == 'SCHEDULED') &&
              (g['gameType'] == 'PARTNER_GACHA' || g['type'] == 'PARTNER_GACHA'))
          .toList();

      setState(() {
        _games = List<Map<String, dynamic>>.from(games);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[Partner] 예외: $e');
      setState(() {
        _error = '네트워크 오류가 발생했습니다';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredGames {
    if (_selectedCategory == 0) return _games;
    final categoryLabel = _categories[_selectedCategory]['label'] as String;
    return _games.where((g) {
      final category = g['category'] as String? ?? '';
      return category == categoryLabel;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
                ),
              )
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadGames,
                    child: CustomScrollView(
                      slivers: [
                        // 헤더
                        SliverToBoxAdapter(child: _buildHeader()),
                        // 배너
                        SliverToBoxAdapter(child: _buildBanner()),
                        // 카테고리 탭
                        SliverToBoxAdapter(child: _buildCategoryTabs()),
                        // 게임 그리드
                        _filteredGames.isEmpty
                            ? SliverToBoxAdapter(child: _buildEmpty())
                            : _buildGameGrid(),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '파트너 이벤트',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share_outlined, color: AppColors.gray500, size: 22),
          ),
        ],
      ),
    );
  }

  /// 상단 프로모션 배너
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryMain, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        children: [
          // 편의점 로고들
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStoreLogo('CU', const Color(0xFF00A651)),
                    const SizedBox(width: 6),
                    _buildStoreLogo('GS25', const Color(0xFF0066B3)),
                    const SizedBox(width: 6),
                    _buildStoreLogo('7', const Color(0xFFE30613)),
                    const SizedBox(width: 6),
                    _buildStoreLogo('E', const Color(0xFFF5A623)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '4대 편의점 사용 가능!\n모바일상품권 10000원 획득하기',
                  style: AppTextStyles.title3.copyWith(color: AppColors.white),
                ),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  ),
                  child: Text(
                    '이벤트 참여하면 +1000P',
                    style: AppTextStyles.caption4.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreLogo(String text, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: text.length > 2 ? 8 : 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }

  /// 카테고리 탭
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryMain.withValues(alpha: 0.1)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    border: isSelected
                        ? Border.all(color: AppColors.primaryMain, width: 1.5)
                        : null,
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    size: 22,
                    color: isSelected
                        ? AppColors.primaryMain
                        : AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryMain
                        : AppColors.gray500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 2열 게임 그리드
  Widget _buildGameGrid() {
    final games = _filteredGames;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final game = games[index];
            return _GameGridCard(
              game: game,
              onTap: () => _openGameDetail(game),
            );
          },
          childCount: games.length,
        ),
      ),
    );
  }

  void _openGameDetail(Map<String, dynamic> game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PartnerDetailScreen(game: game),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.gray300),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(fontSize: 14, color: AppColors.gray500)),
          const SizedBox(height: 12),
          TextButton(onPressed: _loadGames, child: const Text('다시 시도')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.card_giftcard_outlined, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text(
              '진행중인 이벤트가 없습니다',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2열 그리드용 게임 카드
class _GameGridCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final VoidCallback onTap;

  const _GameGridCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final product = (game['gameProducts'] as List?)?.isNotEmpty == true
        ? (game['gameProducts'] as List).first['product'] as Map<String, dynamic>?
        : null;
    final imageUrl = product?['defaultImage'] as String?;
    final productName = product?['name'] as String? ??
        game['mainProductName'] as String? ?? '';
    final brand = product?['brand'] as String? ?? '';

    // 남은 시간 표시
    final endTime = game['endTime'] as String?;
    String timeLeft = '';
    if (endTime != null) {
      try {
        final end = DateTime.parse(endTime);
        final diff = end.difference(DateTime.now());
        if (diff.isNegative) {
          timeLeft = '마감';
        } else {
          final h = diff.inHours.toString().padLeft(2, '0');
          final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
          final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
          timeLeft = '$h:$m:$s 남음';
        }
      } catch (_) {}
    }

    // 포인트
    final entryFee = game['entryFee'] as int? ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.gray200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            AspectRatio(
              aspectRatio: 1.1,
              child: Container(
                color: AppColors.gray100,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.image_outlined, size: 40, color: AppColors.gray300),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.card_giftcard, size: 40, color: AppColors.gray300),
                      ),
              ),
            ),
            // 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품명
                    Text(
                      productName.isNotEmpty ? productName : (game['title'] as String? ?? ''),
                      style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // 시간 + 포인트
                    if (timeLeft.isNotEmpty)
                      Text(
                        timeLeft,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.gray400,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      entryFee == 0 ? '무료' : '+${entryFee}P',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMain,
                      ),
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
}
