import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_wallet_model.dart';
import '../models/user_profile_model.dart';
import '../models/transaction_model.dart';

/// 사용자 프로필 Provider
final userProfileProvider = StateProvider<UserProfile?>((ref) {
  // TODO: 실제로는 GraphQL로 데이터 가져오기
  // 임시 Mock 데이터
  return UserProfile(
    userId: 'user-001',
    nickname: '홍길동',
    email: 'user@blockpick.com',
    profileImageUrl: null,
    tier: UserTier.gold,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  );
});

/// 사용자 지갑 Provider
final userWalletProvider = StateProvider<UserWallet?>((ref) {
  // TODO: 실제로는 GraphQL로 데이터 가져오기
  // 임시 Mock 데이터
  return UserWallet(
    userId: 'user-001',
    fundingCash: 10000,
    eventCash: 8000,
    shoppingCash: 10000,
    totalEventCashUsed: 0,
    totalShoppingCashUsed: 0,
    totalDeposit: 20000,
    totalRefund: 0,
    totalGameReward: 5000,
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
