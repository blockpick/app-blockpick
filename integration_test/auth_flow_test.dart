// integration_test/auth_flow_test.dart
// TC-001-003: 이메일 로그인 → 홈 진입
// TC-001-004: 잘못된 비밀번호 → 오류 메시지
// TC-001-012: 비로그인 참여 시도 → 로그인 유도
//
// 실행 방법:
//   patrol test -t integration_test/auth_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  const testEmail = 'e2e_test@blockpick.io';
  const testPassword = 'E2eTest1234!';

  patrolTest(
    'TC-001-003: 이메일 로그인 성공 → 홈 탭 5개 탭 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());

      await $(find.text('이메일로 로그인')).tap();

      await $(find.byKey(const ValueKey('email_field'))).enterText(testEmail);
      await $(find.byKey(const ValueKey('password_field')))
          .enterText(testPassword);
      await $(find.text('로그인')).tap();

      await $.pumpAndSettle();

      expect(find.text('홈'), findsOneWidget);
      expect(find.text('블록픽'), findsOneWidget);
      expect(find.text('참여내역'), findsOneWidget);
      expect(find.text('친구초대'), findsOneWidget);
      expect(find.text('마이'), findsOneWidget);
    },
  );

  patrolTest(
    'TC-001-004: 잘못된 비밀번호 → 오류 메시지 노출',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());

      await $(find.text('이메일로 로그인')).tap();
      await $(find.byKey(const ValueKey('email_field'))).enterText(testEmail);
      await $(find.byKey(const ValueKey('password_field')))
          .enterText('WrongPass999!');
      await $(find.text('로그인')).tap();

      await $.pumpAndSettle();

      expect(find.textContaining('올바르지 않습니다'), findsOneWidget);
    },
  );

  patrolTest(
    'TC-001-012: 비로그인 → 참여하기 탭 → 로그인 유도',
    ($) async {
      await $.pumpWidgetAndSettle(_buildApp());

      // 로그인 없이 참여 버튼 탭 시도
      // 실제 앱에서는 go_router 딥링크로 블록픽 상세 직접 진입
      await $(find.byKey(const ValueKey('join_button_unauthenticated'))).tap();
      await $.pumpAndSettle();

      expect(find.textContaining('로그인'), findsWidgets);
    },
  );
}

Widget _buildApp() {
  // TODO: 실제 앱 진입점으로 교체
  // import 'package:blockpick_flutter/main.dart' as app;
  // return app.buildApp();
  return const MaterialApp(
    home: Scaffold(body: Center(child: Text('BlockPick E2E Stub'))),
  );
}
