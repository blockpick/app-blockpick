// BlockpickSummary / BlockpickDetail → GameRound 변환 어댑터
//
// 배경:
//   구 game_provider (getGames GraphQL) → 신 blockpick_provider (blockpicks GraphQL) 마이그레이션.
//   신 모델(BlockpickSummary)에는 gameType / currency / maxEntries / participants 필드가 아직 없음.
//   백엔드 스키마 확장 전까지 아래 Mock 값 / 계산 규칙으로 동작.
//
// TODO (백엔드 정합 후 재검증):
//   - BlockpickSummary에 gameType(String), currency(String), maxEntries(int), participants(int) 추가
//   - fromSummary() 내 Mock 값 제거 후 실제 필드로 교체
//   - docs/blockpick_summary_field_request.md 참조

import '../../models/game_round_model.dart';
import 'blockpick_models.dart';

class BlockpickToGameAdapter {
  // =====================================================================
  // Public API
  // =====================================================================

  /// BlockpickSummary → GameRound (리스트 뷰용)
  ///
  /// [mockGameType] : 백엔드에 gameType 필드 추가 전까지 사용하는 임시 값.
  ///                 호출처에서 명시적으로 지정 (예: GameType.daily).
  static GameRound fromSummary(
    BlockpickSummary bp, {
    GameType mockGameType = GameType.daily,
  }) {
    return GameRound(
      id: bp.id,
      title: bp.title,
      description: '', // BlockpickSummary에는 description 없음
      imageUrl: bp.thumbnailUrl ?? '',
      participants: bp.totalEntryCount.toInt(),
      // TODO: 백엔드에서 maxEntries 필드 추가 후 실제 값으로 교체
      maxParticipants: 0,
      totalBlocks: bp.gridRows * bp.gridCols,
      requiredPicks: 1, // 기본값 (BlockpickSummary에 없음)
      winners: 1, // 기본값
      originalPrice: bp.topPrize?.prize.faceValue?.toInt() ?? 0,
      // TODO: 기획 단가 정책 확정 후 실제 entryFee로 교체
      currentPrice: _calculateEntryFee(bp.freeEntryQuota),
      timeLeft: _calcTimeLeft(bp.endTime),
      // TODO: BlockpickSummary에 gameType 추가 후 실제 enum으로 매핑
      type: mockGameType,
      status: _mapStatus(bp.status),
      category: bp.category.code,
      gridWidth: bp.gridCols,
      gridHeight: bp.gridRows,
    );
  }

  /// BlockpickDetail → GameRound (상세 뷰용)
  ///
  /// prizes 전체 리스트를 포함한 변환이 필요할 때 사용.
  /// 현재 GameRound 모델에는 gameProducts 필드가 없으므로 기본 필드만 매핑.
  static GameRound fromDetail(
    BlockpickDetail bp, {
    GameType mockGameType = GameType.daily,
  }) {
    // 최고 등급 상품 이미지를 대표 이미지로 사용
    final grandPrize = bp.prizes.where((p) => p.tier == PrizeTier.grand).firstOrNull;
    final topPrize = grandPrize ?? (bp.prizes.isNotEmpty ? bp.prizes.first : null);

    return GameRound(
      id: bp.id,
      title: bp.title,
      description: bp.description ?? '',
      imageUrl: bp.thumbnailUrl ?? topPrize?.prize.imageUrl ?? '',
      participants: bp.totalEntryCount.toInt(),
      // TODO: 백엔드에서 maxEntries 필드 추가 후 실제 값으로 교체
      maxParticipants: 0,
      totalBlocks: bp.gridRows * bp.gridCols,
      requiredPicks: 1,
      winners: 1,
      originalPrice: topPrize?.prize.faceValue?.toInt() ?? 0,
      currentPrice: _calculateEntryFee(bp.freeEntryQuota),
      timeLeft: _calcTimeLeft(bp.endTime),
      type: mockGameType,
      status: _mapStatus(bp.status),
      category: bp.category.code,
      gridWidth: bp.gridCols,
      gridHeight: bp.gridRows,
    );
  }

  /// BlockpickSummary 목록 → GameRound 목록 (일괄 변환 편의 메서드)
  static List<GameRound> fromSummaryList(
    List<BlockpickSummary> list, {
    GameType mockGameType = GameType.daily,
  }) {
    return list
        .map((bp) => fromSummary(bp, mockGameType: mockGameType))
        .toList();
  }

  // =====================================================================
  // 내부 변환 헬퍼
  // =====================================================================

  /// 진입료 계산 (freeEntryQuota → entryFee 포인트)
  ///
  /// 기획 단가 규칙 (임시):
  ///   - 무료 입장 1회  → 25P
  ///   - 무료 입장 2~3회 → 40P
  ///   - 무료 입장 0회  → 100P (유료)
  ///
  /// TODO: 기획 단가 정책 확정 후 수치 조정 필요
  static int _calculateEntryFee(int freeEntryQuota) {
    switch (freeEntryQuota) {
      case 1:
        return 25;
      case 2:
      case 3:
        return 40;
      default:
        return freeEntryQuota > 3 ? 40 : 100;
    }
  }

  /// BlockpickStatus → GameStatus 매핑
  static GameStatus _mapStatus(BlockpickStatus status) {
    switch (status) {
      case BlockpickStatus.draft:
        return GameStatus.scheduled;
      case BlockpickStatus.active:
        return GameStatus.active;
      case BlockpickStatus.paused:
        return GameStatus.paused;
      case BlockpickStatus.ended:
        return GameStatus.ended;
    }
  }

  /// 종료 시각 문자열 → 남은 시간 계산 (GameRound.timeLeft 형식)
  static String _calcTimeLeft(String endTimeIso) {
    try {
      final end = DateTime.parse(endTimeIso);
      final diff = end.difference(DateTime.now());
      if (diff.isNegative) return 'Ended';
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return '${h}h ${m}m';
    } catch (_) {
      return '0h 0m';
    }
  }
}
