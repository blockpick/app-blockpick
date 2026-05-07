import 'package:flutter/material.dart';

/// 블록 선택 그리드 보드
class GridBoard extends StatelessWidget {
  final int rows;
  final int cols;
  final int? selectedRow;
  final int? selectedCol;
  final void Function(int row, int col) onTap;

  const GridBoard({
    super.key,
    required this.rows,
    required this.cols,
    this.selectedRow,
    this.selectedCol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final aspectRatio = cols / rows;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          final row = index ~/ cols;
          final col = index % cols;
          final isSelected = row == selectedRow && col == selectedCol;

          return GestureDetector(
            onTap: () => onTap(row, col),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: isSelected
                    ? Text(
                        'R${row + 1}-C${col + 1}',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
