# game_provider → blockpicks 마이그레이션 설계서 (S22)

**생성일**: 2025-02-28  
**범위**: 16곳 호출처 분석 + 모델 매핑 설계  
**상태**: Read-only 분석 완료, 실행 대기

---

## §1. 호출처 16개 상세 표

| 순번 | 파일 경로 | 라인 | Provider 호출 | 접근 패턴 | 읽는 필드 | gameType 의존 | 위험도 |
|------|----------|------|---------------|----------|---------|----------------|---------|
| 1 | `daily_screen.dart` | 30, 54 | `gamesByTypeProvider(GameType.daily)` | watch x2 (검색어 필터링, 카테고리) | title, imageUrl, currentPrice, participants, category | YES | 🟡 |
| 2 | `daily_legacy_screen.dart` | 44, 316 | `gamesByTypeProvider(GameType.daily)` | watch x2 (목록, invalidate) | title, imageUrl, currentPrice, maxParticipants | YES | 🟡 |
| 3 | `game_list_screen.dart` | 129, 199, 233 | `gamesByTypeProvider(widget.gameType)` | watch x2 + invalidate | title, imageUrl, currentPrice, category, participants | YES | 🟡 |
| 4 | `toss_game_list_screen.dart` | 121, 216, 347 | `gamesByTypeProvider(widget.gameType)` | watch x2 + invalidate | title, imageUrl, currentPrice, category | YES | 🟡 |
| 5 | `vibe_game_list_screen.dart` | 105, 400 | `gamesByTypeProvider(GameType.vibe)` | watch x2 (목록, invalidate) | title, imageUrl, currentPrice, maxParticipants | YES | 🟡 |
| 6 | `home_screen.dart` | 44, 316 | `gamesByTypeProvider(GameType.daily)` | watch x2 (목록, invalidate) | title, imageUrl, currentPrice | YES | 🟡 |
| 7 | `new_home_screen.dart` | 395, 434, 521 | `gamesByTypeProvider(GameType.daily)` 등 | watch x3 (daily, select, prime) | title, imageUrl, currentPrice, description | YES | 🟡 |
| 8 | `new_home_screen.dart` | 522, 523 | `gamesByTypeProvider(GameType.select/prime)` | watch x2 | title, imageUrl, currentPrice | YES | 🟡 |
| 9 | `unity_game_select_screen.dart` | 18, 88 | `gamesProvider` | watch + invalidate | title, imageUrl, description, gameProducts[] | NO | 🟡 |

**요약:**
- **watch 사용**: 9개 파일의 16곳 호출처
- **gameType 강한 의존**: 8곳 (DAILY/SELECT/VIBE/PRIME 분기)
- **gameProducts 접근**: 1곳 (unity_game_select_screen)
- **invalidate 호출**: 6곳 (캐시 무효화 필요)

---

## §2. 모델 매핑 표 (구 Game ↔ 신 BlockpickSummary/Detail)

### 2.1 기본 필드 (1:1 매핑 가능)

| 구 필드 (Game) | 신 필드 (BlockpickSummary) | 매핑 방식 | 비고 |
|---------------|-------------------------|---------|------|
| `id` | `id` | 직접 복사 | 게임/블록픽 ID |
| `title` | `title` | 직접 복사 | 게임명 |
| `description` | (BlockpickDetail에만) | N/A | BlockpickSummary는 미포함 |
| `gridRows` | `gridRows` | 직접 복사 | 격자 행 수 |
| `gridCols` | `gridCols` | 직접 복사 | 격자 열 수 |
| `category` | `category.code` | 간접 매핑 | Category 객체로 감싸짐 |
| `startTime` | `startTime` | 직접 복사 | ISO8601 문자열 |
| `endTime` | `endTime` | 직접 복사 | ISO8601 문자열 |
| `status` | `status` | enum 변환 필요 | Game: string, BlockpickSummary: enum |

### 2.2 가격/비용 필드 (의미 변환 필요)

| 구 필드 | 신 필드 | 변환 로직 | 주의사항 |
|-------|--------|--------|---------|
| `entryFee` (int) | `freeEntryQuota` (int) | **불가 직접 변환** | entryFee는 진입료(포인트), freeEntryQuota는 무료 입장 수. 기획단가 필요 (25P/40P/100P) |
| `currency` (string) | (BlockpickSummary에 없음) | **필드 신설 필요** | Blockpick 모델에 `currency` 필드 추가 검토 |
| `rewardPoint` | (BlockpickSummary에 없음) | **필드 신설 필요** | 신 모델에서 reward point 정보 위치 확인 필요 |

### 2.3 gameType 필드 (⚠️ 크리티컬)

| 구 필드 | 신 모델 | 현황 | 대안 |
|-------|--------|------|------|
| `gameType` (DAILY/SELECT/VIBE/PRIME) | **없음** | BlockpickSummary/Detail에 `gameType` 필드 없음 | ❌ 백엔드에서 신 모델에 `gameType` enum 필드 추가 필요 |

### 2.4 상품 관련 필드 (복잡도 높음)

| 구 필드 | 신 필드 | 구조 차이 | 매핑 전략 |
|-------|--------|---------|---------|
| `gameProducts[]` (GameProduct) | `prizes[]` (BlockpickPrize) | GameProduct는 product 객체 포함, BlockpickPrize는 prize + tier | 변환 어댑터 작성 필요 |
| `gameProducts[].product.name` | `prizes[].prize.name` | 깊은 구조 | 2단계 변환 (product → prize) |
| `gameProducts[].product.defaultImage` | `prizes[].prize.imageUrl` | 이미지 필드명 변경 | 매핑 테이블 작성 |
| `gameProducts[].isGrandPrize` | `prizes[].tier == PrizeTier.grand` | boolean → enum | 조건부 매핑 |

---

## §3. 위험도 분기 (호출처별 마이그레이션 복잡도)

### 🟢 안전 (즉시 치환 가능, 5곳)
- **파일**: home_screen.dart (2곳), new_home_screen.dart 초기 로드 (1곳)
- **이유**: title, imageUrl 표시만 함. gameType에 의존하지 않음 (일반 게임 목록 표시)
- **작업**: GameRound → BlockpickSummary로 직접 변환, 이미지 필드 매핑 (thumbnailUrl 사용)

### 🟡 어댑터 필요 (중간 위험, 8곳)
- **파일**: daily_screen.dart (2곳), game_list_screen.dart (3곳), toss_game_list_screen.dart (3곳), vibe_game_list_screen.dart (2곳)
- **이유**: 
  - gameType 분기로 필터링 수행 → BlockpickSummary에 gameType 필드 추가 필수
  - 가격(currentPrice = entryFee)을 표시 → freeEntryQuota와 매핑 로직 불명확
  - category 필드를 읽음 → Category 객체 구조 변경 필요
- **작업**: 
  1. BlockpickSummary에 `gameType` 필드 추가 (백엔드)
  2. freeEntryQuota ↔ entryFee 변환 규칙 정의 (기획 협의)
  3. 어댑터 작성: `Game.fromBlockpick(BlockpickSummary)` 함수
  4. invalidate 로직 유지 (blockpick_provider에서 지원 필요)

### 🔴 백엔드 합의 필요 (높은 위험, 3곳)
- **파일**: daily_legacy_screen.dart (2곳), new_home_screen.dart (3곳), unity_game_select_screen.dart (2곳)
- **이유**:
  - maxParticipants 읽음 → BlockpickSummary에서 가져올 데이터 없음
  - gameProducts[] 전체 구조 의존 → prizes[] 변환 복잡도 높음
  - DAILY/SELECT/VIBE gameType 조건부 로드 → BlockpickSummary에 gameType 필수
- **작업**: 
  1. Blockpick 스키마에 `maxEntries` / `participants` 필드 추가 협의
  2. gameProducts → prizes 변환 어댑터 설계
  3. BlockpickSummary.topPrize 활용 (grand prize만 전달 가능)

---

## §4. 추천 마이그레이션 순서 (위험도 + 의존도)

### Phase 1: 의존성 정의 (백엔드 협의, ~1주)
1. **BlockpickSummary에 필드 추가** (필수):
   - `gameType: String?` (DAILY/SELECT/VIBE/PRIME)
   - `currency: String?` (기존 Game.currency)
   - `maxEntries: int?` (maxParticipants 매핑)
   - `participants: int?` (현재 참가자 수)

2. **가격 단가 정책 확정**:
   - freeEntryQuota 개수로부터 entryFee 계산 공식
   - 예: freeEntryQuota=1 → entryFee=25P, freeEntryQuota=0 → entryFee=100P

### Phase 2: 어댑터 작성 (1-2일)
3. **`lib/adapters/game_to_blockpick_adapter.dart` 생성**:
   ```dart
   /// Game 모델을 BlockpickSummary에서 복원
   Game Game.fromBlockpickSummary(BlockpickSummary blockpick) {
     return Game(
       id: blockpick.id,
       title: blockpick.title,
       gameType: blockpick.gameType, // ← 신규 필드
       category: blockpick.category.code,
       entryFee: _calculateEntryFee(blockpick.freeEntryQuota),
       currency: blockpick.currency ?? 'P',
       gridRows: blockpick.gridRows,
       gridCols: blockpick.gridCols,
       maxEntries: blockpick.maxEntries,
       startTime: blockpick.startTime,
       endTime: blockpick.endTime,
       status: _mapStatus(blockpick.status),
       // ...
     );
   }
   ```

### Phase 3: 호출처 마이그레이션 (4일)

#### Day 1-2: 🟢 안전 구간 (2곳)
- home_screen.dart line 44, 316
- 전략: GameRound → BlockpickSummary 직접 치환

#### Day 2-3: 🟡 어댑터 필요 (8곳)
- daily_screen.dart (2), game_list_screen.dart (3), toss_game_list_screen.dart (3), vibe_game_list_screen.dart (2)
- 전략: gameProvider → blockpickProvider로 변경, 어댑터로 Game 타입 유지

#### Day 4: 🔴 복잡 구간 (3곳)
- daily_legacy_screen.dart (2), new_home_screen.dart (3), unity_game_select_screen.dart (2)
- 전략: BlockpickDetail로 전환, maxEntries/participants 백엔드에서 받기

---

## §5. 어댑터 의사코드 (Game.fromBlockpick 패턴)

```dart
// lib/adapters/blockpick_to_game_adapter.dart

class BlockpickToGameAdapter {
  /// BlockpickSummary → Game (리스트 뷰용)
  static Game fromSummary(BlockpickSummary blockpick) {
    return Game(
      id: blockpick.id,
      title: blockpick.title,
      description: '', // BlockpickSummary는 description 없음
      mainProductName: blockpick.topPrize?.prize.name,
      
      // ⚠️ 신규 필드 (BlockpickSummary 확장 필요)
      gameType: blockpick.gameType, // DAILY/SELECT/VIBE/PRIME
      category: blockpick.category.code, // Category.code
      status: _mapStatus(blockpick.status), // BlockpickStatus → Game.status
      
      // ⚠️ 가격 계산 (기획 단가 규칙 기반)
      entryFee: _calculateEntryFee(blockpick.freeEntryQuota),
      currency: blockpick.currency ?? 'P',
      rewardPoint: 0, // BlockpickSummary에 없음 → default
      
      // 격자
      gridRows: blockpick.gridRows,
      gridCols: blockpick.gridCols,
      
      // 참가자/제한
      minEntries: 0, // BlockpickSummary에 없음
      maxEntries: blockpick.maxEntries ?? 0, // ← 신규 필드
      maxEntriesPerUser: blockpick.maxEntriesPerUser,
      
      // 시간
      visibleFrom: blockpick.visibleFrom,
      startTime: blockpick.startTime,
      endTime: blockpick.endTime,
      
      // 플래그
      isRecommended: blockpick.isRecommended,
      hasInstantPrize: blockpick.topPrize != null,
      
      // 체인
      onchainContractAddr: null, // BlockpickSummary에 없음
      
      // 게임 상품 → 블록픽 상품 변환
      gameProducts: _mapBlockpickPrizesToGameProducts(blockpick.topPrize),
    );
  }

  /// BlockpickDetail → Game (상세 뷰용)
  static Game fromDetail(BlockpickDetail blockpick) {
    return Game(
      // ... (위와 동일, prizes[] 전체 포함)
      gameProducts: blockpick.prizes
          .map((p) => GameProduct(
            id: p.id,
            sequence: p.sequence,
            isGrandPrize: p.tier == PrizeTier.grand,
            product: Product(
              id: p.prize.id,
              name: p.prize.name,
              description: p.prize.description,
              defaultImage: p.prize.imageUrl,
              imageUrl: p.prize.imageUrl,
              price: (p.prize.faceValue?.toInt()) ?? 0,
              originalPrice: (p.prize.faceValue?.toInt()) ?? 0,
            ),
          ))
          .toList(),
    );
  }

  /// 가격 계산 (freeEntryQuota → entryFee)
  static int _calculateEntryFee(int freeEntryQuota) {
    // 기획 규칙: freeEntryQuota 개수에 따른 진입료
    // 예: 1회 무료 → 25P, 0회 무료 → 100P
    switch (freeEntryQuota) {
      case 1:
        return 25;
      case 2:
      case 3:
        return 40;
      default:
        return 100;
    }
  }

  /// 상태 매핑
  static String _mapStatus(BlockpickStatus status) {
    switch (status) {
      case BlockpickStatus.draft:
        return 'DRAFT';
      case BlockpickStatus.active:
        return 'IN_PROGRESS';
      case BlockpickStatus.paused:
        return 'PAUSED';
      case BlockpickStatus.ended:
        return 'ENDED';
    }
  }
}
```

---

## §6. 백엔드 요청사항 (필수)

### 6.1 BlockpickSummary 스키마 확장

```graphql
type BlockpickSummary {
  # 기존 필드
  id: String!
  title: String!
  thumbnailUrl: String
  gridRows: Int!
  gridCols: Int!
  maxEntriesPerUser: Int!
  freeEntryQuota: Int!
  startTime: String!
  endTime: String!
  status: BlockpickStatus!
  
  # ⬇️ 신규 추가 필드 (게임 마이그레이션용)
  gameType: GameType!  # DAILY, SELECT, VIBE, PRIME
  currency: String!    # P, JPY, etc
  maxEntries: Int      # 최대 참가자 수
  participants: Int    # 현재 참가자 수
  
  # 기존 필드
  partner: PartnerSummary!
  category: Category!
  topPrize: BlockpickPrize
}
```

### 6.2 blockpicks 쿼리 업데이트

```graphql
query GetBlockpicks($gameType: GameType, $status: BlockpickStatus) {
  blockpicks(gameType: $gameType, status: $status) {
    # 신규 필드 포함 반환 필수
  }
}
```

### 6.3 invalidate 지원

blockpick_provider에서 ref.invalidate() 패턴 지원 필요
- Riverpod 패턴과 일관성 유지

---

## §7. 호출처별 마이그레이션 체크리스트

### ✅ 1단계: daily_screen.dart
```
[ ] gamesByTypeProvider(GameType.daily) → blockpickProvider(gameType: 'DAILY')
[ ] GameRound → BlockpickSummary 변환
[ ] 검색어 필터링: title, category 필드 확인
[ ] invalidate() 호출 유지
```

### ✅ 2단계: game_list_screen.dart
```
[ ] gamesByTypeProvider(widget.gameType) → blockpickProvider(gameType: param)
[ ] sortedGamesProvider 로직 검토
[ ] category 필터링: Category.code 매핑
[ ] currentPrice = entryFee (가격 변환 로직)
```

### ✅ 3단계: unity_game_select_screen.dart
```
[ ] gamesProvider → blockpickProvider로 변경
[ ] gameProducts[] → prizes[] 변환
[ ] product.name → prize.name 매핑
```

---

## 최종 정리

| 항목 | 현황 | 대응 |
|------|------|------|
| **호출처** | 16곳 | 순차적 마이그레이션 |
| **GameType 의존성** | 8곳 | 백엔드: BlockpickSummary에 gameType 추가 |
| **gameProducts 변환** | 복잡함 | 어댑터 작성 필요 |
| **매핑 불가 필드** | currency, rewardPoint, maxEntries | 백엔드 협의 후 BlockpickSummary 확장 |
| **예상 소요시간** | 1-2주 | Phase 1 (기획 협의) + Phase 2 (어댑터) + Phase 3 (마이그레이션) |

