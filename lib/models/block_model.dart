import 'package:flutter/foundation.dart';

/// 블록 상태
enum BlockState {
  /// 빈 셀
  empty,

  /// 선택된 셀
  selected,

  /// 당첨 셀
  winner,

  /// 유니크 셀 (한 명만 선택)
  unique,

  /// 중복 셀 (여러 명 선택)
  duplicate,

  /// 과거 선택
  past,
}

/// 블록 모델
@immutable
class BlockModel {
  /// 행 (1-based)
  final int row;

  /// 열 (1-based)
  final int col;

  /// 블록 ID (고유 식별자)
  final String id;

  /// 블록 상태
  final BlockState state;

  /// 마지막 업데이트 시간
  final DateTime lastUpdated;

  const BlockModel({
    required this.row,
    required this.col,
    required this.id,
    this.state = BlockState.empty,
    required this.lastUpdated,
  });

  /// ID를 row, col로부터 생성
  factory BlockModel.fromPosition(int row, int col, {BlockState? state}) {
    return BlockModel(
      row: row,
      col: col,
      id: '$row-$col',
      state: state ?? BlockState.empty,
      lastUpdated: DateTime.now(),
    );
  }

  /// 복사본 생성
  BlockModel copyWith({
    int? row,
    int? col,
    String? id,
    BlockState? state,
    DateTime? lastUpdated,
  }) {
    return BlockModel(
      row: row ?? this.row,
      col: col ?? this.col,
      id: id ?? this.id,
      state: state ?? this.state,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'id': id,
      'state': state.name,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      row: json['row'] as int,
      col: json['col'] as int,
      id: json['id'] as String,
      state: BlockState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => BlockState.empty,
      ),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BlockModel && other.id == id && other.state == state;
  }

  @override
  int get hashCode => id.hashCode ^ state.hashCode;

  @override
  String toString() {
    return 'BlockModel(row: $row, col: $col, id: $id, state: $state)';
  }
}

/// 게임 결과 모델
@immutable
class GameResultsModel {
  /// 당첨 셀 번호
  final int? winnerCell;

  /// 당첨 상품
  final dynamic winnerProduct;

  /// 유니크 셀 목록
  final List<int> uniqueCells;

  /// 플레이어 선택 (셀 번호 -> 선택 수)
  final Map<int, int> playerSelections;

  /// 상품 획득 여부
  final bool wonPrize;

  /// 획득 포인트
  final int pointsEarned;

  const GameResultsModel({
    this.winnerCell,
    this.winnerProduct,
    this.uniqueCells = const [],
    this.playerSelections = const {},
    this.wonPrize = false,
    this.pointsEarned = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'winnerCell': winnerCell,
      'winnerProduct': winnerProduct,
      'uniqueCells': uniqueCells,
      'playerSelections': playerSelections,
      'wonPrize': wonPrize,
      'pointsEarned': pointsEarned,
    };
  }

  factory GameResultsModel.fromJson(Map<String, dynamic> json) {
    return GameResultsModel(
      winnerCell: json['winnerCell'] as int?,
      winnerProduct: json['winnerProduct'],
      uniqueCells: List<int>.from(json['uniqueCells'] ?? []),
      playerSelections: Map<int, int>.from(json['playerSelections'] ?? {}),
      wonPrize: json['wonPrize'] as bool? ?? false,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
    );
  }
}

/// 게임 통계 모델
@immutable
class GameStatsModel {
  /// 참가자 수
  final int participants;

  /// 전체 블록 수
  final int totalBlocks;

  /// 필수 선택 수
  final int requiredPicks;

  /// 최대 선택 수
  final int maxPicks;

  /// 당첨자 수
  final int winners;

  /// 남은 시간
  final Duration? timeLeft;

  const GameStatsModel({
    this.participants = 0,
    this.totalBlocks = 0,
    this.requiredPicks = 0,
    this.maxPicks = 0,
    this.winners = 0,
    this.timeLeft,
  });

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'totalBlocks': totalBlocks,
      'requiredPicks': requiredPicks,
      'maxPicks': maxPicks,
      'winners': winners,
      'timeLeft': timeLeft?.inSeconds,
    };
  }

  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      participants: json['participants'] as int? ?? 0,
      totalBlocks: json['totalBlocks'] as int? ?? 0,
      requiredPicks: json['requiredPicks'] as int? ?? 0,
      maxPicks: json['maxPicks'] as int? ?? 0,
      winners: json['winners'] as int? ?? 0,
      timeLeft: json['timeLeft'] != null
          ? Duration(seconds: json['timeLeft'] as int)
          : null,
    );
  }
}
