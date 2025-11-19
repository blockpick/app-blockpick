# 🚨 서버 에러 리포트: requestEncryptionKey INTERNAL_ERROR

## 📋 에러 요약

- **Mutation**: `requestEncryptionKey`
- **에러 코드**: `INTERNAL_ERROR`
- **에러 메시지**: `Transaction silently rolled back because it has been marked as rollback-only`
- **발생 횟수**: 2회 연속 (다른 게임, 다른 지갑에서도 동일 에러)
- **영향**: 암호화 키 생성 불가 → 게임 참여 불가

## 🔍 재현 가능한 테스트 케이스

### Case 1
```graphql
mutation RequestEncryptionKey {
  requestEncryptionKey(input: {
    gameId: "01a18547-64cc-4e9e-9816-3161f0278018"
    userAddress: "0xdf59aeb15cd63561a5e409f54fa6373c85961251"
    index: "4653bd9809920e75a12222214de745099063a1d6a017ccf450bb5efe1c895ca6"
  }) {
    success
    code
    message
    encryptionKey
    txHash
  }
}
```

**응답:**
```json
{
  "success": false,
  "code": "INTERNAL_ERROR",
  "message": "Transaction silently rolled back because it has been marked as rollback-only",
  "encryptionKey": null,
  "contractAddress": null,
  "txHash": null,
  "userAddress": null,
  "index": null
}
```

### Case 2 (다른 게임, 다른 지갑)
```graphql
mutation RequestEncryptionKey {
  requestEncryptionKey(input: {
    gameId: "3907f3f0-6a8f-4209-993b-56133138fbac"
    userAddress: "0x3783673683fa8cf16a687461c55d048ac1703be5"
    index: "e40fdef1bc6e3c17cdac438b653bbf757fae1f373ffb71fc03a2a3315c7966e3"
  }) {
    success
    code
    message
  }
}
```

**결과:** 동일 에러 발생

## 🔬 에러 분석

### 에러 타입
`Transaction silently rolled back because it has been marked as rollback-only`는 Spring Framework의 `UnexpectedRollbackException`입니다.

### 발생 원인 (추정)

이 에러는 다음과 같은 시나리오에서 발생합니다:

```java
@Transactional
public RequestEncryptionKeyResponse requestEncryptionKey(RequestEncryptionKeyInput input) {
    try {
        // 1. DB에 요청 기록
        keyRequestRepository.save(...);

        // 2. 블록체인 RPC 호출
        String txHash = blockchainService.sendTransaction(...);
        // ← 여기서 예외 발생 가능:
        //   - RPC 연결 실패
        //   - 가스비 부족
        //   - 컨트랙트 revert
        //   - 네트워크 타임아웃

        // 3. 결과 저장
        keyRequestRepository.update(...);

        return success(...);

    } catch (Exception e) {
        // 4. 예외를 catch했지만 @Transactional이 이미 트랜잭션을
        //    rollback-only로 마크함
        log.error("Error creating encryption key", e);

        // 5. 에러 응답 반환 시도
        return failure("...");
        // ← 여기서 "rollback-only" 에러 발생!
    }

    // 6. 메서드 종료 시 Spring이 트랜잭션 커밋 시도
    //    → UnexpectedRollbackException 발생
}
```

## 🎯 확인이 필요한 사항

### 1. 서버 로그 스택 트레이스
```
ERROR [...] TransactionInterceptor - Transaction rolled back
because it has been marked as rollback-only

Caused by: [실제 원인 예외]
  at ...
```

**질문:**
- 실제 원인 예외(Caused by)는 무엇인가요?
- 블록체인 RPC 호출 중 에러가 발생했나요?
- 데이터베이스 제약 조건 위반이 있었나요?

### 2. 블록체인 RPC 로그
- RPC 호출이 성공했나요?
- 트랜잭션 해시가 생성되었나요?
- 가스비 추정에 실패했나요?

### 3. 데이터베이스 로그
- `key_request` 테이블에 중복 데이터가 있나요?
- Foreign key 제약 조건 위반이 있나요?
- Unique constraint 위반이 있나요?

### 4. 트랜잭션 설정
```java
@Transactional(propagation = ?)
@Transactional(rollbackFor = ?)
@Transactional(noRollbackFor = ?)
```
- 트랜잭션 전파 설정이 올바른가요?
- 중첩된 트랜잭션이 있나요?

## ✅ 온체인 확인 결과

클라이언트에서 온체인 조회 결과:
- **암호화 키**: ❌ 없음
- **블록체인 기록**: ❌ 없음
- **결론**: 서버가 블록체인에 트랜잭션을 전송하지 못했습니다

## 💡 권장 수정 방법

### Option 1: 예외 처리 개선
```java
@Transactional(rollbackFor = {DatabaseException.class})
public RequestEncryptionKeyResponse requestEncryptionKey(RequestEncryptionKeyInput input) {
    try {
        // DB 작업
        keyRequestRepository.save(...);

        // 블록체인 호출은 별도 트랜잭션으로 분리
        String txHash = blockchainService.sendTransactionWithoutTransaction(...);

        return success(...);

    } catch (BlockchainException e) {
        // 블록체인 에러는 DB 롤백하지 않음
        log.error("Blockchain error", e);
        return failure("BLOCKCHAIN_ERROR", e.getMessage());

    } catch (Exception e) {
        // DB 에러만 롤백
        throw e;
    }
}
```

### Option 2: 트랜잭션 분리
```java
public RequestEncryptionKeyResponse requestEncryptionKey(RequestEncryptionKeyInput input) {
    // 1. DB 기록 (별도 트랜잭션)
    KeyRequest request = saveKeyRequest(input);

    try {
        // 2. 블록체인 호출 (트랜잭션 없음)
        String txHash = blockchainService.sendTransaction(...);

        // 3. 결과 업데이트 (별도 트랜잭션)
        updateKeyRequest(request.getId(), txHash);

        return success(...);

    } catch (Exception e) {
        // 4. 실패 상태로 업데이트 (별도 트랜잭션)
        updateKeyRequestFailed(request.getId(), e.getMessage());

        return failure("BLOCKCHAIN_ERROR", e.getMessage());
    }
}

@Transactional
private KeyRequest saveKeyRequest(RequestEncryptionKeyInput input) { ... }

@Transactional
private void updateKeyRequest(String id, String txHash) { ... }

@Transactional
private void updateKeyRequestFailed(String id, String error) { ... }
```

## 📊 클라이언트 로그

### 요청
```
📤 GraphQL 요청:
   - Operation: unnamed
   - Variables: {
       input: {
         gameId: "3907f3f0-6a8f-4209-993b-56133138fbac",
         userAddress: "0x3783673683fa8cf16a687461c55d048ac1703be5",
         index: "e40fdef1bc6e3c17cdac438b653bbf757fae1f373ffb71fc03a2a3315c7966e3"
       }
     }
```

### 응답
```
📥 GraphQL 응답:
   - Data: {
       requestEncryptionKey: {
         success: false,
         code: INTERNAL_ERROR,
         message: Transaction silently rolled back because it has been marked as rollback-only,
         encryptionKey: null,
         contractAddress: null,
         txHash: null,
         userAddress: null,
         index: null
       }
     }
   - Errors: null
```

## 🔧 클라이언트 임시 우회 방법

서버 수정 전까지 클라이언트에서 직접 블록체인 트랜잭션을 보내는 대체 로직 구현 가능합니다.

**단점:**
- 사용자가 가스비를 직접 부담해야 함
- 서버와 데이터 동기화 문제
- 보안 위험 (개인키 노출 가능성)

**권장하지 않음 - 서버 수정이 우선입니다.**

## 📞 연락처

- **리포팅**: Flutter 클라이언트 팀
- **날짜**: 2025-11-19
- **환경**: Development (api-dev.blockpick.net)
- **우선순위**: 🔴 Critical (게임 참여 불가)

---

**다음 단계:**
1. ✅ 클라이언트 에러 리포트 작성 완료
2. ⏳ 백엔드 팀: 서버 로그 확인
3. ⏳ 백엔드 팀: 근본 원인 파악
4. ⏳ 백엔드 팀: 수정 및 배포
5. ⏳ 클라이언트 팀: 수정 확인 및 테스트
