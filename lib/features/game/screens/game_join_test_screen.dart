import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/game_join_button.dart';
import '../widgets/game_join_loading_overlay.dart';
import '../widgets/game_join_result_overlay.dart';
import '../../../providers/game_participation_provider.dart';

/// 게임 참가 기능 E2E 테스트 화면
///
/// 실제 블록체인 연동 및 GraphQL Mutation을 테스트합니다.
class GameJoinTestScreen extends ConsumerStatefulWidget {
  const GameJoinTestScreen({super.key});

  @override
  ConsumerState<GameJoinTestScreen> createState() => _GameJoinTestScreenState();
}

class _GameJoinTestScreenState extends ConsumerState<GameJoinTestScreen> {
  // 테스트용 기본값
  final TextEditingController _gameIdController = TextEditingController(
    text: '01a18547-64cc-4e9e-9816-3161f0278018', // 실제 게임 ID
  );
  final TextEditingController _productIdController = TextEditingController(
    text: 'product-1', // 테스트용
  );
  final TextEditingController _rowController = TextEditingController(
    text: '771',
  );
  final TextEditingController _colController = TextEditingController(
    text: '968',
  );
  final TextEditingController _contractController = TextEditingController(
    text: '0x63d469d7eE4d04634BB87Fa95C639431E1814af7', // 실제 컨트랙트 주소
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _gameIdController.dispose();
    _productIdController.dispose();
    _rowController.dispose();
    _colController.dispose();
    _contractController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 게임 참가 E2E 테스트'),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 안내 카드
            _buildInfoCard(),

            const SizedBox(height: 24),

            // 입력 필드들
            _buildTextField(
              controller: _gameIdController,
              label: '게임 ID',
              hint: '01a18547-64cc-4e9e-9816-3161f0278018',
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _productIdController,
              label: '상품 ID',
              hint: 'product-1',
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _rowController,
                    label: '행 (Row)',
                    hint: '0-999',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _colController,
                    label: '열 (Column)',
                    hint: '0-999',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _contractController,
              label: '컨트랙트 주소',
              hint: '0x...',
            ),

            const SizedBox(height: 32),

            // 테스트 버튼들
            _buildTestButton1(),

            const SizedBox(height: 16),

            _buildTestButton2(),

            const SizedBox(height: 16),

            _buildTestButton3(),

            const SizedBox(height: 32),

            // 지갑 정보
            _buildWalletInfo(),

            const SizedBox(height: 16),

            // 네트워크 상태
            _buildNetworkStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue.withOpacity(0.1),
            AppColors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: AppColors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                'E2E 테스트',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '실제 블록체인 트랜잭션을 전송하고 게임에 참가합니다.\n'
            '콘솔 로그를 확인하세요!',
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Polygon Amoy Testnet 사용 (테스트넷)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange.shade800,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestButton1() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleTest1,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow),
          const SizedBox(width: 8),
          Text(
            '테스트 1: 기본 UI 버튼',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton2() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleTest2,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.animation),
          const SizedBox(width: 8),
          Text(
            '테스트 2: 토스 스타일 애니메이션',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton3() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleTest3,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.code),
          const SizedBox(width: 8),
          Text(
            '테스트 3: Provider 직접 호출',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfo() {
    final walletAddress = ref.watch(userWalletAddressProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppColors.blue),
                const SizedBox(width: 8),
                Text(
                  '지갑 정보',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            walletAddress.when(
              data: (address) {
                if (address == null) {
                  return Text(
                    '지갑 없음 (자동 생성됨)',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.gray500,
                    ),
                  );
                }
                return SelectableText(
                  address,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.gray900,
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('에러: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatus() {
    final canJoin = ref.watch(canJoinGameProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wifi, color: AppColors.green),
                const SizedBox(width: 8),
                Text(
                  '네트워크 상태',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            canJoin.when(
              data: (can) => Row(
                children: [
                  Icon(
                    can ? Icons.check_circle : Icons.error,
                    color: can ? AppColors.green : AppColors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    can ? 'Polygon Amoy 연결됨' : '연결 실패',
                    style: AppTextStyles.body.copyWith(
                      color: can ? AppColors.green : AppColors.red,
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('에러: $e'),
            ),
          ],
        ),
      ),
    );
  }

  // 테스트 1: 기본 UI 버튼
  Future<void> _handleTest1() async {
    final gameId = _gameIdController.text;
    final productId = _productIdController.text;
    final row = int.tryParse(_rowController.text);
    final col = int.tryParse(_colController.text);
    final contract = _contractController.text;

    if (row == null || col == null) {
      _showError('좌표를 올바르게 입력하세요');
      return;
    }

    print('\n🧪 [테스트 1] 기본 UI 버튼 테스트 시작');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GameJoinButton(
          gameId: gameId,
          selectedGameProductId: productId,
          selectedRow: row,
          selectedCol: col,
          contractAddress: contract,
          onSuccess: () {
            print('✅ [테스트 1] 성공 콜백 실행됨');
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  // 테스트 2: 토스 스타일 애니메이션
  Future<void> _handleTest2() async {
    final gameId = _gameIdController.text;
    final productId = _productIdController.text;
    final row = int.tryParse(_rowController.text);
    final col = int.tryParse(_colController.text);
    final contract = _contractController.text;

    if (row == null || col == null) {
      _showError('좌표를 올바르게 입력하세요');
      return;
    }

    print('\n🧪 [테스트 2] 토스 스타일 애니메이션 테스트 시작');

    setState(() => _isLoading = true);

    try {
      // 1. 로딩 오버레이 표시
      GameJoinLoadingOverlay.show(context);

      // 2. 게임 참가
      final result = await ref
          .read(gameParticipationProvider.notifier)
          .joinGame(
            gameId: gameId,
            selectedGameProductId: productId,
            row: row,
            col: col,
            contractAddress: contract,
          );

      // 3. 로딩 숨김
      if (mounted) {
        GameJoinLoadingOverlay.hide(context);
        await Future.delayed(const Duration(milliseconds: 300));

        // 4. 결과 표시
        if (result.success) {
          GameJoinResultOverlay.showSuccess(
            context,
            entryId: result.entryId,
            txHash: result.txHash,
            onConfirm: () {
              print('✅ [테스트 2] 성공!');
            },
          );
        } else {
          GameJoinResultOverlay.showError(
            context,
            errorMessage: result.message,
            onRetry: () {
              _handleTest2();
            },
          );
        }
      }
    } catch (e) {
      print('❌ [테스트 2] 에러: $e');
      if (mounted) {
        GameJoinLoadingOverlay.hide(context);
        await Future.delayed(const Duration(milliseconds: 300));
        GameJoinResultOverlay.showError(
          context,
          errorMessage: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 테스트 3: Provider 직접 호출
  Future<void> _handleTest3() async {
    final gameId = _gameIdController.text;
    final productId = _productIdController.text;
    final row = int.tryParse(_rowController.text);
    final col = int.tryParse(_colController.text);
    final contract = _contractController.text;

    if (row == null || col == null) {
      _showError('좌표를 올바르게 입력하세요');
      return;
    }

    print('\n🧪 [테스트 3] Provider 직접 호출 테스트 시작');

    setState(() => _isLoading = true);

    try {
      final result = await ref
          .read(gameParticipationProvider.notifier)
          .joinGame(
            gameId: gameId,
            selectedGameProductId: productId,
            row: row,
            col: col,
            contractAddress: contract,
          );

      if (mounted) {
        if (result.success) {
          _showSuccess('성공! Entry ID: ${result.entryId}');
        } else {
          _showError('실패: ${result.message}');
        }
      }
    } catch (e) {
      print('❌ [테스트 3] 에러: $e');
      if (mounted) {
        _showError('에러: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
      ),
    );
  }
}
