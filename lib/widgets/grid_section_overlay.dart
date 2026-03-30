import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/app_constants.dart';
import '../models/grid_section_model.dart';
import '../models/block_model.dart';

/// 그리드 섹션 오버레이
///
/// 축소 시 그리드를 구역으로 나누어 표시
class GridSectionOverlay extends StatelessWidget {
  final List<GridSection> sections;
  final Map<GridSection, List<BlockModel>> picksBySection;
  final double zoom;
  final double panX;
  final double panY;
  final Size screenSize;
  final bool show; // 축소 시에만 표시

  const GridSectionOverlay({
    super.key,
    required this.sections,
    required this.picksBySection,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.screenSize,
    this.show = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: sections.map((section) {
        // 섹션의 화면 좌표 계산
        final startX = (section.startCol - 1) * AppConstants.cellSize * zoom + panX;
        final startY = (section.startRow - 1) * AppConstants.cellSize * zoom + panY;
        final endX = section.endCol * AppConstants.cellSize * zoom + panX;
        final endY = section.endRow * AppConstants.cellSize * zoom + panY;

        final width = endX - startX;
        final height = endY - startY;

        // 화면 밖이면 렌더링 안 함
        if (endX < 0 || startX > screenSize.width || endY < 0 || startY > screenSize.height) {
          return const SizedBox.shrink();
        }

        // 이 섹션의 픽 개수
        final pickCount = picksBySection[section]?.length ?? 0;

        return Positioned(
          left: startX,
          top: startY,
          width: width,
          height: height,
          child: _buildSectionWidget(section, pickCount),
        );
      }).toList(),
      ),
    );
  }

  Widget _buildSectionWidget(GridSection section, int pickCount) {
    if (pickCount == 0) {
      // 픽이 없는 섹션: 투명한 테두리만
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.buleGray.withOpacity(0.3),
            width: 1.0,
          ),
        ),
      );
    }

    // 픽이 있는 섹션: 색상 + 개수 표시
    return Container(
      decoration: BoxDecoration(
        color: section.color.withOpacity(0.15),
        border: Border.all(
          color: section.color.withOpacity(0.6),
          width: 2.0,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: section.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                section.name,
                style: AppTextStyles.body4.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '$pickCount picks',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 섹션 목록 위젯 (우측 패널용)
class SectionListWidget extends StatelessWidget {
  final Map<GridSection, List<BlockModel>> picksBySection;
  final Function(GridSection)? onSectionTap;
  final int totalPicks;

  SectionListWidget({
    super.key,
    required this.picksBySection,
    this.onSectionTap,
    required this.totalPicks,
  });

  @override
  Widget build(BuildContext context) {
    if (picksBySection.isEmpty) {
      return const SizedBox.shrink();
    }

    // 섹션을 픽 개수 순으로 정렬
    final sortedSections = picksBySection.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '구역별 분포',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...sortedSections.map((entry) {
          final section = entry.key;
          final picks = entry.value;
          final percentage = (picks.length / totalPicks * 100).toStringAsFixed(0);

          return ListTile(
            dense: true,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: section.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  section.name,
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            title: Text(
              GridSectionManager.getSimpleLocation(section, 3),
              style: AppTextStyles.body3.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${picks.length}개 픽 ($percentage%)',
              style: AppTextStyles.body4.copyWith(
                color: AppColors.medium,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.medium,
            ),
            onTap: () => onSectionTap?.call(section),
          );
        }).toList(),
      ],
    );
  }
}

/// 섹션 미니 맵 (간단한 격자 뷰)
class SectionMiniGrid extends StatelessWidget {
  final Map<GridSection, List<BlockModel>> picksBySection;
  final int sectionsPerSide;
  final Function(GridSection)? onSectionTap;

  SectionMiniGrid({
    super.key,
    required this.picksBySection,
    this.sectionsPerSide = 3,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '구역 맵',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: sectionsPerSide,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: sectionsPerSide * sectionsPerSide,
              itemBuilder: (context, index) {
                final section = _getSectionAtIndex(index);
                final pickCount = picksBySection[section]?.length ?? 0;

                return GestureDetector(
                  onTap: () => onSectionTap?.call(section),
                  child: Container(
                    decoration: BoxDecoration(
                      color: pickCount > 0
                          ? section.color.withOpacity(0.8)
                          : AppColors.deepWhite,
                      border: Border.all(
                        color: pickCount > 0
                            ? section.color
                            : AppColors.buleGray,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            section.name,
                            style: AppTextStyles.body4.copyWith(
                              color: pickCount > 0
                                  ? AppColors.white
                                  : AppColors.medium,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (pickCount > 0) ...[
                            SizedBox(height: 4),
                            Text(
                              '$pickCount',
                              style: AppTextStyles.heading1.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  GridSection _getSectionAtIndex(int index) {
    // index에서 section을 찾기
    // picksBySection의 키들을 정렬된 순서로 반환
    final allSections = picksBySection.keys.toList();
    allSections.sort((a, b) {
      final aRow = a.name[0].codeUnitAt(0);
      final bRow = b.name[0].codeUnitAt(0);
      if (aRow != bRow) return aRow.compareTo(bRow);

      final aCol = int.parse(a.name.substring(1));
      final bCol = int.parse(b.name.substring(1));
      return aCol.compareTo(bCol);
    });

    return index < allSections.length
        ? allSections[index]
        : allSections.first; // fallback
  }
}
