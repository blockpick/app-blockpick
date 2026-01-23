import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admob_service.dart';

/// 광고 컨텍스트 타입
enum AdContextType {
  /// 출석 2배 보상 (1일 1회)
  attendanceBoost,
  /// 트랜잭션 대기 중 고보상 (무제한)
  txWaitBoost,
  /// 게임 결과 후 회복 보상 (무제한)
  postResultBoost,
  /// 홈 화면 일일 보상 (1일 5회)
  homeDaily,
}

extension AdContextTypeExtension on AdContextType {
  String get value {
    switch (this) {
      case AdContextType.attendanceBoost:
        return 'ATTENDANCE_BOOST';
      case AdContextType.txWaitBoost:
        return 'TX_WAIT_BOOST';
      case AdContextType.postResultBoost:
        return 'POST_RESULT_BOOST';
      case AdContextType.homeDaily:
        return 'HOME_DAILY';
    }
  }
}

/// 광고 세션 상태
enum AdRewardStatus {
  initiated,
  verificationPending,
  verified,
  granted,
  rejected,
  expired,
}

/// 광고 보상 세션 정보
class AdRewardSession {
  final String rewardSessionId;
  final String verificationToken;
  final int rewardPreviewAmount;
  final DateTime expiresAt;
  final AdRewardStatus status;

  AdRewardSession({
    required this.rewardSessionId,
    required this.verificationToken,
    required this.rewardPreviewAmount,
    required this.expiresAt,
    required this.status,
  });

  factory AdRewardSession.fromJson(Map<String, dynamic> json) {
    return AdRewardSession(
      rewardSessionId: json['rewardSessionId'] as String,
      verificationToken: json['verificationToken'] as String,
      rewardPreviewAmount: json['rewardPreviewAmount'] as int,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: AdRewardStatus.initiated,
    );
  }
}

/// 광고 보상 결과
class AdRewardResult {
  final AdRewardStatus status;
  final int grantedAmount;
  final String? reasonCode;
  final WalletSnapshot? walletSnapshot;

  AdRewardResult({
    required this.status,
    required this.grantedAmount,
    this.reasonCode,
    this.walletSnapshot,
  });

  factory AdRewardResult.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String;
    final status = switch (statusStr) {
      'INITIATED' => AdRewardStatus.initiated,
      'VERIFICATION_PENDING' => AdRewardStatus.verificationPending,
      'VERIFIED' => AdRewardStatus.verified,
      'GRANTED' => AdRewardStatus.granted,
      'REJECTED' => AdRewardStatus.rejected,
      'EXPIRED' => AdRewardStatus.expired,
      _ => AdRewardStatus.initiated,
    };

    return AdRewardResult(
      status: status,
      grantedAmount: json['grantedAmount'] as int? ?? 0,
      reasonCode: json['reasonCode'] as String?,
      walletSnapshot: json['walletSnapshot'] != null
          ? WalletSnapshot.fromJson(json['walletSnapshot'])
          : null,
    );
  }

  bool get isSuccess => status == AdRewardStatus.granted;
}

/// 지갑 스냅샷
class WalletSnapshot {
  final String userId;
  final int shoppingCash;
  final int eventPoint;
  final int participationPoint;

  WalletSnapshot({
    required this.userId,
    required this.shoppingCash,
    required this.eventPoint,
    required this.participationPoint,
  });

  factory WalletSnapshot.fromJson(Map<String, dynamic> json) {
    return WalletSnapshot(
      userId: json['userId'] as String,
      shoppingCash: (json['shoppingCash'] as num?)?.toInt() ?? 0,
      eventPoint: (json['eventPoint'] as num?)?.toInt() ?? 0,
      participationPoint: (json['participationPoint'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 광고 보상 정책
class AdRewardPolicy {
  final String? id;
  final AdContextType contextType;
  final String? provider;
  final bool enabled;
  final double baseRewardAmount;
  final double bonusRewardAmount;
  final double multiplier;
  final int dailyLimit;
  final int cooldownSeconds;
  final int perGameLimit;
  final int perEntryLimit;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;

  AdRewardPolicy({
    this.id,
    required this.contextType,
    this.provider,
    required this.enabled,
    required this.baseRewardAmount,
    required this.bonusRewardAmount,
    required this.multiplier,
    required this.dailyLimit,
    required this.cooldownSeconds,
    required this.perGameLimit,
    required this.perEntryLimit,
    this.effectiveFrom,
    this.effectiveTo,
  });

  factory AdRewardPolicy.fromJson(Map<String, dynamic> json) {
    final contextTypeStr = json['contextType'] as String;
    final contextType = switch (contextTypeStr) {
      'ATTENDANCE_BOOST' => AdContextType.attendanceBoost,
      'TX_WAIT_BOOST' => AdContextType.txWaitBoost,
      'POST_RESULT_BOOST' => AdContextType.postResultBoost,
      'HOME_DAILY' => AdContextType.homeDaily,
      _ => AdContextType.homeDaily,
    };

    return AdRewardPolicy(
      id: json['id'] as String?,
      contextType: contextType,
      provider: json['provider'] as String?,
      enabled: json['enabled'] as bool? ?? false,
      baseRewardAmount: (json['baseRewardAmount'] as num?)?.toDouble() ?? 0,
      bonusRewardAmount: (json['bonusRewardAmount'] as num?)?.toDouble() ?? 0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1,
      dailyLimit: (json['dailyLimit'] as num?)?.toInt() ?? 0,
      cooldownSeconds: (json['cooldownSeconds'] as num?)?.toInt() ?? 0,
      perGameLimit: (json['perGameLimit'] as num?)?.toInt() ?? 0,
      perEntryLimit: (json['perEntryLimit'] as num?)?.toInt() ?? 0,
      effectiveFrom: json['effectiveFrom'] != null
          ? DateTime.tryParse(json['effectiveFrom'] as String)
          : null,
      effectiveTo: json['effectiveTo'] != null
          ? DateTime.tryParse(json['effectiveTo'] as String)
          : null,
    );
  }

  /// 총 보상 금액 (기본 + 보너스) * 배수
  double get totalRewardAmount => (baseRewardAmount + bonusRewardAmount) * multiplier;

  /// 정책이 현재 유효한지 확인
  bool get isCurrentlyEffective {
    if (!enabled) return false;
    final now = DateTime.now();
    if (effectiveFrom != null && now.isBefore(effectiveFrom!)) return false;
    if (effectiveTo != null && now.isAfter(effectiveTo!)) return false;
    return true;
  }
}

/// 광고 보상 실패 사유 코드
enum AdRewardReasonCode {
  limitDaily,
  limitEntry,
  limitGame,
  limitCooldown,
  tokenInvalid,
  sessionExpired,
  providerVerificationFailed,
  policyDisabled,
  policyPeriodInvalid,
  duplicateRequest,
  invalidStatus,
}

extension AdRewardReasonCodeExtension on AdRewardReasonCode {
  static AdRewardReasonCode? fromString(String? value) {
    if (value == null) return null;
    return switch (value) {
      'LIMIT_DAILY' => AdRewardReasonCode.limitDaily,
      'LIMIT_ENTRY' => AdRewardReasonCode.limitEntry,
      'LIMIT_GAME' => AdRewardReasonCode.limitGame,
      'LIMIT_COOLDOWN' => AdRewardReasonCode.limitCooldown,
      'TOKEN_INVALID' => AdRewardReasonCode.tokenInvalid,
      'SESSION_EXPIRED' => AdRewardReasonCode.sessionExpired,
      'PROVIDER_VERIFICATION_FAILED' => AdRewardReasonCode.providerVerificationFailed,
      'POLICY_DISABLED' => AdRewardReasonCode.policyDisabled,
      'POLICY_PERIOD_INVALID' => AdRewardReasonCode.policyPeriodInvalid,
      'DUPLICATE_REQUEST' => AdRewardReasonCode.duplicateRequest,
      'INVALID_STATUS' => AdRewardReasonCode.invalidStatus,
      _ => null,
    };
  }

  String get displayMessage {
    return switch (this) {
      AdRewardReasonCode.limitDaily => '오늘 일일 보상 횟수를 모두 사용했습니다.',
      AdRewardReasonCode.limitEntry => '해당 참여에 대한 보상 횟수를 초과했습니다.',
      AdRewardReasonCode.limitGame => '해당 게임에 대한 보상 횟수를 초과했습니다.',
      AdRewardReasonCode.limitCooldown => '잠시 후 다시 시도해주세요.',
      AdRewardReasonCode.tokenInvalid => '인증에 실패했습니다. 다시 시도해주세요.',
      AdRewardReasonCode.sessionExpired => '세션이 만료되었습니다. 다시 시도해주세요.',
      AdRewardReasonCode.providerVerificationFailed => '광고 검증에 실패했습니다.',
      AdRewardReasonCode.policyDisabled => '현재 보상이 비활성화되어 있습니다.',
      AdRewardReasonCode.policyPeriodInvalid => '보상 기간이 아닙니다.',
      AdRewardReasonCode.duplicateRequest => '이미 처리된 요청입니다.',
      AdRewardReasonCode.invalidStatus => '잘못된 요청입니다.',
    };
  }
}

/// 광고 보상 원장 (기록)
class AdRewardLedger {
  final String? id;
  final String userId;
  final AdContextType contextType;
  final String? provider;
  final String? adUnitId;
  final double rewardAmount;
  final AdRewardStatus status;
  final String idempotencyKey;
  final String? gameId;
  final String? entryId;
  final String? txHash;
  final AdRewardReasonCode? reasonCode;
  final DateTime? createdAt;
  final DateTime? verifiedAt;
  final DateTime? grantedAt;
  final DateTime? expiresAt;

  AdRewardLedger({
    this.id,
    required this.userId,
    required this.contextType,
    this.provider,
    this.adUnitId,
    required this.rewardAmount,
    required this.status,
    required this.idempotencyKey,
    this.gameId,
    this.entryId,
    this.txHash,
    this.reasonCode,
    this.createdAt,
    this.verifiedAt,
    this.grantedAt,
    this.expiresAt,
  });

  factory AdRewardLedger.fromJson(Map<String, dynamic> json) {
    final contextTypeStr = json['contextType'] as String;
    final contextType = switch (contextTypeStr) {
      'ATTENDANCE_BOOST' => AdContextType.attendanceBoost,
      'TX_WAIT_BOOST' => AdContextType.txWaitBoost,
      'POST_RESULT_BOOST' => AdContextType.postResultBoost,
      'HOME_DAILY' => AdContextType.homeDaily,
      _ => AdContextType.homeDaily,
    };

    final statusStr = json['status'] as String;
    final status = switch (statusStr) {
      'INITIATED' => AdRewardStatus.initiated,
      'VERIFICATION_PENDING' => AdRewardStatus.verificationPending,
      'VERIFIED' => AdRewardStatus.verified,
      'GRANTED' => AdRewardStatus.granted,
      'REJECTED' => AdRewardStatus.rejected,
      'EXPIRED' => AdRewardStatus.expired,
      _ => AdRewardStatus.initiated,
    };

    return AdRewardLedger(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      contextType: contextType,
      provider: json['provider'] as String?,
      adUnitId: json['adUnitId'] as String?,
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble() ?? 0,
      status: status,
      idempotencyKey: json['idempotencyKey'] as String,
      gameId: json['gameId'] as String?,
      entryId: json['entryId'] as String?,
      txHash: json['txHash'] as String?,
      reasonCode: AdRewardReasonCodeExtension.fromString(json['reasonCode'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'] as String)
          : null,
      grantedAt: json['grantedAt'] != null
          ? DateTime.tryParse(json['grantedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  /// 보상 성공 여부
  bool get isGranted => status == AdRewardStatus.granted;

  /// 컨텍스트 타입 표시명
  String get contextTypeDisplayName {
    return switch (contextType) {
      AdContextType.attendanceBoost => '출석 2배 보상',
      AdContextType.txWaitBoost => 'TX 대기 보상',
      AdContextType.postResultBoost => '결과 후 보상',
      AdContextType.homeDaily => '일일 보상',
    };
  }
}

/// 광고 보상 원장 페이지 응답
class AdRewardLedgerPage {
  final List<AdRewardLedger> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  AdRewardLedgerPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory AdRewardLedgerPage.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return AdRewardLedgerPage(
      content: contentList
          .map((e) => AdRewardLedger.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  bool get hasMore => currentPage < totalPages - 1;
}

/// 광고 보상 서비스
/// 백엔드 API와 연동하여 광고 시청 보상을 처리합니다.
class AdRewardService {
  final GraphQLClient _client;
  final AdMobService _adMobService;

  AdRewardService({
    required GraphQLClient client,
    AdMobService? adMobService,
  })  : _client = client,
        _adMobService = adMobService ?? AdMobService();

  /// 보상형 광고 Unit ID
  String get _adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('지원하지 않는 플랫폼입니다.');
  }

  /// 광고 세션 시작
  Future<AdRewardSession> startAdRewardSession({
    required AdContextType contextType,
    required String idempotencyKey,
    String? gameId,
    String? entryId,
  }) async {
    const mutation = r'''
      mutation StartAdReward($input: StartAdRewardSessionInput!) {
        startAdRewardSession(input: $input) {
          rewardSessionId
          verificationToken
          rewardPreviewAmount
          expiresAt
          status
        }
      }
    ''';

    final variables = {
      'input': {
        'contextType': contextType.value,
        'idempotencyKey': idempotencyKey,
        'provider': 'admob',
        'adUnitId': _adUnitId,
        if (gameId != null) 'gameId': gameId,
        if (entryId != null) 'entryId': entryId,
      },
    };

    debugPrint('📤 광고 세션 시작 요청: $variables');

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw Exception('광고 세션 시작 실패: ${result.exception}');
    }

    final data = result.data?['startAdRewardSession'];
    if (data == null) {
      throw Exception('광고 세션 시작 응답이 없습니다.');
    }

    debugPrint('📥 광고 세션 시작 응답: $data');
    return AdRewardSession.fromJson(data);
  }

  /// 광고 보상 완료 처리
  Future<AdRewardResult> completeAdRewardSession({
    required String rewardSessionId,
    required String idempotencyKey,
    required String verificationToken,
    Map<String, dynamic>? providerPayload,
    String? providerRewardEventId,
  }) async {
    const mutation = r'''
      mutation CompleteAdReward($input: CompleteAdRewardSessionInput!) {
        completeAdRewardSession(input: $input) {
          status
          grantedAmount
          reasonCode
          walletSnapshot {
            userId
            shoppingCash
            eventPoint
            participationPoint
          }
        }
      }
    ''';

    final variables = {
      'input': {
        'rewardSessionId': rewardSessionId,
        'idempotencyKey': idempotencyKey,
        'verificationToken': verificationToken,
        if (providerPayload != null) 'providerPayload': jsonEncode(providerPayload),
        if (providerRewardEventId != null) 'providerRewardEventId': providerRewardEventId,
      },
    };

    debugPrint('📤 광고 보상 완료 요청: $variables');

    final result = await _client.mutate(
      MutationOptions(
        document: gql(mutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw Exception('광고 보상 완료 실패: ${result.exception}');
    }

    final data = result.data?['completeAdRewardSession'];
    if (data == null) {
      throw Exception('광고 보상 완료 응답이 없습니다.');
    }

    debugPrint('📥 광고 보상 완료 응답: $data');
    return AdRewardResult.fromJson(data);
  }

  /// 전체 광고 보상 플로우 실행
  ///
  /// 1. 세션 시작 → 2. 광고 표시 → 3. 보상 완료 처리
  Future<AdRewardResult> showRewardedAdWithReward({
    required AdContextType contextType,
    required String userId,
    String? gameId,
    String? entryId,
    void Function(int previewAmount)? onSessionStarted,
    VoidCallback? onAdShowing,
    void Function(String error)? onError,
  }) async {
    // Idempotency Key 생성
    final idempotencyKey = _generateIdempotencyKey(
      userId: userId,
      contextType: contextType,
      gameId: gameId,
      entryId: entryId,
    );

    try {
      // 1. 세션 시작
      debugPrint('🚀 광고 보상 플로우 시작: ${contextType.value}');
      final session = await startAdRewardSession(
        contextType: contextType,
        idempotencyKey: idempotencyKey,
        gameId: gameId,
        entryId: entryId,
      );

      onSessionStarted?.call(session.rewardPreviewAmount);
      debugPrint('✅ 세션 시작 완료: ${session.rewardSessionId}');
      debugPrint('   예상 보상: ${session.rewardPreviewAmount}P');

      // 2. 광고 로드 확인 및 표시
      if (!_adMobService.isAdLoaded) {
        debugPrint('📥 광고 로드 중...');
        await _loadAdWithRetry();
      }

      // 광고 표시 및 결과 대기
      final rewardCompleter = Completer<RewardItem>();

      onAdShowing?.call();
      await _adMobService.showRewardedAd(
        onUserEarnedReward: (reward) {
          rewardCompleter.complete(reward);
        },
        onAdFailedToShow: (error) {
          if (!rewardCompleter.isCompleted) {
            rewardCompleter.completeError(Exception(error));
          }
        },
      );

      // 보상 획득 대기
      final reward = await rewardCompleter.future;
      debugPrint('🎉 광고 보상 획득: ${reward.amount} ${reward.type}');

      // 3. 보상 완료 처리
      final result = await completeAdRewardSession(
        rewardSessionId: session.rewardSessionId,
        idempotencyKey: idempotencyKey,
        verificationToken: session.verificationToken,
        providerPayload: {
          'adNetworkId': 'admob',
          'rewardAmount': reward.amount,
          'rewardType': reward.type,
        },
      );

      debugPrint('✅ 광고 보상 완료: ${result.grantedAmount}P');
      return result;
    } catch (e) {
      debugPrint('❌ 광고 보상 플로우 실패: $e');
      onError?.call(e.toString());
      rethrow;
    }
  }

  /// Idempotency Key 생성
  String _generateIdempotencyKey({
    required String userId,
    required AdContextType contextType,
    String? gameId,
    String? entryId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final contextName = contextType.value.toLowerCase();

    switch (contextType) {
      case AdContextType.attendanceBoost:
        // 출석 2배: 날짜 기반 (1일 1회)
        final today = DateTime.now().toIso8601String().split('T')[0].replaceAll('-', '');
        return 'user-$userId-attendance-$today';

      case AdContextType.txWaitBoost:
        // TX 대기: 엔트리 + 타임스탬프 (무제한)
        return 'user-$userId-txwait-$entryId-$timestamp';

      case AdContextType.postResultBoost:
        // 게임 결과: 게임 + 타임스탬프 (무제한)
        return 'user-$userId-postresult-$gameId-$timestamp';

      case AdContextType.homeDaily:
        // 홈 일일: 타임스탬프 (1일 5회)
        return 'user-$userId-home-$timestamp';
    }
  }

  /// 광고 로드 (재시도 포함)
  Future<void> _loadAdWithRetry({int maxRetries = 3}) async {
    final completer = Completer<void>();

    for (var i = 0; i < maxRetries; i++) {
      try {
        await _adMobService.loadRewardedAd(
          onAdLoaded: () {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onAdFailedToLoad: (error) {
            debugPrint('⚠️ 광고 로드 실패 (시도 ${i + 1}/$maxRetries): $error');
            if (i == maxRetries - 1 && !completer.isCompleted) {
              completer.completeError(Exception('광고를 불러올 수 없습니다.'));
            }
          },
        );

        // 로드 완료 대기 (최대 10초)
        await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (i == maxRetries - 1) {
              throw TimeoutException('광고 로드 시간 초과');
            }
          },
        );

        if (completer.isCompleted) break;
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(Duration(seconds: i + 1));
      }
    }
  }

  /// 광고 미리 로드 (앱 시작 시 호출)
  Future<void> preloadAd() async {
    await _adMobService.loadRewardedAd();
  }

  /// 광고 보상 정책 조회
  Future<AdRewardPolicy?> getAdRewardPolicy(AdContextType contextType) async {
    const query = r'''
      query GetAdRewardPolicy($contextType: AdRewardContextType!) {
        adRewardPolicy(contextType: $contextType) {
          id
          contextType
          provider
          enabled
          baseRewardAmount
          bonusRewardAmount
          multiplier
          dailyLimit
          cooldownSeconds
          perGameLimit
          perEntryLimit
          effectiveFrom
          effectiveTo
        }
      }
    ''';

    final variables = {
      'contextType': contextType.value,
    };

    debugPrint('📤 광고 보상 정책 조회: $variables');

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception('광고 보상 정책 조회 실패: ${result.exception}');
    }

    final data = result.data?['adRewardPolicy'];
    if (data == null) {
      debugPrint('📥 광고 보상 정책 없음');
      return null;
    }

    debugPrint('📥 광고 보상 정책 응답: $data');
    return AdRewardPolicy.fromJson(data);
  }

  /// 내 광고 보상 기록 조회
  Future<AdRewardLedgerPage> getMyAdRewardLedgers({
    int page = 0,
    int size = 20,
  }) async {
    const query = r'''
      query GetMyAdRewardLedgers($page: PageInput!) {
        myAdRewardLedgers(page: $page) {
          content {
            id
            userId
            contextType
            provider
            adUnitId
            rewardAmount
            status
            idempotencyKey
            gameId
            entryId
            txHash
            reasonCode
            createdAt
            verifiedAt
            grantedAt
            expiresAt
          }
          totalElements
          totalPages
          currentPage
          pageSize
        }
      }
    ''';

    final variables = {
      'page': {
        'page': page,
        'size': size,
      },
    };

    debugPrint('📤 내 광고 보상 기록 조회: $variables');

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception('내 광고 보상 기록 조회 실패: ${result.exception}');
    }

    final data = result.data?['myAdRewardLedgers'];
    if (data == null) {
      throw Exception('내 광고 보상 기록 응답이 없습니다.');
    }

    debugPrint('📥 내 광고 보상 기록 응답: 총 ${data['totalElements']}건');
    return AdRewardLedgerPage.fromJson(data);
  }

  /// 광고 보상 기록 조회 (필터링)
  Future<AdRewardLedgerPage> getAdRewardLedgers({
    String? userId,
    AdContextType? contextType,
    AdRewardStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
    int size = 20,
  }) async {
    const query = r'''
      query GetAdRewardLedgers($filter: AdRewardLedgerFilterInput!, $page: PageInput!) {
        adRewardLedgers(filter: $filter, page: $page) {
          content {
            id
            userId
            contextType
            provider
            adUnitId
            rewardAmount
            status
            idempotencyKey
            gameId
            entryId
            txHash
            reasonCode
            createdAt
            verifiedAt
            grantedAt
            expiresAt
          }
          totalElements
          totalPages
          currentPage
          pageSize
        }
      }
    ''';

    String? statusValue;
    if (status != null) {
      statusValue = switch (status) {
        AdRewardStatus.initiated => 'INITIATED',
        AdRewardStatus.verificationPending => 'VERIFICATION_PENDING',
        AdRewardStatus.verified => 'VERIFIED',
        AdRewardStatus.granted => 'GRANTED',
        AdRewardStatus.rejected => 'REJECTED',
        AdRewardStatus.expired => 'EXPIRED',
      };
    }

    final variables = {
      'filter': {
        if (userId != null) 'userId': userId,
        if (contextType != null) 'contextType': contextType.value,
        if (statusValue != null) 'status': statusValue,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
      'page': {
        'page': page,
        'size': size,
      },
    };

    debugPrint('📤 광고 보상 기록 조회: $variables');

    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception('광고 보상 기록 조회 실패: ${result.exception}');
    }

    final data = result.data?['adRewardLedgers'];
    if (data == null) {
      throw Exception('광고 보상 기록 응답이 없습니다.');
    }

    debugPrint('📥 광고 보상 기록 응답: 총 ${data['totalElements']}건');
    return AdRewardLedgerPage.fromJson(data);
  }

  /// 리소스 해제
  void dispose() {
    _adMobService.dispose();
  }
}
