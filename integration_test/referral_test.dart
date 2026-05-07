// integration_test/referral_test.dart
// TC-005-001: 친구초대 탭 진입 및 초대 링크 노출
// TC-005-002: 초대 링크 복사
// TC-005-003: 공유 시트 열기
// TC-005-005: 초대 실적 내역 확인
// TC-005-007: 초대 가이드 확인
//
// 실행 방법:
//   patrol test -t integration_test/referral_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'TC-005-001: 친구초대 탭 → 링크 + 요약 + 공유 버튼 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('친구초대')).tap();
      await $.pumpAndSettle();

      expect(find.byKey(const ValueKey('referral_summary')), findsOneWidget);
      expect(find.byKey(const ValueKey('referral_link_text')), findsOneWidget);
      expect(find.byKey(const ValueKey('copy_link_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('share_button')), findsOneWidget);
    },
  );

  patrolTest(
    'TC-005-002: 초대 링크 복사 → 토스트 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('친구초대')).tap();
      await $.pumpAndSettle();

      await $(find.byKey(const ValueKey('copy_link_button'))).tap();
      await $.pumpAndSettle();

      expect(find.textContaining('링크가 복사'), findsOneWidget);
    },
  );

  patrolTest(
    'TC-005-003: 공유 버튼 탭 → 네이티브 공유 시트 열림',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('친구초대')).tap();
      await $.pumpAndSettle();

      await $(find.byKey(const ValueKey('share_button'))).tap();
      await $.pumpAndSettle();

      // 네이티브 공유 시트 닫기 (테스트 안정성)
      await $.native.pressBack();
    },
  );

  patrolTest(
    'TC-005-005: 초대 실적 내역 — 항목 노출 확인',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginAsUserWithReferrals($);

      await $(find.text('친구초대')).tap();
      await $.pumpAndSettle();

      await $.scrollUntilVisible(
        finder: find.byKey(const ValueKey('referral_history_list')),
        view: find.byType(SingleChildScrollView),
      );

      expect(
          find.byKey(const ValueKey('referral_history_list')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('referral_history_item')), findsWidgets);
    },
  );

  patrolTest(
    'TC-005-007: 초대 가이드 섹션 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('친구초대')).tap();
      await $.pumpAndSettle();

      await $.scrollUntilVisible(
        finder: find.byKey(const ValueKey('referral_guide_section')),
        view: find.byType(SingleChildScrollView),
      );

      expect(
          find.byKey(const ValueKey('referral_guide_section')), findsOneWidget);
      expect(find.textContaining('초대 방법'), findsOneWidget);
    },
  );
}

Future<void> _loginHelper(PatrolIntegrationTester $) async {
  // TODO: staging 토큰 주입
}

Future<void> _loginAsUserWithReferrals(PatrolIntegrationTester $) async {
  // TODO: 초대 이력 있는 staging 계정 토큰 주입
}

Widget _buildApp() {
  return const MaterialApp(
    home: Scaffold(body: Center(child: Text('BlockPick E2E Stub'))),
  );
}
