# SMS 인증 API 가이드 (프론트엔드)

## 📱 개요

회원가입 시 휴대폰 번호 인증을 위한 SMS 인증 API입니다.
Twilio Verify API를 사용하여 안전한 SMS 인증을 제공합니다.

## 🔐 인증 플로우

### 일반 회원가입 플로우

```
1. SMS 인증 코드 발송 (sendSmsVerificationCode)
   ↓
2. 사용자가 SMS로 받은 6자리 코드 입력
   ↓
3. SMS 인증 코드 검증 (verifySmsCode)
   ↓
4. 이메일 인증 코드 발송 (sendVerificationCode)
   ↓
5. 사용자가 이메일로 받은 6자리 코드 입력
   ↓
6. 이메일 인증 코드 검증 (verifyCode)
   ↓
7. 회원가입 (signUp)
```

### 소셜 로그인 플로우

```
1. 소셜 로그인 (Google/Kakao/Apple 등)
   ↓
2. SMS 인증 코드 발송 (sendSmsVerificationCode)
   ↓
3. 사용자가 SMS로 받은 6자리 코드 입력
   ↓
4. SMS 인증 코드 검증 (verifySmsCode)
   ↓
5. 회원가입 (signUp)
```

### ⚡ 중요: 순서는 상관없습니다!

**인증 순서를 바꿔도 됩니다:**

- SMS 인증 → 이메일 인증 ✅
- 이메일 인증 → SMS 인증 ✅
- 소셜 로그인 → SMS 인증 ✅
- SMS 인증 → 소셜 로그인 ✅

**회원가입 시 체크하는 것:**

- ✅ 이메일 인증 완료 (24시간 이내)
- ✅ SMS 인증 완료 (24시간 이내)
- **두 인증이 모두 완료되어 있으면 회원가입 가능**

## 📡 API 엔드포인트

**Base URL**: `https://api.blockpick.net/graphql` (또는 로컬: `http://localhost:8080/graphql`)

**Method**: `POST`

**Content-Type**: `application/json`

---

## 1️⃣ SMS 인증 코드 발송

### Mutation

```graphql
mutation SendSmsVerificationCode($input: SendSmsVerificationRequest!) {
  sendSmsVerificationCode(input: $input) {
    success
    code
    message
  }
}
```

### Request Variables

```json
{
  "input": {
    "phoneNumber": "+821012345678",
    "verifyType": "SIGN_UP"
  }
}
```

### Request Example (JavaScript/Fetch)

```javascript
const sendSmsCode = async (phoneNumber) => {
    const response = await fetch('https://api.blockpick.net/graphql', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            query: `
        mutation SendSmsVerificationCode($input: SendSmsVerificationRequest!) {
          sendSmsVerificationCode(input: $input) {
            success
            code
            message
          }
        }
      `,
            variables: {
                input: {
                    phoneNumber: phoneNumber,
                    verifyType: 'SIGN_UP'
                }
            }
        })
    });

    return await response.json();
};

// 사용 예시
const result = await sendSmsCode('+821012345678');
console.log(result);
```

### Response Success

```json
{
  "data": {
    "sendSmsVerificationCode": {
      "success": true,
      "code": "SUCCESS",
      "message": "SMS 인증 코드가 발송되었습니다."
    }
  }
}
```

### Response Error

```json
{
  "data": {
    "sendSmsVerificationCode": {
      "success": false,
      "code": "SEND_ERROR",
      "message": "SMS 인증 코드 발송에 실패했습니다: [에러 메시지]"
    }
  }
}
```

### 파라미터 설명

| 필드          | 타입            | 필수 | 설명                                                     |
|-------------|---------------|----|--------------------------------------------------------|
| phoneNumber | String        | ✅  | E.164 형식의 전화번호 (예: +821012345678)                      |
| verifyType  | SmsVerifyType | ✅  | `SIGN_UP`, `FIND_EMAIL`, `CHANGE_PASSWORD`, `WITHDRAW` |

### 주의사항

- 전화번호는 **E.164 국제 표준 형식**을 사용해야 합니다
    - ✅ 올바른 형식: `+821012345678`
    - ❌ 잘못된 형식: `010-1234-5678`, `01012345678`
- 한국 번호의 경우 국가 코드 `+82`를 사용하고, 앞의 0을 제거합니다
    - 예: `010-1234-5678` → `+821012345678`
- SMS 발송 후 3분간 유효합니다
- 동일한 번호로 중복 요청 시 이전 코드는 무효화됩니다

---

## 2️⃣ SMS 인증 코드 검증

### Mutation

```graphql
mutation VerifySmsCode($input: VerifySmsCodeRequest!) {
  verifySmsCode(input: $input) {
    success
    message
  }
}
```

### Request Variables

```json
{
  "input": {
    "phoneNumber": "+821012345678",
    "code": "123456",
    "verifyType": "SIGN_UP"
  }
}
```

### Request Example (JavaScript/Fetch)

```javascript
const verifySmsCode = async (phoneNumber, code) => {
    const response = await fetch('https://api.blockpick.net/graphql', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            query: `
        mutation VerifySmsCode($input: VerifySmsCodeRequest!) {
          verifySmsCode(input: $input) {
            success
            message
          }
        }
      `,
            variables: {
                input: {
                    phoneNumber: phoneNumber,
                    code: code,
                    verifyType: 'SIGN_UP'
                }
            }
        })
    });

    return await response.json();
};

// 사용 예시
const result = await verifySmsCode('+821012345678', '123456');
console.log(result);
```

### Response Success

```json
{
  "data": {
    "verifySmsCode": {
      "success": true,
      "message": "인증이 완료되었습니다."
    }
  }
}
```

### Response Error

```json
{
  "data": {
    "verifySmsCode": {
      "success": false,
      "message": "인증 코드가 올바르지 않습니다."
    }
  }
}
```

### 파라미터 설명

| 필드          | 타입            | 필수 | 설명                             |
|-------------|---------------|----|--------------------------------|
| phoneNumber | String        | ✅  | SMS를 받은 전화번호 (발송 시 사용한 번호와 동일) |
| code        | String        | ✅  | SMS로 받은 6자리 인증 코드              |
| verifyType  | SmsVerifyType | ✅  | 발송 시 사용한 타입과 동일                |

### 주의사항

- 인증 코드는 발송 후 **3분간** 유효합니다
- 잘못된 코드를 여러 번 입력하면 일시적으로 차단될 수 있습니다
- 인증 성공 시 **24시간** 동안 유효합니다 (회원가입 시 사용)

---

## 3️⃣ 회원가입 (SMS 인증 포함)

SMS 인증과 이메일 인증이 모두 완료된 후 회원가입을 진행합니다.

### Mutation

```graphql
mutation SignUp($input: SignUpRequest!) {
  signUp(input: $input) {
    success
    code
    message
    user {
      id
      email
      nickname
      phoneNumber
      createdAt
    }
  }
}
```

### Request Variables

```json
{
  "input": {
    "email": "user@example.com",
    "password": "Password123!",
    "phoneNumber": "+821012345678",
    "nickname": "홍길동"
  }
}
```

### Request Example (JavaScript/Fetch)

```javascript
const signUp = async (email, password, phoneNumber, nickname) => {
    const response = await fetch('https://api.blockpick.net/graphql', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            query: `
        mutation SignUp($input: SignUpRequest!) {
          signUp(input: $input) {
            success
            code
            message
            user {
              id
              email
              nickname
              phoneNumber
              createdAt
            }
          }
        }
      `,
            variables: {
                input: {
                    email: email,
                    password: password,
                    phoneNumber: phoneNumber,
                    nickname: nickname
                }
            }
        })
    });

    return await response.json();
};

// 사용 예시
const result = await signUp(
    'user@example.com',
    'Password123!',
    '+821012345678',
    '홍길동'
);
console.log(result);
```

### Response Success

```json
{
  "data": {
    "signUp": {
      "success": true,
      "code": "SUCCESS",
      "message": "회원가입이 완료되었습니다.",
      "user": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "user@example.com",
        "nickname": "홍길동",
        "phoneNumber": "+821012345678",
        "createdAt": "2026-01-08T10:30:00"
      }
    }
  }
}
```

### Response Error

```json
{
  "data": {
    "signUp": {
      "success": false,
      "code": "SIGNUP_FAILED",
      "message": "휴대폰 번호 인증이 필요하거나 인증 유효기간(24시간)이 만료되었습니다.",
      "user": null
    }
  }
}
```

### 파라미터 설명

| 필드          | 타입     | 필수 | 설명                             |
|-------------|--------|----|--------------------------------|
| email       | String | ✅  | 사용자 이메일 (이메일 인증 완료 필요)         |
| password    | String | ✅  | 비밀번호 (8자 이상, 영문+숫자+특수문자 조합 권장) |
| phoneNumber | String | ✅  | 전화번호 (SMS 인증 완료 필요)            |
| nickname    | String | ✅  | 닉네임 (2~20자)                    |

### 필수 조건

회원가입이 성공하려면 다음 조건을 만족해야 합니다:

1. ✅ **SMS 인증 완료**: 24시간 이내에 인증 완료된 전화번호
2. ✅ **이메일 인증 완료**: 24시간 이내에 인증 완료된 이메일
3. ✅ **중복 체크**: 이미 사용 중인 이메일/전화번호가 아님

---

## 📝 SmsVerifyType (Enum)

SMS 인증 타입을 지정합니다.

| 값                 | 설명           |
|-------------------|--------------|
| `SIGN_UP`         | 회원가입 시 인증    |
| `FIND_EMAIL`      | 이메일 찾기 시 인증  |
| `CHANGE_PASSWORD` | 비밀번호 변경 시 인증 |
| `WITHDRAW`        | 회원 탈퇴 시 인증   |

---

## 🎨 프론트엔드 구현 예시 (React)

### 1. SMS 인증 컴포넌트

```jsx
import {useState} from 'react';

function SmsVerification({phoneNumber, onVerified}) {
    const [code, setCode] = useState('');
    const [isSent, setIsSent] = useState(false);
    const [isVerifying, setIsVerifying] = useState(false);
    const [error, setError] = useState('');

    // SMS 발송
    const sendSmsCode = async () => {
        try {
            const response = await fetch('https://api.blockpick.net/graphql', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    query: `
            mutation SendSmsVerificationCode($input: SendSmsVerificationRequest!) {
              sendSmsVerificationCode(input: $input) {
                success
                message
              }
            }
          `,
                    variables: {
                        input: {
                            phoneNumber: phoneNumber,
                            verifyType: 'SIGN_UP'
                        }
                    }
                })
            });

            const result = await response.json();

            if (result.data.sendSmsVerificationCode.success) {
                setIsSent(true);
                setError('');
                alert('SMS 인증 코드가 발송되었습니다.');
            } else {
                setError(result.data.sendSmsVerificationCode.message);
            }
        } catch (err) {
            setError('SMS 발송에 실패했습니다.');
        }
    };

    // SMS 인증 검증
    const verifySmsCode = async () => {
        setIsVerifying(true);
        try {
            const response = await fetch('https://api.blockpick.net/graphql', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    query: `
            mutation VerifySmsCode($input: VerifySmsCodeRequest!) {
              verifySmsCode(input: $input) {
                success
                message
              }
            }
          `,
                    variables: {
                        input: {
                            phoneNumber: phoneNumber,
                            code: code,
                            verifyType: 'SIGN_UP'
                        }
                    }
                })
            });

            const result = await response.json();

            if (result.data.verifySmsCode.success) {
                setError('');
                onVerified(); // 인증 완료 콜백
            } else {
                setError(result.data.verifySmsCode.message);
            }
        } catch (err) {
            setError('인증 코드 검증에 실패했습니다.');
        } finally {
            setIsVerifying(false);
        }
    };

    return (
        <div className="sms-verification">
            <h3>휴대폰 인증</h3>
            <p>전화번호: {phoneNumber}</p>

            {!isSent ? (
                <button onClick={sendSmsCode}>
                    인증번호 발송
                </button>
            ) : (
                <div>
                    <input
                        type="text"
                        maxLength="6"
                        placeholder="인증번호 6자리"
                        value={code}
                        onChange={(e) => setCode(e.target.value)}
                    />
                    <button
                        onClick={verifySmsCode}
                        disabled={isVerifying || code.length !== 6}
                    >
                        {isVerifying ? '인증 중...' : '인증하기'}
                    </button>
                    <button onClick={sendSmsCode}>
                        재발송
                    </button>
                </div>
            )}

            {error && <p className="error">{error}</p>}
        </div>
    );
}

export default SmsVerification;
```

### 2. 전화번호 포맷팅 유틸리티

```javascript
/**
 * 한국 전화번호를 E.164 형식으로 변환
 * @param {string} phoneNumber - 입력된 전화번호
 * @returns {string} E.164 형식 전화번호
 */
export const formatPhoneNumber = (phoneNumber) => {
        // 숫자만 추출
        const numbers = phoneNumber.replace(/[^\d]/g, '');

        // 010으로 시작하는 경우
        if (numbers.startsWith('010')) {
            return `+82${numbers.substring(1)}`;
        }

        // 이미 +82로 시작하는 경우
        if (numbers.startsWith('82')) {
            return `+${numbers}`;
        }

        // 0으로 시작하는 경우
        if (numbers.startsWith('0')) {
            return `+82${numbers.substring(1)}`;
        }

        return `+82${numbers}`;
    };

// 사용 예시
console.log(formatPhoneNumber('010-1234-5678')); // +821012345678
console.log(formatPhoneNumber('01012345678'));   // +821012345678
console.log(formatPhoneNumber('10-1234-5678'));  // +821012345678
```

---

## ⚠️ 에러 코드

| 코드                    | 설명        | 해결 방법                  |
|-----------------------|-----------|------------------------|
| `SUCCESS`             | 성공        | -                      |
| `SEND_ERROR`          | SMS 발송 실패 | 전화번호 형식 확인, 네트워크 상태 확인 |
| `SEND_FAILED`         | 발송 처리 실패  | 잠시 후 재시도               |
| `VERIFICATION_FAILED` | 인증 실패     | 올바른 인증 코드 입력           |
| `EXPIRED`             | 인증 코드 만료  | 인증 코드 재발송              |
| `SIGNUP_FAILED`       | 회원가입 실패   | 모든 인증 완료 여부 확인         |

---

## 🔍 테스트 방법

### cURL 테스트

```bash
# 1. SMS 인증 코드 발송
curl -X POST https://api.blockpick.net/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { sendSmsVerificationCode(input: { phoneNumber: \"+821012345678\", verifyType: SIGN_UP }) { success message } }"
  }'

# 2. SMS 인증 코드 검증
curl -X POST https://api.blockpick.net/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { verifySmsCode(input: { phoneNumber: \"+821012345678\", code: \"123456\", verifyType: SIGN_UP }) { success message } }"
  }'
```

### Postman 컬렉션

Postman에서 사용할 수 있는 샘플 요청:

**URL**: `POST https://api.blockpick.net/graphql`

**Headers**:

```
Content-Type: application/json
```

**Body (raw JSON)**:

```json
{
  "query": "mutation SendSmsVerificationCode($input: SendSmsVerificationRequest!) { sendSmsVerificationCode(input: $input) { success code message } }",
  "variables": {
    "input": {
      "phoneNumber": "+821012345678",
      "verifyType": "SIGN_UP"
    }
  }
}
```

---

## 📞 문의

API 관련 문의사항은 백엔드 팀에 연락해주세요.

- **담당자**: 백엔드 개발팀
- **문서 버전**: 1.0.0
- **최종 업데이트**: 2026-01-08

