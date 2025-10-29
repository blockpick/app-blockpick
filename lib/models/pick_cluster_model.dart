import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'block_model.dart';

/// 픽 클러스터 모델
///
/// 축소 시 인접한 픽들을 그룹화하여 표시
@immutable
class PickCluster {
  /// 클러스터에 포함된 픽들
  final List<BlockModel> picks;

  /// 클러스터 중심 위치 (화면 좌표)
  final Offset centerPosition;

  /// 클러스터 ID
  final String id;

  const PickCluster({
    required this.picks,
    required this.centerPosition,
    required this.id,
  });

  /// 단일 픽인지 확인
  bool get isSingle => picks.length == 1;

  /// 클러스터 레이블 (픽 개수)
  String get label => picks.length.toString();

  /// 첫 번째 픽 (단일 픽일 때 사용)
  BlockModel get firstPick => picks.first;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PickCluster &&
        other.id == id &&
        listEquals(other.picks, picks);
  }

  @override
  int get hashCode => id.hashCode ^ Object.hashAll(picks);
}

/// 클러스터링 알고리즘
class PickClusteringAlgorithm {
  /// 간단한 그리드 기반 클러스터링
  ///
  /// [picks] 픽 리스트
  /// [zoom] 현재 줌
  /// [panX] 현재 X 팬 오프셋
  /// [panY] 현재 Y 팬 오프셋
  /// [cellSize] 셀 크기 (기본 크기, zoom 미적용)
  /// [threshold] 클러스터링 임계값 (픽셀 단위)
  static List<PickCluster> clusterPicks({
    required List<BlockModel> picks,
    required double zoom,
    required double panX,
    required double panY,
    required double cellSize,
    required double threshold,
  }) {
    if (picks.isEmpty || threshold <= 0) {
      return [];
    }

    final clusters = <PickCluster>[];
    final processed = <String>{};

    for (int i = 0; i < picks.length; i++) {
      final pick = picks[i];

      // 이미 처리된 픽은 건너뛰기
      if (processed.contains(pick.id)) continue;

      // 현재 픽을 포함하는 클러스터 생성
      final clusterPicks = <BlockModel>[pick];
      processed.add(pick.id);

      // 현재 픽의 화면 좌표 계산
      final pickX = (pick.col - 1) * cellSize * zoom + panX;
      final pickY = (pick.row - 1) * cellSize * zoom + panY;

      // 임계값 이내의 다른 픽들 찾기
      for (int j = i + 1; j < picks.length; j++) {
        final otherPick = picks[j];

        if (processed.contains(otherPick.id)) continue;

        // 다른 픽의 화면 좌표 계산
        final otherX = (otherPick.col - 1) * cellSize * zoom + panX;
        final otherY = (otherPick.row - 1) * cellSize * zoom + panY;

        // 거리 계산
        final distance = _distance(pickX, pickY, otherX, otherY);

        // 임계값 이내면 클러스터에 추가
        if (distance <= threshold) {
          clusterPicks.add(otherPick);
          processed.add(otherPick.id);
        }
      }

      // 클러스터 중심 계산
      final centerX =
          clusterPicks.map((p) => (p.col - 1) * cellSize * zoom + panX).reduce((a, b) => a + b) /
              clusterPicks.length;
      final centerY =
          clusterPicks.map((p) => (p.row - 1) * cellSize * zoom + panY).reduce((a, b) => a + b) /
              clusterPicks.length;

      clusters.add(
        PickCluster(
          picks: clusterPicks,
          centerPosition: Offset(centerX, centerY),
          id: 'cluster_${clusters.length}',
        ),
      );
    }

    return clusters;
  }

  /// DBSCAN 기반 클러스터링 (더 정교한 클러스터링)
  ///
  /// [picks] 픽 리스트
  /// [zoom] 현재 줌
  /// [panX] 현재 X 팬 오프셋
  /// [panY] 현재 Y 팬 오프셋
  /// [cellSize] 셀 크기 (기본 크기, zoom 미적용)
  /// [epsilon] DBSCAN epsilon (거리 임계값)
  /// [minPoints] 클러스터를 형성하기 위한 최소 포인트 수
  static List<PickCluster> dbscanCluster({
    required List<BlockModel> picks,
    required double zoom,
    required double panX,
    required double panY,
    required double cellSize,
    required double epsilon,
    int minPoints = 1,
  }) {
    if (picks.isEmpty) return [];

    final clusters = <List<BlockModel>>[];
    final visited = <String>{};
    final clustered = <String>{};

    // 각 픽에 대해 DBSCAN 수행
    for (final pick in picks) {
      if (visited.contains(pick.id)) continue;
      visited.add(pick.id);

      // 이웃 찾기
      final neighbors = _findNeighbors(
        pick,
        picks,
        epsilon,
        zoom,
        panX,
        panY,
        cellSize,
      );

      if (neighbors.length < minPoints) {
        // 노이즈 포인트 - 단일 클러스터로 추가
        if (!clustered.contains(pick.id)) {
          clusters.add([pick]);
          clustered.add(pick.id);
        }
        continue;
      }

      // 새 클러스터 생성
      final cluster = <BlockModel>[pick];
      clustered.add(pick.id);

      // 이웃을 클러스터에 추가
      final queue = List<BlockModel>.from(neighbors);
      while (queue.isNotEmpty) {
        final neighbor = queue.removeAt(0);

        if (!visited.contains(neighbor.id)) {
          visited.add(neighbor.id);

          final neighborNeighbors = _findNeighbors(
            neighbor,
            picks,
            epsilon,
            zoom,
            panX,
            panY,
            cellSize,
          );

          if (neighborNeighbors.length >= minPoints) {
            queue.addAll(neighborNeighbors);
          }
        }

        if (!clustered.contains(neighbor.id)) {
          cluster.add(neighbor);
          clustered.add(neighbor.id);
        }
      }

      clusters.add(cluster);
    }

    // PickCluster 객체로 변환
    return clusters.map((clusterPicks) {
      final centerX = clusterPicks
              .map((p) => (p.col - 1) * cellSize * zoom + panX)
              .reduce((a, b) => a + b) /
          clusterPicks.length;
      final centerY = clusterPicks
              .map((p) => (p.row - 1) * cellSize * zoom + panY)
              .reduce((a, b) => a + b) /
          clusterPicks.length;

      return PickCluster(
        picks: clusterPicks,
        centerPosition: Offset(centerX, centerY),
        id: 'cluster_${clusters.indexOf(clusterPicks)}',
      );
    }).toList();
  }

  /// 이웃 찾기
  static List<BlockModel> _findNeighbors(
    BlockModel pick,
    List<BlockModel> allPicks,
    double epsilon,
    double zoom,
    double panX,
    double panY,
    double cellSize,
  ) {
    final pickX = (pick.col - 1) * cellSize * zoom + panX;
    final pickY = (pick.row - 1) * cellSize * zoom + panY;

    return allPicks.where((other) {
      if (other.id == pick.id) return false;

      final otherX = (other.col - 1) * cellSize * zoom + panX;
      final otherY = (other.row - 1) * cellSize * zoom + panY;

      final distance = _distance(pickX, pickY, otherX, otherY);
      return distance <= epsilon;
    }).toList();
  }

  /// 유클리드 거리 계산
  static double _distance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return (dx * dx + dy * dy); // 제곱근 생략 (비교용이므로)
  }
}
