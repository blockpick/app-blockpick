// integration_test/main.dart
// Patrol 통합 테스트 진입점
//
// 각 테스트 파일을 개별 실행할 때는 이 파일이 아닌
// patrol test -t integration_test/<file>_test.dart 를 사용합니다.
// 이 파일은 전체 suite 실행 시 앱 초기화에 사용됩니다.

import 'package:flutter/material.dart';

// TODO: 실제 앱 진입점으로 교체
// import 'package:blockpick_flutter/main.dart' as app;

void main() {
  // app.main();
  runApp(
    const MaterialApp(
      title: 'BlockPick E2E',
      home: Scaffold(
        body: Center(
          child: Text('BlockPick E2E Test Runner'),
        ),
      ),
    ),
  );
}
