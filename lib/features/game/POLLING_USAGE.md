# 게임 참여 폴링 시스템 사용 가이드

## 개요

게임 참여 시 블록체인 트랜잭션이 완료될 때까지 상태를 폴링하는 시스템입니다.

## ✅ 완료된 구현 항목

1. **모델 생성** - `EncryptionKeyStatus`, `EntryStatus`, `TxIntentDetail`
2. **폴링 서비스** - `EncryptionKeyPollingService`, `EntryStatusPollingService`
3. **Provider 통합** - `game_participation_provider`에 자동 폴링 통합
4. **UI 컴포넌트** - `GameJoinProgressOverlay`, `GameJoinProgressNotifier`
5. **진행 상태 업데이트** - 6단계 실시간 UI 업데이트
6. **에러 핸들링 강화** - 네트워크 재시도 로직, 사용자 친화적 메시지

## 🎯 주요 기능

- **자동 폴링**: `joinGame()` 호출 시 자동으로 CONFIRMED 상태까지 대기
- **실시간 UI 업데이트**: 6단계 진행 상태를 오버레이로 표시
- **네트워크 에러 자동 재시도**: 최대 30회 재시도 (네트워크 에러 감지 시)
- **트랜잭션 진행률 표시**: 몇 개의 트랜잭션이 확정되었는지 실시간 표시

## 주요 컴포넌트

### 1. 모델 (Models)

#### EncryptionKeyStatus (`lib/models/encryption_key_status.dart`)
```dart
class EncryptionKeyStatus {
  final bool success;
  final String requestId;
  final String status;  // PENDING, PROCESSING, COMPLETED, FAILED
  final String? txHash;
  final String? errorCode;
  final String? errorMessage;
}
```

#### EntryStatus (`lib/models/entry_status.dart`)
```dart
class EntryStatus {
  final bool success;
  final String entryId;
  final String status;  // PENDING, PROCESSING, CONFIRMED, FAILED
  final List<TxIntentDetail> txIntents;
  final String? errorMessage;
}

class TxIntentDetail {
  final String intentId;
  final String status;
  final String? txHash;
  final String? errorCode;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 2. 폴링 서비스 (Services)

#### EncryptionKeyPollingService
```dart
final service = EncryptionKeyPollingService(client: graphqlClient);

// 암호화 키 생성 상태 폴링
await for (final status in service.pollEncryptionKeyStatus(requestId)) {
  print('Status: ${status.status}');

  if (status.isCompleted) {
    print('Key generated!');
    break;
  }

  if (status.isFailed) {
    print('Failed: ${status.errorMessage}');
    break;
  }
}
```

#### EntryStatusPollingService
```dart
final service = EntryStatusPollingService(client: graphqlClient);

// 게임 참여 상태 폴링
await for (final status in service.pollEntryStatus(entryId)) {
  print('Status: ${status.status}');
  print('Transactions: ${status.txIntents.length}');

  if (status.isConfirmed) {
    print('Entry confirmed!');
    break;
  }

  if (status.isFailed) {
    print('Failed: ${status.errorMessage}');
    break;
  }
}
```

### 3. 통합 Provider

#### GameParticipation Provider
`lib/providers/game_participation_provider.dart`

자동으로 폴링이 통합되어 있습니다:

```dart
// 사용 예제
final result = await ref.read(gameParticipationProvider.notifier).joinGame(
  gameId: 'game-123',
  selectedGameProductId: 'product-456',
  row: 5,
  col: 10,
  contractAddress: '0x...',
);

// result.success == true: 블록체인 확정 완료
// result.success == false: 실패
```

**프로세스:**
1. 지갑 확인/생성
2. 암호화 키 생성 (서버 가스비 대납)
3. 좌표 암호화
4. 지갑 주소 해시화
5. joinGame Mutation 전송
6. **🆕 게임 참여 상태 폴링 (CONFIRMED까지 대기)**

### 4. UI 컴포넌트

#### GameJoinProgressOverlay
`lib/features/game/widgets/game_join_progress_overlay.dart`

진행 상태를 시각적으로 표시:

```dart
// 오버레이 표시
final overlay = GameJoinProgressOverlay.show(
  context,
  currentStep: GameJoinStep.polling,
  statusMessage: '블록체인 처리 중...',
  txHash: '0x123...',
);

// 오버레이 제거
overlay.remove();
```

**GameJoinStep 단계:**
- `walletCheck`: 지갑 확인/생성 (1/6)
- `encryptionKey`: 암호화 키 생성 (2/6)
- `coordinateEncryption`: 좌표 암호화 (3/6)
- `walletHashing`: 지갑 주소 해시화 (4/6)
- `joinMutation`: 게임 참여 요청 (5/6)
- `polling`: 블록체인 처리 대기 (6/6)

#### GameJoinProgressNotifier
`lib/providers/game_join_progress_provider.dart`

실시간 진행 상태 관리:

```dart
// 상태 업데이트
ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
  step: GameJoinStep.polling,
  message: '2/3 트랜잭션 처리 중...',
  txHash: '0x123...',
);

// 에러 업데이트
ref.read(gameJoinProgressNotifierProvider.notifier).updateError(
  step: GameJoinStep.polling,
  errorMessage: '트랜잭션 실패',
);

// 상태 초기화
ref.read(gameJoinProgressNotifierProvider.notifier).reset();
```

## 폴링 설정

### 기본 설정

- **폴링 간격**: 2초
- **최대 시도**: 30회 (약 1분)
- **타임아웃**: 60초

### 커스터마이징

```dart
final service = EntryStatusPollingService(client: client);

await for (final status in service.pollEntryStatus(
  entryId,
  interval: const Duration(seconds: 3),  // 3초마다 폴링
  maxAttempts: 20,                        // 최대 20회 시도
)) {
  // ...
}
```

## 에러 핸들링

### 폴링 타임아웃
```dart
try {
  await for (final status in service.pollEntryStatus(entryId)) {
    // ...
  }
} on TimeoutException catch (e) {
  print('타임아웃: ${e.message}');
  // 사용자에게 수동 확인 옵션 제공
}
```

### 네트워크 에러
- 자동으로 재시도합니다 (최대 시도 횟수까지)
- 최대 시도 초과 시 예외 발생

### 비즈니스 에러
- `status == 'FAILED'` 시 즉시 중단
- `errorMessage`에 상세 정보 포함

## GraphQL 쿼리

### encryptionKeyStatus
```graphql
query EncryptionKeyStatus($requestId: String!) {
  encryptionKeyStatus(requestId: $requestId) {
    success
    requestId
    status
    txHash
    errorCode
    errorMessage
  }
}
```

### entryStatus
```graphql
query EntryStatus($entryId: String!) {
  entryStatus(entryId: $entryId) {
    success
    entryId
    status
    txIntents {
      intentId
      status
      txHash
      errorCode
      errorMessage
      createdAt
      updatedAt
    }
    errorMessage
  }
}
```

## 실전 예제

### 기존 GameJoinButton 업데이트

```dart
class _GameJoinButtonState extends ConsumerState<GameJoinButton> {
  OverlayEntry? _progressOverlay;

  Future<void> _handleJoinGame() async {
    try {
      // 1. 진행 오버레이 표시
      _progressOverlay = GameJoinProgressOverlay.show(
        context,
        currentStep: GameJoinStep.walletCheck,
        statusMessage: '게임 참여를 준비하고 있습니다...',
      );

      // 2. 게임 참가 실행 (자동으로 폴링 포함)
      final result = await ref
          .read(gameParticipationProvider.notifier)
          .joinGame(
            gameId: widget.gameId,
            selectedGameProductId: widget.selectedGameProductId,
            row: widget.selectedRow,
            col: widget.selectedCol,
            contractAddress: widget.contractAddress,
          );

      // 3. 오버레이 제거
      _progressOverlay?.remove();
      _progressOverlay = null;

      // 4. 결과 처리
      if (mounted) {
        if (result.success) {
          // 성공 다이얼로그
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('✅ 참여 완료!'),
              content: Text('게임 참여가 확정되었습니다.\n\nEntry ID: ${result.entryId}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSuccess?.call();
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          );
        } else {
          // 실패 다이얼로그
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('❌ 참여 실패'),
              content: Text(result.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('닫기'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleJoinGame(); // 재시도
                  },
                  child: Text('재시도'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // 에러 처리
      _progressOverlay?.remove();
      _progressOverlay = null;

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('❌ 오류'),
            content: Text('알 수 없는 오류가 발생했습니다.\n\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('닫기'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _progressOverlay?.remove();
    super.dispose();
  }
}
```

## 테스트

### 수동 테스트
1. 게임 참여 버튼 클릭
2. 콘솔에서 폴링 로그 확인:
   ```
   🔄 [게임 참여 폴링] 시도 1/30 (entryId: xxx)
   📊 [게임 참여 폴링] 상태: PENDING
   🔄 [게임 참여 폴링] 시도 2/30 (entryId: xxx)
   📊 [게임 참여 폴링] 상태: PROCESSING
   ✅ [게임 참여 폴링] 완료!
   ```

### 상태별 시나리오
- **PENDING → PROCESSING → CONFIRMED**: 정상 완료
- **PENDING → FAILED**: 즉시 실패
- **PENDING → ... (30회)**: 타임아웃

## 주의사항

1. **폴링 중복 방지**: 동일한 entryId로 여러 번 폴링하지 않도록 주의
2. **리소스 정리**: Overlay 등 UI 리소스는 반드시 정리
3. **네트워크 효율**: 폴링 간격을 너무 짧게 설정하지 않기
4. **사용자 경험**: 타임아웃 시 수동 확인 옵션 제공

## 문제 해결

### Q: 폴링이 너무 오래 걸려요
A: 백엔드 트랜잭션 처리 시간을 확인하고, 필요시 `maxAttempts`를 늘려주세요.

### Q: 폴링이 실패해요
A:
1. GraphQL 쿼리가 정상 작동하는지 확인
2. `entryId`가 올바르게 전달되는지 확인
3. 네트워크 연결 상태 확인

### Q: UI가 업데이트되지 않아요
A: `GameJoinProgressNotifier`를 통해 상태를 업데이트하고 있는지 확인하세요.

## 향후 개선사항

- [ ] WebSocket 기반 실시간 업데이트 (폴링 대체)
- [ ] 로컬 알림 (백그라운드 처리 완료 시)
- [ ] 재시도 전략 커스터마이징
- [ ] 폴링 진행률 시각화 개선
