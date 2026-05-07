# BlockpickSummary 스키마 확장 요청서 (S22 마이그레이션 후속)

**작성일**: 2026-05-07  
**작성자**: FE팀 (S22 game_provider → blockpick_provider 마이그레이션)  
**상태**: 백엔드 협의 대기

---

## 배경

game_provider(구 `getGames` GraphQL) → blockpick_provider(신 `blockpicks` GraphQL)  
마이그레이션 중 BlockpickSummary에 부재한 필드로 인해 클라이언트에서 Mock 값을 사용 중.  
아래 필드가 추가되어야 Mock 값을 실제 데이터로 교체할 수 있음.

---

## §1. 필수 추가 필드 (Critical)

### 1.1 `gameType: String!`

| 항목 | 내용 |
|------|------|
| 타입 | `String` (enum: `DAILY`, `SELECT`, `VIBE`, `PRIME`) |
| 필요 이유 | 화면별 게임 타입 필터링 (daily_screen, game_list_screen, vibe_game_list_screen 등) |
| 현재 상태 | 클라이언트에서 `mockGameType` 기본값으로 모든 블록픽을 DAILY로 표시 중 |
| 호출처 | `blockpicksByGameTypeProvider` (blockpick_provider.dart) |

**GraphQL 스키마 예시:**
```graphql
type BlockpickSummary {
  # 기존 필드 ...
  gameType: GameType!  # DAILY | SELECT | VIBE | PRIME
}

enum GameType {
  DAILY
  SELECT
  VIBE
  PRIME
}
```

**쿼리 필터 추가:**
```graphql
query Blockpicks($input: BlockpickFilterInput) {
  blockpicks(input: $input) { ... }
}

input BlockpickFilterInput {
  # 기존 필드 ...
  gameType: GameType  # 추가 필요
}
```

---

### 1.2 `participants: Int`

| 항목 | 내용 |
|------|------|
| 타입 | `Int` (현재 참가자 수) |
| 필요 이유 | `GameRound.participants` 매핑, 목록 화면의 "N명 참여 중" 표시 |
| 현재 상태 | `totalEntryCount`(double)를 int로 캐스팅하여 임시 사용 중. 의미 불일치 가능성 있음 |
| 참고 | `totalEntryCount`가 실제 현재 참가자 수와 동일하면 필드 추가 불필요 — 백엔드 확인 필요 |

---

## §2. 권장 추가 필드 (Important)

### 2.1 `maxEntries: Int`

| 항목 | 내용 |
|------|------|
| 타입 | `Int` (최대 참가자 수) |
| 필요 이유 | `GameRound.maxParticipants` 매핑, PRIME 이벤트 카드의 "N/M" 표시 |
| 현재 상태 | 클라이언트에서 `0`으로 하드코딩 → "0/0" 으로 표시됨 |

---

### 2.2 `currency: String`

| 항목 | 내용 |
|------|------|
| 타입 | `String` (예: `P`, `JPY`) |
| 필요 이유 | 다국어 통화 표시 지원 |
| 현재 상태 | 클라이언트에서 `'P'`로 하드코딩 |

---

## §3. 가격 단가 정책 확인 필요

현재 클라이언트의 임시 변환 규칙 (`blockpick_to_game_adapter.dart`):

```dart
// freeEntryQuota → entryFee(P) 변환 임시 규칙
switch (freeEntryQuota) {
  case 1:  → 25P
  case 2, 3: → 40P
  default (0): → 100P
  default (>3): → 40P
}
```

**확인 요청:**
- 위 규칙이 기획 단가 정책과 일치하는지 확인
- 또는 BlockpickSummary에 `entryFeePoint: Int` 필드 추가로 단순화 가능

---

## §4. 재검증 필요 화면 목록

백엔드 필드 추가 후 아래 파일의 TODO 주석을 제거하고 재검증:

| 파일 | TODO 내용 |
|------|----------|
| `lib/providers/blockpick_provider.dart` | gameType 필터 파라미터 추가 |
| `lib/data/blockpick/blockpick_to_game_adapter.dart` | Mock gameType 제거, maxEntries 실제 값 사용 |
| `lib/features/daily/daily_screen.dart` | gameType 필터 검증 |
| `lib/features/daily_legacy/daily_legacy_screen.dart` | maxParticipants 표시 검증 |
| `lib/features/game/game_list_screen.dart` | gameType 분기 필터 검증 |
| `lib/features/game/toss_game_list_screen.dart` | gameType 분기 필터 검증 |
| `lib/features/game/vibe_game_list_screen.dart` | VIBE 타입 필터 검증 |
| `lib/features/home/new_home_screen.dart` | DAILY/SELECT/PRIME 분기 검증 |
| `lib/features/more/unity/unity_game_select_screen.dart` | gameProducts 매핑 검증 |

---

## §5. 참고 문서

- `docs/game_provider_migration_design.md` — §6 백엔드 요청사항 (S22 사전 분석)
- `lib/data/blockpick/blockpick_to_game_adapter.dart` — 어댑터 변환 로직
- `lib/providers/blockpick_provider.dart` — `blockpicksByGameTypeProvider` 구현
