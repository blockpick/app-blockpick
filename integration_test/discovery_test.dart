// integration_test/discovery_test.dart
// TC-002-001: 홈 탭 섹션 노출
// TC-002-002: 블록픽 탭 리스트 로드
// TC-002-003: 키워드 검색
// TC-002-005: 카테고리 필터 — 쇼핑
// TC-002-009: 블록픽 상세 진입
//
// 실행 방법:
//   patrol test -t integration_test/discovery_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'TC-002-001: 홈 탭 진입 → 핵심 섹션 4개 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('홈')).tap();
      await $.pumpAndSettle();

      // 스크롤하며 섹션 확인
      for (final section in ['추천 블록픽', '진행 중', '신규 오픈', '마감 임박']) {
        await $.scrollUntilVisible(
          finder: find.textContaining(section),
          view: find.byType(SingleChildScrollView),
        );
        expect(find.textContaining(section), findsOneWidget);
      }
    },
  );

  patrolTest(
    'TC-002-002: 블록픽 탭 → 리스트 + UI 요소 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('블록픽')).tap();
      await $.pumpAndSettle();

      expect(find.text('전체'), findsOneWidget);
      expect(find.text('쇼핑'), findsOneWidget);
      expect(find.byKey(const ValueKey('sort_dropdown')), findsOneWidget);
      expect(find.byKey(const ValueKey('blockpick_card')), findsWidgets);
    },
  );

  patrolTest(
    'TC-002-003: 키워드 검색 → 결과 또는 빈 상태 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('블록픽')).tap();
      await $(find.byKey(const ValueKey('search_bar'))).tap();
      await $(find.byKey(const ValueKey('search_field'))).enterText('스타벅스');
      await $.pumpAndSettle();

      final hasResults =
          find.byKey(const ValueKey('blockpick_card')).evaluate().isNotEmpty;
      final hasEmpty =
          find.textContaining('검색 결과가 없습니다').evaluate().isNotEmpty;
      expect(hasResults || hasEmpty, isTrue,
          reason: '검색 결과 카드 또는 빈 상태 중 하나가 노출되어야 함');
    },
  );

  patrolTest(
    'TC-002-005: 카테고리 필터 쇼핑 선택 → 칩 강조',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('블록픽')).tap();
      await $(find.text('쇼핑')).tap();
      await $.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('category_chip_쇼핑_selected')),
        findsOneWidget,
      );
    },
  );

  patrolTest(
    'TC-002-009: 블록픽 카드 탭 → 상세 화면 + CTA 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('홈')).tap();
      await $(find.byKey(const ValueKey('blockpick_card'))).first.tap();
      await $.pumpAndSettle();

      expect(find.byKey(const ValueKey('blockpick_detail_screen')),
          findsOneWidget);
      expect(find.text('지금 참여하기'), findsOneWidget);
    },
  );
}

Future<void> _loginHelper(PatrolIntegrationTester $) async {
  // TODO: staging 토큰 주입 또는 로그인 흐름 실행
}

Widget _buildApp() {
  return const MaterialApp(
    home: Scaffold(body: Center(child: Text('BlockPick E2E Stub'))),
  );
}
