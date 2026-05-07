// integration_test/points_test.dart
// TC-004-001: 포인트 잔액 확인
// TC-004-002: 출석체크 → 잔액 증가
// TC-004-003: 당일 재출석 시도 → 차단
// TC-004-007: 광고 시청 한도 초과
//
// 실행 방법:
//   patrol test -t integration_test/points_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'TC-004-001: 포인트 잔액 확인',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.text('마이')).tap();
      await $.pumpAndSettle();
      await $(find.byKey(const ValueKey('point_wallet_entry'))).tap();
      await $.pumpAndSettle();

      expect(find.byKey(const ValueKey('point_balance_text')), findsOneWidget);
      expect(find.byKey(const ValueKey('point_history_list')), findsOneWidget);
    },
  );

  patrolTest(
    'TC-004-002: 출석체크 → 포인트 증가 확인',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginHelper($);

      await $(find.byKey(const ValueKey('attendance_check_entry'))).tap();
      await $.pumpAndSettle();

      // 출석 전 잔액 텍스트 캡처
      final beforeFinder = find.byKey(const ValueKey('point_balance_text'));
      expect(beforeFinder, findsOneWidget);
      final beforeWidget = beforeFinder.evaluate().first.widget as Text;
      final before =
          int.tryParse(beforeWidget.data?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;

      await $(find.byKey(const ValueKey('attendance_button'))).tap();
      await $.pumpAndSettle();

      expect(find.textContaining('출석체크 완료'), findsOneWidget);

      // 출석 후 잔액 확인
      final afterWidget =
          find.byKey(const ValueKey('point_balance_text')).evaluate().first.widget as Text;
      final after =
          int.tryParse(afterWidget.data?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
      expect(after, greaterThan(before));
    },
  );

  patrolTest(
    'TC-004-003: 당일 재출석 시도 → 버튼 비활성 + 안내 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      // 오늘 이미 출석 완료 상태 계정 사용
      await _loginAsAlreadyCheckedUser($);

      await $(find.byKey(const ValueKey('attendance_check_entry'))).tap();
      await $.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('attendance_button_disabled')), findsOneWidget);
      expect(find.textContaining('이미 출석체크를 완료'), findsOneWidget);
    },
  );

  patrolTest(
    'TC-004-007: 광고 시청 한도 초과 → 비활성 안내',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());
      await _loginAsAdLimitExceededUser($);

      await $(find.byKey(const ValueKey('ad_reward_entry'))).tap();
      await $.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('watch_ad_button_disabled')), findsOneWidget);
      expect(find.textContaining('오늘 광고 시청 횟수를 모두 사용'), findsOneWidget);
    },
  );
}

Future<void> _loginHelper(PatrolIntegrationTester $) async {
  // TODO: staging 일반 계정 토큰 주입
}

Future<void> _loginAsAlreadyCheckedUser(PatrolIntegrationTester $) async {
  // TODO: 오늘 출석 완료 staging 계정 토큰 주입
}

Future<void> _loginAsAdLimitExceededUser(PatrolIntegrationTester $) async {
  // TODO: 광고 한도 초과 staging 계정 토큰 주입
}

Widget _buildApp() {
  return const MaterialApp(
    home: Scaffold(body: Center(child: Text('BlockPick E2E Stub'))),
  );
}
