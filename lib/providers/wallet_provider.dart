import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_wallet_model.dart';
import '../models/user_profile_model.dart';
import '../models/transaction_model.dart';
import '../core/auth/domain/providers/auth_provider.dart';

/// 사용자 프로필 Provider (실제 인증 데이터 기반)
final userProfileProvider = Provider<UserProfile?>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.valueOrNull?.user;

  if (user == null) return null;

  return UserProfile(
    userId: user.id ?? '',
    nickname: user.nickname ?? '사용자',
    email: user.email,
    profileImageUrl: user.profileImageUrl,
    tier: UserTier.bronze, // TODO: 백엔드에서 tier 정보 추가 필요
    createdAt: DateTime.now(), // TODO: createdAt 백엔드에서 제공 필요
    updatedAt: DateTime.now(),
  );
});

/// 사용자 지갑 Provider (GraphQL 스키마 User 필드 기반)
final userWalletProvider = Provider<UserWallet?>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.valueOrNull?.user;

  if (user == null) return null;

  final shoppingCash = user.shoppingCash.toInt();
  final eventCash = user.eventPoint.toInt();
  final participationPoint = user.participationPoint.toInt();
  final totalBalance = shoppingCash + eventCash + participationPoint;

  return UserWallet(
    userId: user.id ?? '',
    fundingCash: 0,
    eventCash: eventCash,
    shoppingCash: shoppingCash,
    totalEventCashUsed: 0, // TODO: 백엔드 데이터 필요
    totalShoppingCashUsed: 0, // TODO: 백엔드 데이터 필요
    totalDeposit: totalBalance, // TODO: 실제 총 입금액 백엔드 데이터 필요
    totalRefund: 0, // TODO: 백엔드 데이터 필요
    totalGameReward: 0, // TODO: 백엔드 데이터 필요
    updatedAt: DateTime.now(),
  );
});

/// 거래 내역 Provider
final transactionListProvider = StateProvider<List<Transaction>>((ref) {
  // TODO: 실제로는 GraphQL로 데이터 가져오기
  // 임시 Mock 데이터
  final now = DateTime.now();

  return [
    Transaction(
      id: 'txn-001',
      userId: 'user-001',
      type: TransactionType.gameEntry,
      amount: 3000,
      description: '블록픽 게임 #1234 참가',
      metadata: {'gameId': '1234'},
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    Transaction(
      id: 'txn-002',
      userId: 'user-001',
      type: TransactionType.deposit,
      amount: 10000,
      description: 'Stripe 결제',
      metadata: {'paymentMethod': 'stripe'},
      createdAt: now.subtract(const Duration(hours: 6)),
    ),
    Transaction(
      id: 'txn-003',
      userId: 'user-001',
      type: TransactionType.gameReward,
      amount: 5000,
      description: '블록픽 #1230 - 2위',
      metadata: {'gameId': '1230', 'rank': 2},
      createdAt: now.subtract(const Duration(days: 1, hours: 5)),
    ),
    Transaction(
      id: 'txn-004',
      userId: 'user-001',
      type: TransactionType.shoppingPurchase,
      amount: 15000,
      description: '블록픽 굿즈 세트 구매',
      metadata: {'orderId': '5678'},
      createdAt: now.subtract(const Duration(days: 2, hours: 7)),
    ),
    Transaction(
      id: 'txn-005',
      userId: 'user-001',
      type: TransactionType.refund,
      amount: 10000,
      description: '환불 승인',
      metadata: {},
      createdAt: now.subtract(const Duration(days: 3, hours: 14)),
    ),
  ];
});

/// 최근 거래 내역 (최대 5개)
final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  return transactions.take(5).toList();
});
