import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'block_model.dart';
import '../core/theme/app_colors.dart';

/// 그리드 섹션 (구역)
///
/// 큰 그리드를 여러 구역으로 나누어 표시
@immutable
class GridSection {
  /// 섹션 ID
  final String id;

  /// 섹션 이름 (예: "A1", "B2")
  final String name;

  /// 시작 행 (1-based)
  final int startRow;

  /// 끝 행 (1-based, inclusive)
  final int endRow;

  /// 시작 열 (1-based)
  final int startCol;

  /// 끝 열 (1-based, inclusive)
  final int endCol;

  /// 색상
  final Color color;

  const GridSection({
    required this.id,
    required this.name,
    required this.startRow,
    required this.endRow,
    required this.startCol,
    required this.endCol,
    required this.color,
  });

  /// 블록이 이 섹션에 속하는지 확인
  bool contains(BlockModel block) {
    return block.row >= startRow &&
        block.row <= endRow &&
        block.col >= startCol &&
        block.col <= endCol;
  }

  /// 중심 좌표
  Offset get center {
    final centerRow = (startRow + endRow) / 2;
    final centerCol = (startCol + endCol) / 2;
    return Offset(centerCol, centerRow);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridSection && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 그리드를 섹션으로 분할
class GridSectionManager {
  /// 그리드를 NxN 섹션으로 분할
  ///
  /// [gridWidth] 그리드 가로 크기
  /// [gridHeight] 그리드 세로 크기
  /// [sectionsPerSide] 한 변에 몇 개의 섹션을 만들지 (기본: 3x3)
  static List<GridSection> createSections({
    required int gridWidth,
    required int gridHeight,
    int sectionsPerSide = 3,
  }) {
    final sections = <GridSection>[];

    // 각 섹션의 크기 계산
    final sectionWidth = (gridWidth / sectionsPerSide).ceil();
    final sectionHeight = (gridHeight / sectionsPerSide).ceil();

    // 섹션 색상 (시각적 구분을 위해)
    final colors = [
      AppColors.blue, // blue
      AppColors.primaryLight, // purple
      AppColors.red, // pink
      AppColors.yellow500, // amber
      AppColors.green500, // green
      AppColors.blue, // cyan
      AppColors.red, // red
      AppColors.primaryMain, // indigo
      AppColors.green500, // lime
    ];

    // 섹션 이름 생성 (A1, A2, ... B1, B2, ...)
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    int sectionIndex = 0;
    for (int row = 0; row < sectionsPerSide; row++) {
      for (int col = 0; col < sectionsPerSide; col++) {
        final startRow = row * sectionHeight + 1;
        final endRow = ((row + 1) * sectionHeight).clamp(1, gridHeight);
        final startCol = col * sectionWidth + 1;
        final endCol = ((col + 1) * sectionWidth).clamp(1, gridWidth);

        final sectionName = '${letters[row]}${col + 1}';
        final colorIndex = sectionIndex % colors.length;

        sections.add(
          GridSection(
            id: 'section_${row}_$col',
            name: sectionName,
            startRow: startRow,
            endRow: endRow,
            startCol: startCol,
            endCol: endCol,
            color: colors[colorIndex],
          ),
        );

        sectionIndex++;
      }
    }

    return sections;
  }

  /// 블록이 속한 섹션 찾기
  static GridSection? findSectionForBlock(
    BlockModel block,
    List<GridSection> sections,
  ) {
    for (final section in sections) {
      if (section.contains(block)) {
        return section;
      }
    }
    return null;
  }

  /// 섹션별 픽 개수 계산
  static Map<GridSection, List<BlockModel>> groupPicksBySection(
    List<BlockModel> picks,
    List<GridSection> sections,
  ) {
    final grouped = <GridSection, List<BlockModel>>{};

    for (final pick in picks) {
      final section = findSectionForBlock(pick, sections);
      if (section != null) {
        grouped.putIfAbsent(section, () => []);
        grouped[section]!.add(pick);
      }
    }

    return grouped;
  }

  /// 섹션 설명 생성
  static String getSectionDescription(GridSection section) {
    return '${section.name} 구역 (Row ${section.startRow}-${section.endRow}, Col ${section.startCol}-${section.endCol})';
  }

  /// 간단한 위치 설명 생성
  static String getSimpleLocation(GridSection section, int sectionsPerSide) {
    // A1, A2, A3 -> 상단 좌측, 상단 중앙, 상단 우측
    // B1, B2, B3 -> 중단 좌측, 중단 중앙, 중단 우측
    // C1, C2, C3 -> 하단 좌측, 하단 중앙, 하단 우측

    final sectionName = section.name;
    final rowChar = sectionName[0];
    final colNum = int.parse(sectionName.substring(1));

    String vertical;
    String horizontal;

    // 세로 위치
    final rowIndex = rowChar.codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (rowIndex == 0) {
      vertical = '상단';
    } else if (rowIndex == sectionsPerSide - 1) {
      vertical = '하단';
    } else {
      vertical = '중단';
    }

    // 가로 위치
    if (colNum == 1) {
      horizontal = '좌측';
    } else if (colNum == sectionsPerSide) {
      horizontal = '우측';
    } else {
      horizontal = '중앙';
    }

    return '$vertical $horizontal';
  }
}
