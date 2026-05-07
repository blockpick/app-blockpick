// integration_test/entry_flow_test.dart
// TC-003-001: 무료 1회 블록 선택 완료
// TC-003-002: 이미 참여 완료 후 재참여 시도
// TC-003-006: 미당첨 결과 화면
// TC-003-010: 참여 완료 후 참여내역 탭 확인
//
// 실행 방법:
//   patrol test -t integration_test/entry_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'TC-003-001: 무료 1회 블록 선택 → 참여 완료 화면',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);
      await _navigateToFirstBlockpick($);

      await $(find.text('지금 참여하기')).tap();
      await $.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('block_selection_screen')), findsOneWidget);

      await $(find.byKey(const ValueKey('block_cell_available'))).first.tap();
      await $.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('confirm_button_active')), findsOneWidget);
      await $(find.text('선택 확정')).tap();
      await $.pumpAndSettle();

      expect(find.byKey(const ValueKey('entry_result_screen')), findsOneWidget);

      final hasResult =
          find.textContaining('참여 완료').evaluate().isNotEmpty ||
              find.textContaining('당첨').evaluate().isNotEmpty ||
              find.textContaining('대기').evaluate().isNotEmpty;
      expect(hasResult, isTrue);
      expect(find.text('내 참여내역 보기'), findsOneWidget);
    },
  );

  patrolTest(
    'TC-003-002: 이미 참여 완료 → 추가 참여 CTA 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);
      await _navigateToParticipatedBlockpick($);

      await $.pumpAndSettle();

      final hasAdditionalCta =
          find.text('친구 초대하고 기회 받기').evaluate().isNotEmpty ||
              find.textContaining('추가 참여').evaluate().isNotEmpty;
      expect(hasAdditionalCta, isTrue);
      expect(
        find.byKey(const ValueKey('join_button_disabled')),
        findsOneWidget,
      );
    },
  );

  patrolTest(
    'TC-003-006: 미당첨 결과 화면 → 재참여 CTA 3종 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);
      await _navigateToLostResultScreen($);
      await $.pumpAndSettle();

      expect(find.text('친구 초대하고 다시 참여'), findsOneWidget);
      expect(find.text('광고 보고 다시 참여'), findsOneWidget);
      expect(find.text('미션하고 다시 참여'), findsOneWidget);
    },
  );

  patrolTest(
    'TC-003-010: 참여 완료 → 참여내역 탭 이동 → 카드 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);
      await _navigateToFirstBlockpick($);

      await $(find.text('지금 참여하기')).tap();
      await $(find.byKey(const ValueKey('block_cell_available'))).first.tap();
      await $(find.text('선택 확정')).tap();
      await $.pumpAndSettle();

      await $(find.text('내 참여내역 보기')).tap();
      await $.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('participation_screen')), findsOneWidget);
      expect(find.byKey(const ValueKey('participation_card')), findsWidgets);
    },
  );
}

Future<void> _loginHelper(PatrolIntegrationTester $) async {
  // TODO: staging 토큰 주입
}

Future<void> _navigateToFirstBlockpick(PatrolIntegrationTester $) async {
  await $(find.text('블록픽')).tap();
  await $.pumpAndSettle();
  await $(find.byKey(const ValueKey('blockpick_card'))).first.tap();
  await $.pumpAndSettle();
}

Future<void> _navigateToParticipatedBlockpick(PatrolIntegrationTester $) async {
  await $(find.text('참여내역')).tap();
  await $.pumpAndSettle();
  await $(find.byKey(const ValueKey('participation_card'))).first.tap();
  await $.pumpAndSettle();
}

Future<void> _navigateToLostResultScreen(PatrolIntegrationTester $) async {
  // TODO: staging mock 미당첨 결과 화면으로 이동
}

Widget _buildApp() {
  return const MaterialApp(
    home: Scaffold(body: Center(child: Text('BlockPick E2E Stub'))),
  );
}
