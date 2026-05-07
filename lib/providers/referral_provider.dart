import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/referral/referral_models.dart';
import '../data/referral/referral_remote_datasource.dart';

/// ReferralRemoteDataSource provider — 인증 필요
final referralRemoteDataSourceProvider =
    FutureProvider<ReferralRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return ReferralRemoteDataSource(client);
});

/// 내 초대 코드 정보
final myInviteCodeProvider =
    FutureProvider.autoDispose<MyInviteCodeInfo>((ref) async {
  final ds = await ref.watch(referralRemoteDataSourceProvider.future);
  return ds.fetchMyInviteCode();
});

/// 내 추천 내역
final myReferralsProvider =
    FutureProvider.autoDispose<List<Referral>>((ref) async {
  final ds = await ref.watch(referralRemoteDataSourceProvider.future);
  return ds.fetchMyReferrals();
});
