// BlockpickToGameAdapter 단위 테스트
//
// 테스트 항목:
//   - fromSummary: 기본 필드 매핑
//   - fromSummary: freeEntryQuota → entryFee 변환 규칙
//   - fromSummary: BlockpickStatus → GameStatus 매핑
//   - fromSummary: 남은 시간(timeLeft) 계산
//   - fromSummaryList: 목록 일괄 변환
//   - fromDetail: description 포함 변환

import 'package:flutter_test/flutter_test.dart';
import 'package:blockpick_flutter/data/blockpick/blockpick_models.dart';
import 'package:blockpick_flutter/data/blockpick/blockpick_to_game_adapter.dart';
import 'package:blockpick_flutter/models/game_round_model.dart';

// =====================================================================
// 테스트 픽스처 헬퍼
// =====================================================================

PartnerSummary _testPartner() => const PartnerSummary(
      id: 'partner-1',
      name: '테스트 파트너',
    );

Category _testCategory({String code = 'Digital'}) => Category(
      id: 'cat-1',
      code: code,
      name: '디지털',
      displayOrder: 1,
      active: true,
    );

PrizeSummary _testPrizeSummary({double? faceValue}) => PrizeSummary(
      id: 'prize-1',
      name: '테스트 상품',
      prizeType: PrizeType.physical,
      faceValue: faceValue,
      imageUrl: 'https://example.com/prize.jpg',
    );

BlockpickPrize _testBlockpickPrize({PrizeTier tier = PrizeTier.grand}) =>
    BlockpickPrize(
      id: 'bp-prize-1',
      tier: tier,
      quantity: 1,
      sequence: 1,
      prize: _testPrizeSummary(faceValue: 50000),
    );

BlockpickSummary _testSummary({
  String id = 'bp-1',
  String title = '테스트 블록픽',
  String? thumbnailUrl = 'https://example.com/thumb.jpg',
  int gridRows = 10,
  int gridCols = 10,
  int freeEntryQuota = 1,
  BlockpickStatus status = BlockpickStatus.active,
  String? endTime,
  BlockpickPrize? topPrize,
  double totalEntryCount = 42,
  String categoryCode = 'Digital',
}) {
  final end = endTime ??
      DateTime.now().add(const Duration(hours: 2, minutes: 30)).toIso8601String();
  return BlockpickSummary(
    id: id,
    title: title,
    thumbnailUrl: thumbnailUrl,
    gridRows: gridRows,
    gridCols: gridCols,
    maxEntriesPerUser: 5,
    freeEntryQuota: freeEntryQuota,
    visibleFrom: DateTime.now().toIso8601String(),
    startTime: DateTime.now().toIso8601String(),
    endTime: end,
    status: status,
    isRecommended: false,
    totalEntryCount: totalEntryCount,
    partner: _testPartner(),
    category: _testCategory(code: categoryCode),
    topPrize: topPrize,
  );
}

void main() {
  group('BlockpickToGameAdapter.fromSummary', () {
    test('기본 필드가 GameRound에 올바르게 매핑된다', () {
      final summary = _testSummary(
        id: 'bp-123',
        title: '아이폰 16 Pro 블록픽',
        thumbnailUrl: 'https://example.com/iphone.jpg',
        gridRows: 8,
        gridCols: 12,
        totalEntryCount: 100,
        categoryCode: 'Fashion',
      );

      final result = BlockpickToGameAdapter.fromSummary(summary);

      expect(result.id, 'bp-123');
      expect(result.title, '아이폰 16 Pro 블록픽');
      expect(result.imageUrl, 'https://example.com/iphone.jpg');
      expect(result.totalBlocks, 96); // 8 * 12
      expect(result.gridWidth, 12);
      expect(result.gridHeight, 8);
      expect(result.participants, 100);
      expect(result.category, 'Fashion');
    });

    test('thumbnailUrl이 null이면 imageUrl은 빈 문자열', () {
      final summary = _testSummary(thumbnailUrl: null);
      final result = BlockpickToGameAdapter.fromSummary(summary);
      expect(result.imageUrl, '');
    });

    test('mockGameType이 결과 type에 반영된다', () {
      final summary = _testSummary();

      final daily = BlockpickToGameAdapter.fromSummary(summary, mockGameType: GameType.daily);
      final vibe = BlockpickToGameAdapter.fromSummary(summary, mockGameType: GameType.vibe);
      final select = BlockpickToGameAdapter.fromSummary(summary, mockGameType: GameType.select);

      expect(daily.type, GameType.daily);
      expect(vibe.type, GameType.vibe);
      expect(select.type, GameType.select);
    });

    test('기본 mockGameType은 GameType.daily이다', () {
      final result = BlockpickToGameAdapter.fromSummary(_testSummary());
      expect(result.type, GameType.daily);
    });
  });

  group('BlockpickToGameAdapter._calculateEntryFee (freeEntryQuota → currentPrice)', () {
    test('freeEntryQuota=0 → 100P', () {
      final result = BlockpickToGameAdapter.fromSummary(_testSummary(freeEntryQuota: 0));
      expect(result.currentPrice, 100);
    });

    test('freeEntryQuota=1 → 25P', () {
      final result = BlockpickToGameAdapter.fromSummary(_testSummary(freeEntryQuota: 1));
      expect(result.currentPrice, 25);
    });

    test('freeEntryQuota=2 → 40P', () {
      final result = BlockpickToGameAdapter.fromSummary(_testSummary(freeEntryQuota: 2));
      expect(result.currentPrice, 40);
    });

    test('freeEntryQuota=3 → 40P', () {
      final result = BlockpickToGameAdapter.fromSummary(_testSummary(freeEntryQuota: 3));
      expect(result.currentPrice, 40);
    });

    test('freeEntryQuota=5 (>3) → 40P (상한 처리)', () {
      final result = BlockpickToGameAdapter.fromSummary(_testSummary(freeEntryQuota: 5));
      expect(result.currentPrice, 40);
    });
  });

  group('BlockpickToGameAdapter._mapStatus', () {
    test('BlockpickStatus.active → GameStatus.active', () {
      final result = BlockpickToGameAdapter.fromSummary(
        _testSummary(status: BlockpickStatus.active),
      );
      expect(result.status, GameStatus.active);
    });

    test('BlockpickStatus.draft → GameStatus.scheduled', () {
      final result = BlockpickToGameAdapter.fromSummary(
        _testSummary(status: BlockpickStatus.draft),
      );
      expect(result.status, GameStatus.scheduled);
    });

    test('BlockpickStatus.paused → GameStatus.paused', () {
      final result = BlockpickToGameAdapter.fromSummary(
        _testSummary(status: BlockpickStatus.paused),
      );
      expect(result.status, GameStatus.paused);
    });

    test('BlockpickStatus.ended → GameStatus.ended', () {
      final result = BlockpickToGameAdapter.fromSummary(
        _testSummary(status: BlockpickStatus.ended),
      );
      expect(result.status, GameStatus.ended);
    });
  });

  group('BlockpickToGameAdapter._calcTimeLeft', () {
    test('미래 종료 시각 → "Xh Ym" 형식 (시간 단위 검증)', () {
      // 분 단위 경계 오차를 피하기 위해 패턴 매칭으로 검증
      final future = DateTime.now().add(const Duration(hours: 3, minutes: 15));
      final result = BlockpickToGameAdapter.fromSummary(
        _testSummary(endTime: future.toIso8601String()),
      );
      // "3h NNm" 형식이고, 시간 부분이 3임을 확인 (분은 실행 타이밍 오차 허용)
      expect(result.timeLeft, startsWith('3h '));
      expect(result.timeLeft, endsWith('m'));
    });

    test('과거 종료 시각 → "Ended"', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final result = BlockpickToGameAdapter.fromSummary(
        _testSummary(endTime: past.toIso8601String()),
      );
      expect(result.timeLeft, 'Ended');
    });

    test('잘못된 ISO 문자열 → "0h 0m"', () {
      final result = BlockpickToGameAdapter.fromSummary(
        _testSummary(endTime: 'NOT_A_DATE'),
      );
      expect(result.timeLeft, '0h 0m');
    });
  });

  group('BlockpickToGameAdapter.fromSummaryList', () {
    test('빈 목록 → 빈 GameRound 목록', () {
      final result = BlockpickToGameAdapter.fromSummaryList([]);
      expect(result, isEmpty);
    });

    test('목록 개수가 유지된다', () {
      final list = [
        _testSummary(id: '1', title: 'A'),
        _testSummary(id: '2', title: 'B'),
        _testSummary(id: '3', title: 'C'),
      ];
      final result = BlockpickToGameAdapter.fromSummaryList(list, mockGameType: GameType.vibe);
      expect(result.length, 3);
      expect(result[0].id, '1');
      expect(result[2].id, '3');
      expect(result.every((r) => r.type == GameType.vibe), isTrue);
    });
  });

  group('BlockpickToGameAdapter.fromDetail', () {
    BlockpickDetail _testDetail({
      String description = '테스트 설명',
      List<BlockpickPrize> prizes = const [],
    }) {
      return BlockpickDetail(
        id: 'detail-1',
        title: '상세 블록픽',
        description: description,
        thumbnailUrl: 'https://example.com/thumb.jpg',
        gridRows: 5,
        gridCols: 5,
        maxEntriesPerUser: 3,
        freeEntryQuota: 1,
        visibleFrom: DateTime.now().toIso8601String(),
        startTime: DateTime.now().toIso8601String(),
        endTime: DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        status: BlockpickStatus.active,
        isRecommended: true,
        referralEnabled: false,
        adRewardEnabled: false,
        missionEnabled: false,
        totalEntryCount: 10,
        partner: _testPartner(),
        category: _testCategory(),
        prizes: prizes,
      );
    }

    test('description이 매핑된다', () {
      final result = BlockpickToGameAdapter.fromDetail(
        _testDetail(description: '이 게임은 특별합니다'),
      );
      expect(result.description, '이 게임은 특별합니다');
    });

    test('prizes가 비어있으면 originalPrice = 0', () {
      final result = BlockpickToGameAdapter.fromDetail(_testDetail(prizes: []));
      expect(result.originalPrice, 0);
    });

    test('grand prize의 faceValue가 originalPrice에 반영된다', () {
      final result = BlockpickToGameAdapter.fromDetail(
        _testDetail(prizes: [_testBlockpickPrize(tier: PrizeTier.grand)]),
      );
      expect(result.originalPrice, 50000);
    });

    test('gridWidth/Height가 올바르게 설정된다', () {
      final result = BlockpickToGameAdapter.fromDetail(_testDetail());
      expect(result.gridWidth, 5);
      expect(result.gridHeight, 5);
      expect(result.totalBlocks, 25);
    });
  });
}
