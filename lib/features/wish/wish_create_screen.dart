import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wish_model.dart';
import '../../providers/wish_provider.dart';
import 'steps/wish_step_url.dart';
import 'steps/wish_step_info.dart';
import 'steps/wish_step_oneliner.dart';
import 'steps/wish_step_category.dart';
import 'steps/wish_step_preview.dart';
import 'wish_create_complete_screen.dart';

/// 소원 등록 화면 (5단계 스텝 컨테이너)
class WishCreateScreen extends ConsumerStatefulWidget {
  const WishCreateScreen({super.key});

  @override
  ConsumerState<WishCreateScreen> createState() => _WishCreateScreenState();
}

class _WishCreateScreenState extends ConsumerState<WishCreateScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 폼 데이터
  String _purchaseUrl = '';
  String _productName = '';
  int _productPrice = 0;
  String? _productImageUrl;
  String _oneLiner = '';
  WishCategory? _category;
  String _storeName = '';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _goToStep(_currentStep + 1);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    final notifier = ref.read(wishCreateProvider.notifier);
    notifier.purchaseUrl = _purchaseUrl;
    notifier.productName = _productName;
    notifier.productPrice = _productPrice;
    notifier.productImageUrl = _productImageUrl;
    notifier.oneLiner = _oneLiner;
    notifier.category = _category;

    try {
      final wish = await notifier.createWish();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WishCreateCompleteScreen(wish: wish),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _prevStep();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _prevStep,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textBlack),
          ),
          title: Text(
            '소원 등록 (${_currentStep + 1}/5)',
            style: AppTextStyles.title2,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 프로그레스 바
            _buildProgressBar(),
            // 스텝 페이지
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WishStepUrl(
                    initialUrl: _purchaseUrl,
                    onNext: (url, parsedName, parsedPrice, parsedImage, storeName) {
                      setState(() {
                        _purchaseUrl = url;
                        if (parsedName != null) _productName = parsedName;
                        if (parsedPrice != null) _productPrice = parsedPrice;
                        _productImageUrl = parsedImage;
                        _storeName = storeName ?? '';
                      });
                      _nextStep();
                    },
                  ),
                  WishStepInfo(
                    productName: _productName,
                    productPrice: _productPrice,
                    productImageUrl: _productImageUrl,
                    storeName: _storeName,
                    onNext: (name, price, imageUrl) {
                      setState(() {
                        _productName = name;
                        _productPrice = price;
                        _productImageUrl = imageUrl;
                      });
                      _nextStep();
                    },
                  ),
                  WishStepOneliner(
                    initialText: _oneLiner,
                    onNext: (text) {
                      setState(() => _oneLiner = text);
                      _nextStep();
                    },
                  ),
                  WishStepCategory(
                    selected: _category,
                    onNext: (cat) {
                      setState(() => _category = cat);
                      _nextStep();
                    },
                  ),
                  WishStepPreview(
                    productName: _productName,
                    productPrice: _productPrice,
                    productImageUrl: _productImageUrl,
                    oneLiner: _oneLiner,
                    category: _category,
                    purchaseUrl: _purchaseUrl,
                    onSubmit: _submit,
                    onEdit: () => _goToStep(0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= _currentStep ? AppColors.primary : AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
