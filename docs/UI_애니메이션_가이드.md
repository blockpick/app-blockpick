# BlockPick UI 애니메이션 가이드

**작성일**: 2025-11-04
**버전**: 1.0.0

---

## 🎬 개요

BlockPick 앱의 UI 애니메이션 시스템에 대한 가이드입니다. 토스(Toss) 앱과 같은 고급 애니메이션 효과를 구현했습니다.

---

## 🎨 구현된 애니메이션

### 1. 게임 참가 로딩 오버레이

**파일**: `lib/features/game/widgets/game_join_loading_overlay.dart`

**특징**:
- 전체화면 그라데이션 배경 (Blue → Purple)
- 3단계 회전하는 원형 로딩 인디케이터
- 중앙 로켓 아이콘 (스케일 애니메이션)
- 5단계 진행 상황 표시
- 실시간 진행률 바 (shimmer 효과)
- 부드러운 페이드인/스케일 애니메이션

**애니메이션 상세**:
```dart
// 외부 원: 2초 동안 360도 회전 (반복)
.animate(onPlay: (controller) => controller.repeat())
.rotate(duration: 2000.ms)

// 중간 원: 1.5초 동안 역방향 회전 (반복)
.animate(onPlay: (controller) => controller.repeat())
.rotate(duration: 1500.ms, begin: 1, end: 0)

// 로켓 아이콘: 1초 동안 1.0 → 1.1배 스케일 (왕복 반복)
.animate(onPlay: (controller) => controller.repeat(reverse: true))
.scale(duration: 1000.ms, begin: Offset(1.0, 1.0), end: Offset(1.1, 1.1))

// 진행률 바: 1.5초 shimmer 효과
.animate().shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5))
```

**사용 방법**:
```dart
// 표시
GameJoinLoadingOverlay.show(context);

// 숨김
GameJoinLoadingOverlay.hide(context);
```

---

### 2. 게임 참가 결과 오버레이

**파일**: `lib/features/game/widgets/game_join_result_overlay.dart`

**성공 애니메이션**:
- 초록색 그라데이션 배경 (Green → Blue)
- 체크 아이콘 elastic 등장 (0 → 1 스케일)
- 8방향 파티클 효과 (페이드아웃 + 스케일)
- 흔들림 효과 (shake)

**실패 애니메이션**:
- 빨간색 그라데이션 배경 (Red → Pink)
- X 아이콘 등장
- 강한 흔들림 효과 (4Hz)

**애니메이션 상세**:
```dart
// 성공 아이콘
Container(...)
  .animate()
  .scale(
    delay: 100.ms,
    duration: 600.ms,
    begin: Offset(0, 0),
    end: Offset(1, 1),
    curve: Curves.elasticOut, // 튕기는 효과
  )
  .then()
  .shake(hz: 2, curve: Curves.easeInOut)

// 파티클 효과 (8개)
Container(...)
  .animate(onPlay: (controller) => controller.repeat())
  .fadeOut(duration: 2000.ms)
  .scale(
    begin: Offset(0.5, 0.5),
    end: Offset(2.0, 2.0),
    delay: Duration(milliseconds: index * 100), // 순차 실행
  )
```

**사용 방법**:
```dart
// 성공
GameJoinResultOverlay.showSuccess(
  context,
  entryId: 'entry-123',
  txHash: '0x...',
  onConfirm: () => print('확인'),
);

// 실패
GameJoinResultOverlay.showError(
  context,
  errorMessage: '에러 메시지',
  onRetry: () => print('재시도'),
);
```

---

### 3. 게임 참가 버튼

**파일**: `lib/features/game/widgets/game_join_button.dart`

**특징**:
- 그라데이션 배경 (Blue → Purple)
- Shimmer 효과 (2초 반복)
- 호버 시 1.02배 확대
- 클릭 시 시각적 피드백
- 그림자 효과

**애니메이션 상세**:
```dart
// Shimmer 효과
Container(...)
  .animate(onPlay: (controller) => controller.repeat(reverse: true))
  .shimmer(
    duration: 2000.ms,
    color: Colors.white.withOpacity(0.3),
  )

// 호버 효과
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
  ...
)
```

**사용 방법**:
```dart
GameJoinButton(
  gameId: 'game-123',
  selectedGameProductId: 'product-456',
  selectedRow: 100,
  selectedCol: 200,
  contractAddress: '0x...',
  onSuccess: () => print('성공!'),
)
```

---

### 4. 플로팅 게임 참가 버튼

**파일**: `lib/features/game/widgets/game_join_button.dart`

**특징**:
- 좌표 선택 시 슬라이드 인 (하단에서 위로)
- 선택 해제 시 슬라이드 아웃
- 300ms 부드러운 easeOut 곡선

**애니메이션 상세**:
```dart
AnimatedPositioned(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOut,
  bottom: hasSelection ? 24 : -100, // 선택 여부에 따라 위치 변경
  ...
  child: GameJoinButton(...)
    .animate()
    .slideY(begin: 1, end: 0, curve: Curves.easeOut)
    .fadeIn()
)
```

**사용 방법**:
```dart
Stack(
  children: [
    GameGridWidget(),

    GameJoinFloatingButton(
      gameId: 'game-123',
      selectedGameProductId: 'product-456',
      selectedRow: selectedRow, // null이면 자동 숨김
      selectedCol: selectedCol,
      contractAddress: '0x...',
    ),
  ],
)
```

---

### 5. 게임 참가 정보 카드

**파일**: `lib/features/game/widgets/game_join_button.dart`

**특징**:
- 페이드인 + 슬라이드업 등장
- 아이콘 색상 구분
- 부드러운 모서리

**애니메이션 상세**:
```dart
GameJoinInfoCard(...)
  .animate()
  .fadeIn(duration: 500.ms)
  .slideY(begin: 0.2, end: 0)
```

---

## 🎭 애니메이션 타이밍

### 기본 타이밍 가이드

| 동작 | 시간 | Curve |
|------|------|-------|
| 페이드인 | 300-500ms | Linear |
| 슬라이드 | 300-400ms | easeOut |
| 스케일 | 200-400ms | easeOut |
| 버튼 호버 | 200ms | easeInOut |
| 로딩 회전 | 1500-2000ms | Linear (반복) |
| Shimmer | 2000ms | Linear (반복) |
| Shake | 400-600ms | easeInOut |

### Elastic 효과 (성공 표시)

```dart
.scale(
  duration: 600.ms,
  curve: Curves.elasticOut,
)
```

### 순차 실행

```dart
List.generate(8, (index) {
  return Widget(...)
    .animate()
    .fadeIn(delay: Duration(milliseconds: index * 100));
})
```

---

## 📚 flutter_animate 주요 메서드

### 1. 기본 애니메이션

```dart
// 페이드인
.fadeIn(duration: 500.ms)

// 페이드아웃
.fadeOut(duration: 500.ms)

// 슬라이드
.slideY(begin: 1, end: 0) // 아래에서 위로
.slideX(begin: -1, end: 0) // 왼쪽에서 오른쪽으로

// 스케일
.scale(begin: Offset(0, 0), end: Offset(1, 1))

// 회전
.rotate(begin: 0, end: 1) // 0도 → 360도
```

### 2. 효과

```dart
// Shimmer (빛나는 효과)
.shimmer(duration: 2000.ms, color: Colors.white)

// Shake (흔들림)
.shake(hz: 4) // 주파수 4Hz

// Blur (흐림)
.blur(begin: Offset(0, 0), end: Offset(10, 10))
```

### 3. 제어

```dart
// 반복
.animate(onPlay: (controller) => controller.repeat())

// 왕복 반복
.animate(onPlay: (controller) => controller.repeat(reverse: true))

// 순차 실행
.fadeIn().then().slideY()

// 딜레이
.fadeIn(delay: 500.ms)
```

---

## 🎨 색상 그라데이션

### 성공 (초록 → 파랑)

```dart
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.green.withOpacity(0.95),
    AppColors.blue.withOpacity(0.95),
  ],
)
```

### 실패 (빨강 → 핑크)

```dart
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.red.withOpacity(0.95),
    AppColors.pink.withOpacity(0.95),
  ],
)
```

### 로딩 (파랑 → 보라)

```dart
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.blue.withOpacity(0.95),
    AppColors.purple.withOpacity(0.95),
  ],
)
```

---

## 💡 베스트 프랙티스

### 1. 성능 고려사항

```dart
// ❌ 나쁜 예: 무거운 애니메이션
.blur(begin: Offset(0, 0), end: Offset(50, 50))
.shimmer(duration: 100.ms) // 너무 빠름

// ✅ 좋은 예: 최적화된 애니메이션
.fadeIn(duration: 300.ms)
.slideY(begin: 0.2, end: 0)
```

### 2. 사용자 경험

```dart
// ❌ 나쁜 예: 너무 긴 애니메이션
.fadeIn(duration: 2000.ms) // 2초는 너무 길다

// ✅ 좋은 예: 적절한 시간
.fadeIn(duration: 300.ms)
```

### 3. 일관성 유지

```dart
// ✅ 같은 타입의 애니메이션은 같은 시간 사용
.fadeIn(duration: 300.ms)
.slideY(begin: 0.2, end: 0)
```

---

## 🎯 다음 단계

1. [ ] 게임 리스트 카드 애니메이션
2. [ ] 페이지 전환 애니메이션
3. [ ] 미니맵 애니메이션
4. [ ] 알림 토스트 애니메이션
5. [ ] 스켈레톤 로딩 애니메이션

---

## 📖 참고 자료

- [flutter_animate 공식 문서](https://pub.dev/packages/flutter_animate)
- [Material Motion 가이드](https://material.io/design/motion)
- [토스 디자인 시스템](https://toss.im/design)

---

**마지막 업데이트**: 2025-11-04
