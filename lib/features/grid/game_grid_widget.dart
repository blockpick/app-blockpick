import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/block_model.dart';
import '../canvas/block_pick_canvas.dart';

/// 게임 그리드 위젯
///
/// 내부적으로 BlockPickCanvas를 사용하여 대형 그리드를 렌더링합니다.
/// 기존 인터페이스를 유지하여 호출하는 쪽(game_screen.dart 등)은 변경 불필요합니다.
class GameGridWidget extends ConsumerStatefulWidget {
  /// 게임 ID (라운드별 상태 분리)
  final String gameId;

  /// 그리드 가로 크기
  final int gridWidth;

  /// 그리드 세로 크기
  final int gridHeight;

  /// 블록 클릭 콜백 (false 반환 시 블록 선택 취소)
  final bool Function(BlockModel)? onBlockTap;

  /// 배경 이미지 경로 (제품 이미지)
  final String? backgroundImagePath;

  /// 튜토리얼 목표 블록에 할당할 GlobalKey (튜토리얼 스포트라이트용)
  final GlobalKey? tutorialBlockKey;

  const GameGridWidget({
    super.key,
    required this.gameId,
    required this.gridWidth,
    required this.gridHeight,
    this.onBlockTap,
    this.backgroundImagePath,
    this.tutorialBlockKey,
  });

  @override
  ConsumerState<GameGridWidget> createState() => _GameGridWidgetState();
}

class _GameGridWidgetState extends ConsumerState<GameGridWidget> {
  @override
  Widget build(BuildContext context) {
    return BlockPickCanvas(
      gameId: widget.gameId,
      gridWidth: widget.gridWidth,
      gridHeight: widget.gridHeight,
      onBlockTap: widget.onBlockTap,
      backgroundImagePath: widget.backgroundImagePath,
      tutorialBlockKey: widget.tutorialBlockKey,
      showDotPattern: true,
      darkMode: true,
    );
  }
}
