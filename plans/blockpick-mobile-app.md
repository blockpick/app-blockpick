# 🎯 BlockPick 모바일 앱 - 종합 프로젝트 기획서

**프로젝트명**: BlockPick Flutter Mobile Application
**영문명**: BlockPick - Blockchain-based Lucky Draw Platform
**버전**: 1.0.0 MVP
**작성일**: 2025-11-20
**문서 유형**: 팀 공유 문서 / 투자·발표용 자료

---

## 📑 목차

1. [Executive Summary (요약)](#1-executive-summary-요약)
2. [프로젝트 개요](#2-프로젝트-개요)
3. [비즈니스 모델 및 차별화 포인트](#3-비즈니스-모델-및-차별화-포인트)
4. [기술 스택 및 아키텍처](#4-기술-스택-및-아키텍처)
5. [현재 개발 현황](#5-현재-개발-현황)
6. [개발 로드맵](#6-개발-로드맵)
7. [비즈니스 메트릭 및 KPI](#7-비즈니스-메트릭-및-kpi)
8. [리스크 관리](#8-리스크-관리)
9. [부록](#9-부록)

---

## 1. Executive Summary (요약)

### 1.1 한 문장 요약

> **BlockPick**은 블록체인 기술로 투명성과 공정성을 보장하는 **모바일 럭키드로우 게임 플랫폼**입니다.

### 1.2 핵심 가치 제안 (Value Proposition)

**문제 (Problem)**:
- 기존 럭키드로우·경품 플랫폼은 **조작 가능성**에 대한 의구심 존재
- 사용자는 운영자가 당첨을 조작하지 않았는지 확인할 방법이 없음
- "진짜 공정한가?"에 대한 신뢰 문제

**솔루션 (Solution)**:
- **블록체인 기술**을 활용하여 모든 게임 참가 과정을 투명하게 기록
- 사용자가 선택한 좌표를 **암호화**하여 백엔드조차 알 수 없게 함
- 당첨 과정을 **스마트 컨트랙트**로 자동화하여 조작 불가능

**차별화 (Differentiation)**:
- 세계 최초 **대형 그리드 (최대 1,000×1,000)** 모바일 렌더링 성공 (60fps)
- **Polygon 블록체인** 기반 투명한 게임 진행
- **AES-256 암호화** + **SHA-256 해시화**로 사용자 프라이버시 보호
- **Toss 스타일** 프리미엄 UX/UI

### 1.3 타겟 시장

- **1차 타겟**: 20-30대 MZ세대, 럭키드로우·이벤트 참여에 관심 있는 사용자
- **2차 타겟**: 블록체인·NFT에 관심 있는 얼리어답터
- **3차 타겟**: 저렴한 가격에 프리미엄 상품을 구매하고 싶은 쇼핑 유저

### 1.4 개발 진행률

- **현재 진행률**: **70% 완료** (2025년 11월 20일 기준)
- **핵심 기능 완료**: ✅ 그리드 렌더링, 블록체인 연동, 게임 참가
- **11월말 목표**: 블록체인 연동 게임 참가 완료
- **12월말 목표**: DAILY, SELECT, VIBE, PRIME(구 OPTIMAL) 4가지 게임 타입 MVP 완성

---

## 2. 프로젝트 개요

### 2.1 BlockPick이란?

BlockPick은 사용자가 **대형 그리드(격자판)에서 원하는 블록을 선택**하여 경품 추첨에 참여하는 모바일 게임 플랫폼입니다.

#### 2.1.1 기본 게임 플레이

1. **게임 선택**: 사용자가 원하는 상품(예: iPhone, AirPods, 패션 아이템)의 게임 선택
2. **블록 선택**: 100×100 ~ 1,000×1,000 크기의 거대한 그리드에서 원하는 좌표의 블록을 선택 (예: 5개)
3. **게임 참가**: 선택한 블록을 암호화하여 블록체인에 제출
4. **당첨 확인**: 게임 종료 후 스마트 컨트랙트가 무작위로 당첨 블록을 선택하고, 해당 블록을 선택한 사용자가 당첨

#### 2.1.2 왜 "블록"인가?

- **대규모 참여 가능**: 1,000×1,000 그리드 = 100만 개 블록 → 최대 100만 명 참여 가능
- **전략성 부여**: 사용자는 "어느 위치를 선택할까?" 고민하며 재미를 느낌
- **공정성 시각화**: 모든 블록이 동일한 확률 → 공정함을 직관적으로 이해

### 2.2 게임 타입 (4가지)

BlockPick은 다양한 게임 방식을 제공하여 사용자 선택의 폭을 넓힙니다.

#### 2.2.1 DAILY (데일리)

- **설명**: 매일 진행되는 기본 럭키드로우 게임
- **특징**:
  - 고정된 참가비 (예: 1,000원)
  - 일일 라운드제
  - 다양한 상품군
- **타겟**: 일상적으로 럭키드로우를 즐기는 사용자

#### 2.2.2 SELECT (셀렉트)

- **설명**: 여러 상품 중 하나를 선택한 후 블록을 고르는 게임
- **특징**:
  - 상품 선택권 제공
  - 프리미엄 상품 위주
  - 높은 참가비
- **타겟**: 고가 상품을 노리는 사용자

#### 2.2.3 VIBE (바이브)

- **설명**: 배경 이미지(상품 사진)를 기반으로 분위기를 살려 블록을 선택하는 게임
- **특징**:
  - 상품 이미지가 그리드 배경에 표시됨
  - 미적 감각을 활용한 선택
  - 감성적인 게임 경험
- **타겟**: 디자인·감성을 중시하는 MZ세대

#### 2.2.4 PRIME (프라임, 구 OPTIMAL)

- **설명**: 상품의 **최적가(가격)**를 맞추는 입찰형 게임
- **특징**:
  - 블록 선택이 아닌 **가격 입찰**
  - Price Wheel Selector로 가격 입력
  - 정답에 가장 가까운 가격을 입력한 사용자가 당첨
- **타겟**: 가격 감각이 뛰어난 쇼핑 마니아

### 2.3 블록체인 기술의 핵심 역할

#### 2.3.1 공정성 보장

**기존 방식의 문제점**:
```
[사용자] → 선택한 블록 전송 → [서버 DB 저장]
                                    ↓
                         서버 관리자가 DB 조회 가능
                         → 조작 가능성 존재
```

**BlockPick 방식**:
```
[사용자] → 블록 선택 → [클라이언트에서 AES-256 암호화]
                              ↓
                    암호화된 좌표만 서버 전송
                              ↓
                    [블록체인 스마트 컨트랙트]
                              ↓
                    게임 종료 후 복호화 키 공개
                              ↓
                    모든 참가자 좌표 공개 → 투명성 확보
```

**핵심 원리**:
1. **암호화 키는 블록체인 스마트 컨트랙트가 생성**
2. 사용자는 이 키로 자신의 좌표를 암호화
3. 서버는 암호화된 좌표만 저장 (복호화 불가)
4. 게임 종료 후 스마트 컨트랙트가 복호화 키를 공개
5. 모든 사용자가 모든 참가자의 좌표를 확인 가능 → **투명성**

#### 2.3.2 익명성 보장

- 사용자의 **블록체인 지갑 주소**를 SHA-256으로 해시화
- 백엔드는 해시값만 저장 → 원본 주소 알 수 없음
- 사용자 간 익명성 유지

#### 2.3.3 기술 스택

- **블록체인 네트워크**: Polygon Amoy Testnet (추후 Mainnet 전환)
- **스마트 컨트랙트**: Solidity
- **암호화**: AES-256-CBC (좌표), SHA-256 (지갑 주소)
- **블록체인 라이브러리**: web3dart v2.7.3

### 2.4 대형 그리드 렌더링 기술

#### 2.4.1 기술적 도전

**문제**: 1,000×1,000 그리드 = 100만 개 셀을 모바일에서 60fps로 렌더링?

**일반적인 접근의 한계**:
- Flutter ListView/GridView: 수천 개 이상 위젯 시 성능 급감
- 모든 셀을 개별 위젯으로 렌더링: 메모리 부족

#### 2.4.2 BlockPick의 솔루션

**1. CustomPaint 기반 Canvas 렌더링**
- Flutter 위젯 트리를 거치지 않고 직접 Canvas에 그림
- 최대 25,000개 셀까지 동시 렌더링 가능

**2. Sparse Grid (희소 그리드)**
- 빈 셀은 렌더링하지 않음
- 선택된 블록만 추가 렌더링

**3. LOD (Level of Detail) 시스템**
- **9단계 줌 레벨**에 따라 세밀도 조절
  - **High Zoom (확대)**: 개별 셀 경계선 + 번호 표시
  - **Medium Zoom**: 경계선만 표시
  - **Low Zoom (축소)**: 경계선 숨김, 섹션만 표시

**4. Viewport Culling (뷰포트 컬링)**
- 화면에 보이지 않는 영역은 렌더링하지 않음
- 스크롤 시 실시간으로 렌더링 영역 업데이트

**결과**:
- **60fps 유지** (실제 테스트 완료)
- 메모리 사용량: 100MB 이하 (1,000×1,000 그리드)

### 2.5 프리미엄 UX/UI

#### 2.5.1 Toss 스타일 애니메이션

BlockPick은 **토스(Toss)** 앱의 프리미엄 UX를 벤치마킹했습니다.

**게임 참가 프로세스 예시**:
1. 사용자가 "Select blocks" 버튼 터치
2. **전체화면 로딩 오버레이** 표시
   - Blue → Purple 그라데이션 배경
   - 3단 원형 회전 애니메이션
   - 중앙에 로켓 아이콘 (스케일 애니메이션)
3. **5단계 진행 표시**:
   - Step 1: "Creating blockchain wallet..."
   - Step 2: "Requesting encryption key..."
   - Step 3: "Encrypting coordinates..."
   - Step 4: "Hashing wallet address..."
   - Step 5: "Submitting to blockchain..."
4. **성공 오버레이**:
   - Green → Blue 그라데이션
   - ✅ 체크 아이콘 (Elastic 애니메이션)
   - 8방향 파티클 효과
   - 흔들림 효과 (2Hz)

#### 2.5.2 디자인 시스템

**컬러 팔레트**:
- Primary Blue: #5C72F5
- Secondary Purple: #6E5AE9
- Accent Pink: #FF58BB
- Gradients: Blue→Purple, Purple→Pink, Multi-color

**타이포그래피**:
- Display (32px, bold)
- Large (24px, bold)
- Medium (18px, semibold)
- Body (14px, normal)

---

## 3. 비즈니스 모델 및 차별화 포인트

### 3.1 수익 모델

#### 3.1.1 게임 참가비

- 사용자는 게임 참가 시 **캐시(Cash)**를 지불
- 참가비의 일부는 수수료로 수취
- 예시:
  - 게임 참가비: 1,000원 × 10,000명 = 10,000,000원
  - 상품 가격: 1,000,000원
  - 플랫폼 수수료: 9,000,000원 (90%)

#### 3.1.2 광고 수익

- 게임 목록에 배너 광고
- 이벤트 캐시 지급과 연계한 스폰서십

#### 3.1.3 쇼핑몰 연계 (향후)

- 럭키드로우 + 일반 커머스 결합
- 상품을 직접 구매하거나 게임으로 참여

### 3.2 차별화 포인트

#### 3.2.1 기술적 차별화

| 구분 | 기존 럭키드로우 플랫폼 | BlockPick |
|------|---------------------|-----------|
| **공정성 검증** | 불가능 (서버 DB에만 저장) | 블록체인 기반 투명성 |
| **대규모 참여** | 제한적 (수천 명) | 최대 100만 명 (1,000×1,000) |
| **모바일 성능** | 그리드 렌더링 불가 | 60fps 렌더링 성공 |
| **익명성** | 지갑 주소 노출 | SHA-256 해시화로 익명성 |
| **암호화** | 없음 | AES-256 좌표 암호화 |

#### 3.2.2 UX 차별화

**1. 전략적 재미**
- "어느 위치를 선택할까?" 고민하는 재미
- 미니맵, 섹션 오버레이로 위치 파악 용이

**2. 프리미엄 애니메이션**
- Toss 스타일 전체화면 오버레이
- 부드러운 화면 전환
- 햅틱 피드백

**3. 다양한 게임 타입**
- DAILY, SELECT, VIBE, PRIME 4가지
- 사용자 취향에 맞는 게임 선택

### 3.3 시장 분석

#### 3.3.1 TAM (Total Addressable Market)

- **글로벌 온라인 경품/럭키드로우 시장**: 약 50억 달러 (2024년 기준)
- **한국 이벤트·프로모션 시장**: 약 5조 원 (2024년 기준)

#### 3.3.2 경쟁사 분석

| 플랫폼 | 특징 | 약점 |
|--------|------|------|
| **번개장터 럭키드로우** | 대규모 사용자 보유 | 공정성 검증 불가, 단순 추첨 방식 |
| **네이버 쇼핑 럭키드로우** | 높은 브랜드 신뢰도 | 블록체인 미적용, 제한된 게임 방식 |
| **해외 NFT 럭키드로우** | 블록체인 기반 | 높은 진입 장벽 (NFT 지식 필요), 고가 |

**BlockPick의 포지셔닝**:
- **블록체인 기술** + **쉬운 UX** + **모바일 최적화** = 대중적 블록체인 럭키드로우

---

## 4. 기술 스택 및 아키텍처

### 4.1 기술 스택

#### 4.1.1 Frontend (Mobile)

| 기술 | 버전 | 용도 |
|------|------|------|
| **Flutter** | 3.35.6 | 크로스 플랫폼 모바일 앱 프레임워크 |
| **Dart** | 3.9.2 | 프로그래밍 언어 |
| **Riverpod** | 2.6.1 | 상태 관리 |
| **Freezed** | 2.5.7 | 불변 모델 코드 생성 |
| **go_router** | 14.6.2 | 라우팅 |
| **GraphQL Flutter** | 5.1.2 | GraphQL 클라이언트 |
| **web3dart** | 2.7.3 | 블록체인 연동 |
| **FlutterSecureStorage** | 9.2.2 | 안전한 로컬 저장소 |

#### 4.1.2 Backend (서버)

| 기술 | 용도 |
|------|------|
| **GraphQL API** | 백엔드 API (게임 데이터, 사용자 관리) |
| **PostgreSQL** | 데이터베이스 (예상) |
| **Node.js** | 백엔드 런타임 (예상) |

#### 4.1.3 Blockchain

| 기술 | 용도 |
|------|------|
| **Polygon Amoy Testnet** | 블록체인 네트워크 (현재) |
| **Polygon Mainnet** | 블록체인 네트워크 (추후) |
| **Solidity** | 스마트 컨트랙트 언어 |
| **AES-256-CBC** | 좌표 암호화 |
| **SHA-256** | 지갑 주소 해시화 |

### 4.2 아키텍처

#### 4.2.1 시스템 구성도

```
┌──────────────────────────────────────────────────────┐
│                    사용자 (Mobile)                     │
│                                                        │
│  ┌──────────────────────────────────────────────┐   │
│  │         Flutter App (BlockPick)               │   │
│  │                                                │   │
│  │  - 게임 목록 조회                              │   │
│  │  - 그리드 렌더링                               │   │
│  │  - 블록 선택                                   │   │
│  │  - 블록체인 지갑 관리                          │   │
│  │  - 좌표 암호화                                 │   │
│  └──────────────────────────────────────────────┘   │
│           │                        │                  │
│           │ GraphQL                │ Web3             │
│           ↓                        ↓                  │
└───────────┼────────────────────────┼──────────────────┘
            │                        │
            │                        │
   ┌────────▼────────┐      ┌───────▼──────────┐
   │  GraphQL API    │      │  Polygon Amoy    │
   │   (Backend)     │      │   Testnet        │
   │                 │      │                  │
   │ - 게임 CRUD     │      │ - 스마트 컨트랙트 │
   │ - 사용자 관리   │      │ - 암호화 키 생성  │
   │ - 참가 내역     │      │ - 당첨자 선정     │
   │ - 캐시 관리     │      │                  │
   └────────┬────────┘      └──────────────────┘
            │
            ↓
   ┌────────────────┐
   │  PostgreSQL    │
   │   Database     │
   │                │
   │ - 게임 데이터  │
   │ - 사용자 정보  │
   │ - 참가 내역    │
   │   (암호화됨)   │
   └────────────────┘
```

#### 4.2.2 게임 참가 플로우

```
[사용자]
   │
   │ 1. 블록 선택 (예: 5개)
   │
   ↓
[Flutter App - Grid Widget]
   │
   │ 2. "Select blocks" 버튼 터치
   │
   ↓
[Game Participation Provider]
   │
   │ 3. 지갑 확인/생성
   │
   ↓
[Blockchain Wallet Service]
   │
   │ 4. 지갑 있음? → 로드 / 없음? → 생성
   │
   ↓
[Smart Contract Service]
   │
   │ 5. 암호화 키 요청 (Hybrid 전략)
   │    ├─ Step 1: getEncryptionKey() 조회 (Gas 무료)
   │    ├─ Step 2: 없으면 requestEncryptionKey() 호출 (서버 Gas 지불)
   │    └─ Step 3: 폴링으로 대기 (최대 60초)
   │
   ↓
[Coordinate Encryption Service]
   │
   │ 6. 좌표 AES-256 암호화
   │    Input: [(row: 123, col: 456), ...]
   │    Key: 블록체인 암호화 키
   │    Output: Base64 암호문
   │
   ↓
[Blockchain Wallet Service]
   │
   │ 7. 지갑 주소 SHA-256 해시화
   │    Input: 0x1234...abcd
   │    Output: a3f5e9...2b7c
   │
   ↓
[GraphQL API]
   │
   │ 8. joinGame Mutation
   │    Variables:
   │      - gameId
   │      - encryptedCoordinates
   │      - hashedWalletAddress
   │      - userIndex (SHA256(walletAddress + gameId))
   │
   ↓
[Entry Status Polling Service]
   │
   │ 9. 참가 상태 폴링
   │    - PENDING → CONFIRMED → SUCCESS
   │    - 트랜잭션 해시 표시
   │
   ↓
[Game Join Result Overlay]
   │
   │ 10. 성공/실패 오버레이 표시
   │     ✅ Success → 파티클 효과
   │     ❌ Error → 재시도 버튼
   │
   ↓
[사용자]
```

#### 4.2.3 Feature-First 구조

```
lib/
├── core/                          # 핵심 기능
│   ├── auth/                      # 인증 시스템
│   │   ├── data/
│   │   │   ├── datasources/      # 로컬/리모트 데이터 소스
│   │   │   └── repositories/     # Repository 구현
│   │   └── domain/
│   │       ├── models/            # User 모델
│   │       ├── providers/         # AuthProvider (Riverpod)
│   │       └── exceptions/        # Auth 예외
│   ├── graphql/                   # GraphQL 클라이언트
│   ├── router/                    # go_router 설정
│   ├── theme/                     # 테마 (색상, 텍스트)
│   └── constants/                 # 상수
│
├── features/                      # 기능별 화면
│   ├── auth/                      # 로그인/회원가입
│   │   └── presentation/
│   │       ├── pages/             # LoginPage, SignupPage
│   │       ├── widgets/           # LoginForm, SignupForm
│   │       └── dialogs/           # 인증 다이얼로그
│   │
│   ├── game/                      # 게임 화면
│   │   ├── screens/               # GameScreen, GameDetailScreen
│   │   ├── widgets/               # GameJoinButton, Overlays
│   │   └── selected_blocks_sheet.dart
│   │
│   ├── grid/                      # 그리드 렌더링
│   │   ├── game_grid_widget.dart  # 메인 그리드 위젯
│   │   ├── grid_painter.dart      # CustomPaint 렌더러
│   │   └── grid_minimap.dart      # 미니맵
│   │
│   ├── home/                      # 홈 화면
│   │   ├── new_home_screen.dart   # 프리미엄 홈
│   │   └── widgets/               # 배너, 캐러셀 등
│   │
│   ├── optimal/                   # 프라임(OPTIMAL) 게임
│   │   ├── optimal_game_screen.dart
│   │   └── widgets/
│   │       └── price_wheel_selector.dart
│   │
│   ├── my_pick/                   # 참여 내역
│   ├── my/                        # 마이페이지 (지갑)
│   ├── winners/                   # 당첨자 발표
│   └── settings/                  # 설정
│
├── providers/                     # Riverpod Providers
│   ├── game_provider.dart         # 게임 데이터
│   ├── grid_state_provider.dart   # 그리드 상태 (줌, 팬)
│   ├── game_participation_provider.dart  # 게임 참가 로직
│   ├── wallet_provider.dart       # 지갑 상태
│   └── game_join_progress_provider.dart  # 참가 진행 상태
│
├── services/                      # 비즈니스 로직 서비스
│   ├── blockchain_wallet_service.dart      # 지갑 생성/관리
│   ├── smart_contract_service.dart         # 스마트 컨트랙트 호출
│   ├── coordinate_encryption_service.dart  # 좌표 암호화
│   ├── encryption_key_polling_service.dart # 키 폴링
│   └── entry_status_polling_service.dart   # 참가 상태 폴링
│
├── models/                        # 데이터 모델
│   ├── game_model.dart
│   ├── block_model.dart
│   ├── user_model.dart
│   └── ...
│
├── components/                    # 재사용 UI 컴포넌트
│   ├── navigation/                # BottomNavBar, AppBar
│   ├── cards/                     # GameCard, MyPickCard
│   ├── buttons/                   # GradientButton
│   └── ...
│
├── widgets/                       # 공통 위젯
└── utils/                         # 유틸리티 함수
```

---

## 5. 현재 개발 현황

**진행률**: **70% 완료** (2025년 11월 20일 기준)

### 5.1 ✅ 완료된 기능 (Completed Features)

#### 5.1.1 핵심 게임 시스템 (100% 완료)

**1. 대형 그리드 렌더링 시스템**
- **파일**: `lib/features/grid/grid_painter.dart`, `lib/features/grid/game_grid_widget.dart`
- **완료 항목**:
  - ✅ 10×10 ~ 1,000×1,000 그리드 지원
  - ✅ CustomPaint 기반 Canvas 렌더링
  - ✅ 60 FPS 유지 (성능 테스트 완료)
  - ✅ LOD (Level of Detail) 9단계 시스템
  - ✅ Sparse Grid (희소 그리드) 최적화
  - ✅ Viewport Culling (뷰포트 컬링)
  - ✅ 최대 25,000개 셀 동시 렌더링
  - ✅ 배경 이미지 렌더링 (상품 사진)
  - ✅ 선택된 블록 폴리곤 렌더링 (땅따먹기 스타일)
  - ✅ 그리드 라인 색상 커스터마이징

**2. 블록 선택 및 상호작용**
- **파일**: `lib/providers/grid_state_provider.dart`
- **완료 항목**:
  - ✅ 터치/클릭으로 블록 선택
  - ✅ 선택된 블록 시각적 강조 (파란색 테두리)
  - ✅ 다중 블록 선택 (최대 개수 제한)
  - ✅ 선택 해제 기능
  - ✅ 선택 블록 목록 바텀시트
  - ✅ 블록 좌표 표시 (Row, Column)
  - ✅ "모두 삭제" 기능

**3. 줌 & 팬 (확대/축소 및 이동)**
- **완료 항목**:
  - ✅ 모바일: 핀치 투 줌 (2-finger pinch)
  - ✅ 데스크톱: 마우스 휠 줌
  - ✅ 모바일: 터치 드래그 팬 (1-finger drag)
  - ✅ 데스크톱: 마우스 드래그 팬
  - ✅ 줌 레벨 범위: 0.1x ~ 4.0x (초기), 0.05x ~ 16x+ (확장 가능)
  - ✅ 줌 컨트롤 버튼 (+/- 버튼)
  - ✅ 줌 레벨에 따른 LOD 자동 조절

**4. 미니맵**
- **파일**: `lib/features/grid/grid_minimap.dart`, `lib/widgets/minimap_widget.dart`
- **완료 항목**:
  - ✅ 전체 그리드 축소판 표시
  - ✅ 현재 뷰포트 위치 표시 (흰색 박스)
  - ✅ 미니맵 터치로 빠른 이동
  - ✅ 선택된 블록 폴리곤 표시
  - ✅ 실시간 동기화 (줌/팬 시 업데이트)

**5. 섹션 오버레이 시스템**
- **파일**: `lib/widgets/grid_section_overlay.dart`, `lib/models/grid_section_model.dart`
- **완료 항목**:
  - ✅ 그리드를 3×3 구역으로 분할 (A1, A2, ..., C3)
  - ✅ 줌 레벨에 따라 섹션 라벨 표시/숨김
  - ✅ 사용자가 현재 어느 구역에 있는지 표시
  - ✅ 구역별 선택 블록 개수 표시

#### 5.1.2 블록체인 통합 (100% 완료)

**1. 지갑 관리**
- **파일**: `lib/services/blockchain_wallet_service.dart`
- **완료 항목**:
  - ✅ 블록체인 지갑 자동 생성 (EthPrivateKey)
  - ✅ 지갑 로컬 저장 (FlutterSecureStorage)
  - ✅ 지갑 로드
  - ✅ 지갑 주소 조회
  - ✅ 플랫폼별 보안 저장소 (iOS Keychain, Android KeyStore)

**2. 스마트 컨트랙트 연동**
- **파일**: `lib/services/smart_contract_service.dart`
- **완료 항목**:
  - ✅ Polygon Amoy Testnet 연결
  - ✅ 스마트 컨트랙트 ABI 파싱
  - ✅ `requestEncryptionKey()` 함수 호출
  - ✅ `getEncryptionKey()` 뷰 함수 호출
  - ✅ 트랜잭션 서명
  - ✅ 트랜잭션 제출
  - ✅ Gas 비용 처리 (서버 지불)
  - ✅ 하이브리드 암호화 키 전략:
    - Step 1: 블록체인 조회 (무료)
    - Step 2: 서버 요청 (서버 Gas 지불)
    - Step 3: 폴링 대기 (최대 60초)

**3. 좌표 암호화**
- **파일**: `lib/services/coordinate_encryption_service.dart`
- **완료 항목**:
  - ✅ AES-256-CBC 암호화
  - ✅ 단일 좌표 암호화
  - ✅ 다중 좌표 암호화
  - ✅ Base64 인코딩 출력
  - ✅ PKCS7 패딩

**4. 프라이버시 보호**
- **완료 항목**:
  - ✅ 지갑 주소 SHA-256 해시화
  - ✅ UserIndex 생성: SHA256(walletAddress + gameId)
  - ✅ 백엔드에는 해시값만 전송 (원본 주소 노출 안 됨)

**5. 폴링 서비스**
- **파일**:
  - `lib/services/encryption_key_polling_service.dart`
  - `lib/services/entry_status_polling_service.dart`
- **완료 항목**:
  - ✅ 암호화 키 생성 폴링 (최대 30회, 2초 간격)
  - ✅ 게임 참가 상태 폴링 (PENDING → CONFIRMED → SUCCESS)
  - ✅ Stream 기반 실시간 업데이트

#### 5.1.3 게임 참가 플로우 (100% 완료)

**1. E2E 게임 참가 프로세스**
- **파일**: `lib/providers/game_participation_provider.dart`
- **완료 항목**:
  - ✅ 1단계: 지갑 확인/생성
  - ✅ 2단계: 암호화 키 획득 (하이브리드 전략)
  - ✅ 3단계: 좌표 암호화
  - ✅ 4단계: 지갑 주소 해시화
  - ✅ 5단계: joinGame Mutation 호출
  - ✅ 6단계: 참가 상태 폴링
  - ✅ 에러 핸들링 및 재시도

**2. 게임 참가 UI**
- **파일**:
  - `lib/features/game/widgets/game_join_button.dart`
  - `lib/features/game/widgets/game_join_progress_overlay.dart`
  - `lib/features/game/widgets/game_join_result_overlay.dart`
- **완료 항목**:
  - ✅ Toss 스타일 그라데이션 버튼 (Shimmer 효과)
  - ✅ 전체화면 로딩 오버레이:
    - Blue → Purple 그라데이션 배경
    - 3단 원형 회전 애니메이션
    - 로켓 아이콘 (스케일 애니메이션)
    - 5단계 진행 표시
  - ✅ 성공 오버레이:
    - Green → Blue 그라데이션
    - ✅ 체크 아이콘 (Elastic 애니메이션)
    - 8방향 파티클 효과
    - 흔들림 효과 (2Hz)
    - 트랜잭션 정보 표시
  - ✅ 실패 오버레이:
    - Red → Pink 그라데이션
    - ❌ X 아이콘
    - 강한 흔들림 효과 (4Hz)
    - 재시도 버튼

**3. E2E 테스트 화면**
- **파일**: `lib/features/game/screens/game_join_test_screen.dart`
- **완료 항목**:
  - ✅ 전체 블록체인 플로우 테스트 UI
  - ✅ 단계별 디버깅 정보 표시
  - ✅ 수동 테스트 인터페이스

#### 5.1.4 게임 목록 및 상세 화면 (100% 완료)

**1. 게임 목록 화면**
- **파일**: `lib/features/game/game_list_screen.dart`
- **완료 항목**:
  - ✅ 탭 기반 필터링 (DAILY, SELECT, VIBE, PRIME)
  - ✅ 카테고리 칩 필터 (ALL, Digital, Fashion, Beauty 등)
  - ✅ 정렬 드롭다운 (인기순, 최신순, 마감임박순, 저가순)
  - ✅ 그리드/리스트 뷰 토글
  - ✅ 게임 카드 디스플레이:
    - 상품 이미지 (16:9)
    - 상태 배지 (Active/Drawing/Ended)
    - 타입 배지 (Daily/Select/Vibe)
    - 제목, 참가자 수, 남은 시간
    - 참가비, 원가, 할인율
  - ✅ 로딩 상태 (CircularProgressIndicator)
  - ✅ 에러 상태 (재시도 버튼)
  - ✅ 빈 상태 (Empty state)
  - ✅ 무한 스크롤 지원

**2. 게임 상세 화면**
- **파일**: `lib/features/game/game_detail_screen.dart`, `lib/features/game/game_detail_screen_v2.dart`
- **완료 항목**:
  - ✅ 상품 이미지 배경
  - ✅ 정보 패널 오버레이:
    - 타입 배지
    - 남은 시간
    - 참가자 수
    - 당첨자 수
    - 참가비
  - ✅ 공유 버튼
  - ✅ "참가하기" 버튼 (그라데이션, 애니메이션)
  - ✅ 게임 그리드로 이동

**3. 게임 화면 (메인 플레이)**
- **파일**: `lib/features/game/game_screen.dart`
- **완료 항목**:
  - ✅ 전체화면 그리드 위젯
  - ✅ 미니맵 (우상단)
  - ✅ Pick HUD (선택된 블록 개수, 좌상단)
  - ✅ 줌 컨트롤 (+/- 버튼, 우하단)
  - ✅ 선택된 블록 바텀시트 (하단):
    - 블록 목록 카드
    - "CLEAR" 버튼
    - "Select blocks (3/5)" 버튼

#### 5.1.5 프라임(OPTIMAL) 게임 (100% 완료)

- **파일**:
  - `lib/features/optimal/optimal_game_screen.dart`
  - `lib/features/optimal/widgets/price_wheel_selector.dart`
- **완료 항목**:
  - ✅ 가격 휠 셀렉터 UI
  - ✅ 회전하는 휠 인터페이스
  - ✅ 만원 단위 가격 선택
  - ✅ "Bid ₩ 100,000" 버튼 (실시간 금액 업데이트)
  - ✅ 입찰 확인 다이얼로그

#### 5.1.6 인증 시스템 (Backend 100% 완료)

**1. 인증 인프라**
- **파일**:
  - `lib/core/auth/domain/providers/auth_provider.dart`
  - `lib/core/auth/data/repositories/auth_repository.dart`
  - `lib/core/auth/data/datasources/token_local_datasource.dart`
- **완료 항목**:
  - ✅ JWT 토큰 관리 (Access + Refresh)
  - ✅ 안전한 토큰 저장 (FlutterSecureStorage)
  - ✅ 자동 토큰 갱신 메커니즘
  - ✅ 인증 상태 관리 (Riverpod)
  - ✅ GraphQL 클라이언트 인증 헤더 자동 추가
  - ✅ 라우트 보호 미들웨어 (go_router)

**2. Backend API 연동**
- **완료 항목**:
  - ✅ `login` Mutation
  - ✅ `signUp` Mutation (3단계: 이메일 인증 → 코드 확인 → 계정 생성)
  - ✅ 비밀번호 재설정 Mutation (3단계)
  - ✅ `me` Query (사용자 프로필)
  - ✅ 이메일 인증 시스템

#### 5.1.7 네비게이션 & 구조 (100% 완료)

**1. 하단 네비게이션 바**
- **파일**: `lib/components/navigation/bottom_nav_bar.dart`
- **완료 항목**:
  - ✅ 6개 탭: HOME, My Pick, PICK(중앙 대형), Winners, MALL, MY
  - ✅ 선택된 탭 강조 표시
  - ✅ 아이콘 + 라벨
  - ✅ 부드러운 탭 전환 애니메이션

**2. 앱바**
- **파일**:
  - `lib/components/app_bars/main_app_bar.dart`
  - `lib/components/app_bars/sub_app_bar.dart`
- **완료 항목**:
  - ✅ 메인 앱바: 플랫폼 선택, 알림, 사용자 프로필
  - ✅ 서브 앱바: 타이틀, 알림, 설정
  - ✅ 드로어 메뉴

**3. 라우팅**
- **파일**: `lib/core/router/router.dart`
- **완료 항목**:
  - ✅ go_router 설정
  - ✅ 라우트 정의:
    - `/` - 홈 (BlockpickScreen)
    - `/login`, `/signup`, `/forgot-password`
    - `/game/:gameId` - 게임 화면
    - `/optimal/:gameId` - 프라임 게임
    - `/settings` - 설정
    - `/test/game-join` - E2E 테스트
  - ✅ 보호된 라우트 (로그인 필요)
  - ✅ 자동 리다이렉트

#### 5.1.8 홈 화면 (100% 완료)

**1. 프리미엄 홈 화면**
- **파일**: `lib/features/home/new_home_screen.dart`
- **완료 항목**:
  - ✅ 이벤트 배너 캐러셀
  - ✅ SELECT 캐러셀 (프리미엄)
  - ✅ 추천 게임 섹션
  - ✅ Pick 섹션 위젯 (프리미엄)
  - ✅ 상품 쇼케이스 (프리미엄)

**2. 클래식 홈 화면**
- **파일**: `lib/features/home/home_screen.dart`
- **완료 항목**:
  - ✅ 탭 기반 게임 목록 (DAILY/SELECT/VIBE/PRIME)

**3. 홈 위젯 라이브러리**
- **파일**: `lib/features/home/widgets/`
- **완료 항목**:
  - ✅ 이벤트 배너 캐러셀
  - ✅ SELECT 캐러셀 (프리미엄 & 스탠다드)
  - ✅ Pick 섹션 위젯 (프리미엄 & 스탠다드)
  - ✅ 공지사항 위젯 (롤링)
  - ✅ 참여 피드 위젯
  - ✅ 쇼핑몰 미리보기 위젯
  - ✅ 튜토리얼 버튼/링크 위젯
  - ✅ 이벤트 캐시 위젯
  - ✅ BlockPick 가이드 위젯
  - ✅ 리뷰 섹션 위젯
  - ✅ 기능 카드 (프리미엄)
  - ✅ 상품 쇼케이스 (프리미엄)

#### 5.1.9 GraphQL 통합 (100% 완료)

- **파일**: `lib/core/graphql/graphql_client.dart`
- **완료 항목**:
  - ✅ GraphQL Flutter 클라이언트 설정
  - ✅ JWT 자동 인증
  - ✅ 토큰 갱신 핸들링
  - ✅ 에러 핸들링
  - ✅ 캐시 정책 관리
  - ✅ 구현된 Query:
    - `getGames` - 게임 목록
    - `getGame` - 게임 상세
    - `getActiveGames` - 활성 게임
    - `me` - 사용자 프로필
  - ✅ 구현된 Mutation:
    - `login` - 로그인
    - `signUp` - 회원가입
    - `requestEncryptionKey` - 암호화 키 요청
    - `joinGame` - 게임 참가
    - 비밀번호 재설정 Mutations
    - 이메일 인증 Mutations

#### 5.1.10 디자인 시스템 (100% 완료)

- **파일**:
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
  - `lib/core/theme/app_theme.dart`
- **완료 항목**:
  - ✅ 컬러 팔레트 (Primary Blue, Purple, Pink, Gray Scale)
  - ✅ 그라데이션 정의 (Blue, Pink, Purple, Multi-color)
  - ✅ 타이포그래피 시스템 (Display ~ Caption, 7단계)
  - ✅ 다크/라이트 테마 기반 구조

#### 5.1.11 재사용 UI 컴포넌트 (100% 완료)

- **파일**: `lib/components/`
- **완료 항목**:
  - ✅ 네비게이션: BottomNavBar, AppBar, Drawer
  - ✅ 버튼: GradientButton, GameJoinButton, ThemedButton
  - ✅ 카드: GameCard, MyPickCard, BlockItemCard, CashAllocationCard
  - ✅ 시트: DraggableBottomSheet, SelectedBlocksSheet
  - ✅ 다이얼로그: AuthDialogs, ProgressOverlay, ResultOverlay
  - ✅ 그리드 컴포넌트: Minimap, ZoomControls, PickHUD, SectionOverlay

#### 5.1.12 데이터 모델 (100% 완료)

- **파일**: `lib/models/`
- **완료 항목**:
  - ✅ Freezed 기반 불변 모델
  - ✅ JSON 직렬화/역직렬화
  - ✅ 모델:
    - Game, GameItem, GameProduct, Product
    - GameRound (UI 어댑터)
    - OptimalGame
    - BlockModel, BlockState
    - User, UserProfile, UserWallet, Transaction
    - Winner
    - EventBanner, ParticipationFeed, Announcement
    - EventCash
    - PickCluster, GridSection
    - EncryptionKeyStatus, EntryStatus
    - PlatformMode

---

### 5.2 🔄 진행 중인 기능 (In Progress Features)

#### 5.2.1 인증 UI (50% 완료)

- **파일**:
  - `lib/features/auth/presentation/pages/login_page.dart`
  - `lib/features/auth/presentation/pages/signup_page.dart`
  - `lib/features/auth/presentation/pages/forgot_password_page.dart`
- **완료 항목**:
  - ✅ 기본 페이지 레이아웃
  - ✅ 입력 필드 (이메일, 비밀번호)
  - ✅ 로그인/회원가입 버튼
- **미완료 항목**:
  - ❌ 폼 유효성 검사 UI
  - ❌ 에러 메시지 표시
  - ❌ 로딩 상태 UI
  - ❌ 성공/실패 애니메이션
  - ❌ 소셜 로그인 버튼 (Kakao, Naver, Google, Facebook)

#### 5.2.2 My Pick (참여 내역) (70% 완료)

- **파일**: `lib/features/my_pick/my_pick_screen.dart`
- **완료 항목**:
  - ✅ 탭 필터링 (ALL, DAILY, SELECT, VIBE)
  - ✅ 참여 내역 카드 UI
  - ✅ 게임 상세 바텀시트
  - ✅ 블록 좌표 표시
  - ✅ "그리드에서 보기" 버튼
- **미완료 항목**:
  - ❌ 실제 GraphQL API 연동 (현재 Mock 데이터)
  - ❌ 무한 스크롤
  - ❌ 참여 상태별 필터 (진행 중, 당첨, 낙첨)

#### 5.2.3 My 페이지 (지갑 관리) (60% 완료)

- **파일**: `lib/features/my/my_screen.dart`
- **완료 항목**:
  - ✅ Total Cash 카드 표시
  - ✅ Event Cash / Shopping Cash 분배
  - ✅ 액션 버튼 (충전, 환불, 내역)
  - ✅ 최근 거래 내역 리스트
  - ✅ UI 완성
- **미완료 항목**:
  - ❌ 실제 GraphQL API 연동 (현재 Mock 데이터)
  - ❌ 결제 시스템 연동
  - ❌ 환불 시스템 구현
  - ❌ KYC 인증

#### 5.2.4 Winners 화면 (30% 완료)

- **파일**: `lib/features/winners/winners_screen.dart`
- **완료 항목**:
  - ✅ 기본 화면 구조
- **미완료 항목**:
  - ❌ 당첨자 목록 표시
  - ❌ 상품 정보 표시
  - ❌ 상금 청구 기능
  - ❌ 당첨 발표 애니메이션

#### 5.2.5 Settings 화면 (30% 완료)

- **파일**: `lib/features/settings/settings_screen.dart`
- **완료 항목**:
  - ✅ 기본 화면 구조
- **미완료 항목**:
  - ❌ 계정 설정
  - ❌ 알림 설정
  - ❌ 언어 선택
  - ❌ 다크 모드 토글
  - ❌ 프라이버시 설정
  - ❌ 이용약관 표시
  - ❌ 로그아웃 기능

#### 5.2.6 Mall (쇼핑몰) (10% 완료)

- **파일**: `lib/features/mall/mall_screen.dart`
- **완료 항목**:
  - ✅ 플레이스홀더 화면
- **미완료 항목**:
  - ❌ 상품 카탈로그
  - ❌ 카테고리 페이지
  - ❌ 검색 (SERP)
  - ❌ 상품 상세 페이지 (PDP)
  - ❌ 장바구니
  - ❌ 결제
  - ❌ 주문 내역
  - ❌ 위시리스트

---

### 5.3 📋 향후 계획 기능 (Planned Features)

#### 5.3.1 소셜 로그인 (향후)

- **플랫폼**: Kakao, Naver, Google, Facebook
- **우선순위**: 중간
- **예상 개발 기간**: 1주

#### 5.3.2 프로필 관리 (향후)

- **기능**:
  - 아바타 업로드
  - 닉네임 변경
  - 프로필 편집
  - 계정 삭제
- **우선순위**: 중간
- **예상 개발 기간**: 1주

#### 5.3.3 결제 시스템 (향후)

- **기능**:
  - 캐시 충전 (카드, 계좌이체, 토스페이)
  - 환불 시스템
  - 결제 내역 조회
  - PG사 연동
- **우선순위**: 높음
- **예상 개발 기간**: 2주

#### 5.3.4 푸시 알림 (향후)

- **기능**:
  - 게임 시작 알림
  - 게임 마감 임박 알림
  - 당첨 알림
  - 이벤트 알림
- **우선순위**: 중간
- **예상 개발 기간**: 1주

#### 5.3.5 다국어 지원 (i18n) (향후)

- **언어**: 한국어, 영어
- **우선순위**: 낮음
- **예상 개발 기간**: 1주

#### 5.3.6 다크 모드 (향후)

- **우선순위**: 낮음
- **예상 개발 기간**: 3일

#### 5.3.7 테스팅 인프라 (향후)

- **기능**:
  - 단위 테스트
  - 위젯 테스트
  - 통합 테스트
  - 코드 커버리지 70% 목표
- **우선순위**: 높음 (MVP 이후)
- **예상 개발 기간**: 2주

#### 5.3.8 iOS 플랫폼 지원 (향후)

- **현재**: Android, Web만 테스트 완료
- **필요 작업**:
  - iOS 빌드 설정
  - iOS 디바이스 테스트
  - App Store 배포 준비
- **우선순위**: 높음
- **예상 개발 기간**: 1주

#### 5.3.9 성능 최적화 (향후)

- **기능**:
  - 이미지 캐싱
  - Lazy Loading
  - 번들 사이즈 최적화
  - 위젯 리빌드 최소화
  - 메모리 누수 감지
  - 배터리 최적화
- **우선순위**: 중간
- **예상 개발 기간**: 1주

---

### 5.4 기능 완료율 요약

| 기능 영역 | 완료율 | 상태 |
|-----------|--------|------|
| **그리드 렌더링** | 100% | ✅ 완료 |
| **블록 선택** | 100% | ✅ 완료 |
| **블록체인 통합** | 100% | ✅ 완료 |
| **게임 참가 플로우** | 100% | ✅ 완료 |
| **게임 목록/상세** | 100% | ✅ 완료 |
| **프라임(OPTIMAL) 게임** | 100% | ✅ 완료 |
| **인증 Backend** | 100% | ✅ 완료 |
| **인증 UI** | 50% | 🔄 진행 중 |
| **네비게이션** | 100% | ✅ 완료 |
| **홈 화면** | 100% | ✅ 완료 |
| **My Pick** | 70% | 🔄 진행 중 |
| **My 페이지** | 60% | 🔄 진행 중 |
| **Winners** | 30% | 🔄 진행 중 |
| **Settings** | 30% | 🔄 진행 중 |
| **Mall** | 10% | 🔄 진행 중 |
| **디자인 시스템** | 100% | ✅ 완료 |
| **UI 컴포넌트** | 100% | ✅ 완료 |
| **GraphQL 통합** | 100% | ✅ 완료 |
| **소셜 로그인** | 0% | 📋 향후 |
| **결제 시스템** | 0% | 📋 향후 |
| **푸시 알림** | 0% | 📋 향후 |
| **다국어** | 0% | 📋 향후 |
| **테스팅** | 0% | 📋 향후 |

**전체 진행률**: **70% 완료**

---

## 6. 개발 로드맵

### 6.1 개발 일정

#### 6.1.1 Phase 7 (현재) - 2025년 11월 1일 ~ 11월 30일 ✅ 진행 중

**목표**: 블록체인 연동 게임 참가 완료

**완료 항목**:
- ✅ 블록체인 지갑 생성/관리
- ✅ 스마트 컨트랙트 연동
- ✅ 좌표 암호화 (AES-256)
- ✅ 지갑 주소 해시화 (SHA-256)
- ✅ joinGame Mutation
- ✅ E2E 게임 참가 플로우
- ✅ 폴링 서비스 (암호화 키, 참가 상태)
- ✅ Toss 스타일 UI/애니메이션

**남은 작업** (11월 30일까지):
- 🔄 실제 블록체인 네트워크 테스트 (Polygon Amoy Testnet)
- 🔄 에러 케이스 추가 테스트
- 🔄 성능 테스트 (대규모 참가자 시뮬레이션)

#### 6.1.2 Phase 8 - 2025년 12월 1일 ~ 12월 31일 📋 예정

**목표**: DAILY, SELECT, VIBE, PRIME 4가지 게임 타입 MVP 완성

**주요 작업**:

**Week 1 (12/1 ~ 12/7): 인증 UI 완성**
- 로그인/회원가입 폼 유효성 검사
- 에러 메시지 표시
- 로딩 상태 UI
- 성공/실패 애니메이션

**Week 2 (12/8 ~ 12/14): My Pick & My 페이지 완성**
- My Pick GraphQL API 연동
- My 페이지 GraphQL API 연동
- 캐시 관리 기능 (충전/환불은 Mock)

**Week 3 (12/15 ~ 12/21): Winners & Settings**
- Winners 화면 완성
- Settings 화면 기본 기능 구현
- 로그아웃 기능

**Week 4 (12/22 ~ 12/31): MVP 통합 테스트 & 버그 수정**
- 4가지 게임 타입 E2E 테스트
- 버그 수정
- 성능 최적화
- 문서화

**마일스톤**:
- 12/31: **MVP 완성** 🎯

#### 6.1.3 Phase 9 - 2025년 1월 (예정) 📋 향후

**목표**: 런칭 준비

**주요 작업**:
- 결제 시스템 연동 (PG사)
- 소셜 로그인 (Kakao, Naver)
- 푸시 알림
- iOS 빌드 & 테스트
- App Store / Google Play Store 등록 준비
- 베타 테스트
- 서버 부하 테스트

**마일스톤**:
- 1/31: **런칭 준비 완료** (예정)

#### 6.1.4 Phase 10 - 2025년 2월 (예정) 📋 향후

**목표**: 정식 런칭

**주요 작업**:
- 앱 스토어 심사
- 마케팅 준비
- 고객 지원 체계 구축
- 모니터링 시스템 구축

**마일스톤**:
- 2/28: **정식 런칭** 🚀 (예정)

### 6.2 일정 Gantt Chart

```
2025년

11월                 12월                 1월                  2월
│                    │                    │                    │
├─ Phase 7 ─────────┤
│ 블록체인 연동      │
│ ✅ 완료 예정       │
│                    │
                     ├─ Phase 8 ─────────┤
                     │ 4가지 게임 타입    │
                     │ MVP 완성           │
                     │                    │
                                          ├─ Phase 9 ─────────┤
                                          │ 런칭 준비          │
                                          │                    │
                                                               ├─ Phase 10 ───┤
                                                               │ 정식 런칭      │
                                                               │                │
                                                                                └─ 🚀
```

---

## 7. 비즈니스 메트릭 및 KPI

### 7.1 핵심 지표 (Key Performance Indicators)

#### 7.1.1 사용자 지표

| 지표 | 설명 | 목표 (MVP 3개월 후) |
|------|------|---------------------|
| **DAU** | 일일 활성 사용자 수 | 10,000명 |
| **MAU** | 월간 활성 사용자 수 | 50,000명 |
| **Retention (D7)** | 7일 유지율 | 30% |
| **Retention (D30)** | 30일 유지율 | 15% |

#### 7.1.2 게임 참여 지표

| 지표 | 설명 | 목표 |
|------|------|------|
| **게임 참여율** | 게임 조회 → 참여 전환율 | 15% |
| **재참여율** | 한 번 참여한 사용자의 재참여 비율 | 40% |
| **평균 참여 금액** | 사용자당 평균 게임 참여 금액 | 5,000원 |
| **평균 참여 횟수** | 사용자당 월평균 게임 참여 횟수 | 5회 |

#### 7.1.3 수익 지표

| 지표 | 설명 | 목표 (월간) |
|------|------|-------------|
| **GMV** | 총 거래액 (Gross Merchandise Value) | 5억 원 |
| **Revenue** | 플랫폼 수수료 수익 | 4.5억 원 (90%) |
| **ARPU** | 사용자당 평균 수익 | 9,000원 |
| **LTV** | 사용자 생애 가치 | 50,000원 |

#### 7.1.4 기술 지표

| 지표 | 설명 | 목표 |
|------|------|------|
| **그리드 렌더링 FPS** | 그리드 렌더링 프레임율 | 60 FPS |
| **앱 크래시율** | 앱 충돌 비율 | < 0.5% |
| **API 응답 시간** | GraphQL API 평균 응답 시간 | < 500ms |
| **블록체인 트랜잭션 성공률** | 게임 참가 트랜잭션 성공률 | > 95% |

### 7.2 비즈니스 모델 수치

#### 7.2.1 예시 게임

**게임**: iPhone 15 Pro (정가 150만 원)

| 항목 | 값 |
|------|-----|
| **참가비** | 1,000원 |
| **그리드 크기** | 500×500 (25만 블록) |
| **최대 참가자 수** | 25만 명 |
| **예상 참가자 수** | 10만 명 (40% 참여율) |
| **총 거래액 (GMV)** | 1억 원 (10만 × 1,000원) |
| **상품 가격** | 150만 원 |
| **플랫폼 수수료** | 9,850만 원 (98.5%) |
| **당첨자 수** | 1명 |

**수익성**:
- 수수료율: 98.5% (상품 가격 대비)
- ROI: 6,566% (9,850만 원 / 150만 원)

#### 7.2.2 월간 수익 시뮬레이션

**가정**:
- MAU: 50,000명
- 사용자당 월평균 참여: 5회
- 평균 참가비: 1,000원
- 총 월간 참여: 250,000회

| 항목 | 값 |
|------|-----|
| **총 거래액 (GMV)** | 2.5억 원 (250,000 × 1,000원) |
| **총 상품 가격** | 2,500만 원 (10% 가정) |
| **플랫폼 수수료** | 2.25억 원 (90%) |

**연간 수익 예상**: **27억 원**

### 7.3 성장 전략

#### 7.3.1 초기 사용자 확보 (Launch ~ 3개월)

**목표**: MAU 50,000명

**전략**:
1. **인플루언서 마케팅**
   - MZ세대 유튜버/인스타그래머 협업
   - 럭키드로우 참여 영상 콘텐츠
   - 예산: 월 2,000만 원

2. **이벤트 캐시 지급**
   - 신규 가입 사용자에게 무료 캐시 지급
   - 첫 게임 참여 시 추가 캐시
   - 예산: 월 1,000만 원

3. **SNS 광고**
   - Instagram, Facebook 타겟 광고
   - "블록체인 기반 공정한 럭키드로우" 강조
   - 예산: 월 1,500만 원

#### 7.3.2 재참여 유도 (3개월 ~ 6개월)

**목표**: D30 Retention 15%

**전략**:
1. **푸시 알림**
   - 게임 마감 임박 알림
   - 신규 게임 알림
   - 개인화된 추천 게임

2. **리워드 프로그램**
   - 연속 참여 보너스
   - 레벨 시스템 (참여 횟수에 따라 혜택)
   - 친구 초대 이벤트

3. **커뮤니티 구축**
   - 당첨자 인터뷰 콘텐츠
   - 사용자 후기 공유
   - 블록 선택 전략 공유 게시판

#### 7.3.3 수익 극대화 (6개월 ~)

**목표**: ARPU 12,000원

**전략**:
1. **프리미엄 게임**
   - 고가 상품 게임 (MacBook, 자동차 등)
   - 높은 참가비 (5,000원 ~ 10,000원)

2. **쇼핑몰 연계**
   - 럭키드로우 낙첨 시 할인 쿠폰 제공
   - 일반 구매 유도

3. **B2B 모델**
   - 브랜드사와 협업 (예: 삼성, 애플)
   - 브랜드 프로모션 게임 진행
   - 광고 수익

---

## 8. 리스크 관리

### 8.1 기술적 리스크

#### 8.1.1 블록체인 네트워크 안정성

**리스크**:
- Polygon Amoy Testnet 불안정 (네트워크 다운, 느린 응답)
- Gas 비용 급등

**대응 방안**:
- 다중 RPC 엔드포인트 설정 (Fallback)
- Gas 비용 모니터링 및 상한선 설정
- Mainnet 전환 시기 신중히 결정

#### 8.1.2 대규모 트래픽 처리

**리스크**:
- 동시 접속자 급증 시 서버 부하
- 그리드 렌더링 성능 저하

**대응 방안**:
- 서버 오토 스케일링 (AWS/GCP)
- CDN 활용 (이미지 캐싱)
- 그리드 렌더링 최적화 지속

#### 8.1.3 보안 취약점

**리스크**:
- 지갑 개인키 탈취
- 스마트 컨트랙트 해킹

**대응 방안**:
- FlutterSecureStorage로 안전한 저장
- 스마트 컨트랙트 감사 (Audit)
- 정기적인 보안 점검

### 8.2 비즈니스 리스크

#### 8.2.1 규제 리스크

**리스크**:
- 럭키드로우 관련 법적 규제
- 블록체인 게임 규제

**대응 방안**:
- 법률 자문 확보
- 투명한 운영 (블록체인 기록 공개)
- 미성년자 참여 제한

#### 8.2.2 경쟁사 진입

**리스크**:
- 대형 플랫폼의 유사 서비스 출시

**대응 방안**:
- 기술적 차별화 (대형 그리드, 블록체인)
- 빠른 시장 선점
- 커뮤니티 구축으로 브랜드 로열티 확보

#### 8.2.3 사용자 신뢰 문제

**리스크**:
- "정말 공정한가?" 의심
- 블록체인 기술 이해 부족

**대응 방안**:
- 투명성 강조 (모든 과정 공개)
- 쉬운 설명 콘텐츠 (튜토리얼, 가이드)
- 당첨자 후기 적극 공유

### 8.3 운영 리스크

#### 8.3.1 상품 조달 문제

**리스크**:
- 상품 공급 지연
- 가짜 상품 논란

**대응 방안**:
- 신뢰할 수 있는 공급처 확보
- 정품 인증서 제공
- 상품 사진 및 영상 공개

#### 8.3.2 고객 지원 부하

**리스크**:
- 사용자 문의 급증 (당첨, 환불 등)
- CS 인력 부족

**대응 방안**:
- FAQ 및 자동 응답 챗봇
- CS 팀 확대
- 커뮤니티 기반 지원 (유저 간 도움)

---

## 9. 부록

### 9.1 용어 정의

| 용어 | 정의 |
|------|------|
| **블록 (Block)** | 게임 그리드를 구성하는 하나의 칸 (셀) |
| **픽 (Pick)** | 사용자가 선택한 블록 |
| **그리드 (Grid)** | 블록으로 구성된 N×M 크기의 격자판 |
| **스마트 컨트랙트** | 블록체인에 배포된 자동 실행 프로그램 (코드로 작성된 계약) |
| **지갑 (Wallet)** | 블록체인 계정 (공개키와 개인키의 쌍) |
| **암호화 키** | 좌표를 암호화하는 데 사용되는 키 (AES-256) |
| **해시 (Hash)** | SHA-256 등으로 일방향 변환된 값 (복호화 불가능) |
| **JWT** | JSON Web Token, 인증 토큰 형식 |
| **GraphQL** | 쿼리 언어 기반 API |
| **Riverpod** | Flutter 상태 관리 라이브러리 |
| **LOD** | Level of Detail, 줌 레벨에 따른 세밀도 조절 시스템 |
| **Viewport Culling** | 화면에 보이지 않는 영역을 렌더링하지 않는 최적화 기법 |
| **Polygon Amoy Testnet** | Polygon 블록체인의 테스트 네트워크 |
| **GMV** | Gross Merchandise Value, 총 거래액 |
| **ARPU** | Average Revenue Per User, 사용자당 평균 수익 |
| **LTV** | Lifetime Value, 사용자 생애 가치 |
| **DAU** | Daily Active Users, 일일 활성 사용자 수 |
| **MAU** | Monthly Active Users, 월간 활성 사용자 수 |

### 9.2 기술 스택 전체 목록

#### 9.2.1 Frontend (Mobile)

```yaml
dependencies:
  flutter: 3.35.6
  dart: 3.9.2

  # State Management
  flutter_riverpod: 2.6.1
  riverpod_annotation: 2.6.1

  # Code Generation
  freezed: 2.5.7
  freezed_annotation: 2.4.4
  json_serializable: 6.8.0

  # Navigation
  go_router: 14.6.2

  # GraphQL
  graphql_flutter: 5.1.2

  # Blockchain
  web3dart: 2.7.3
  bip39: 1.0.6 (선택)

  # Storage
  flutter_secure_storage: 9.2.2
  shared_preferences: 2.3.3

  # UI
  cached_network_image: 3.4.1
  shimmer: 3.0.0

  # Utilities
  intl: 0.19.0
  crypto: 3.0.6

  # Platform Detection
  universal_io: 2.2.2
```

#### 9.2.2 Backend (예상)

```yaml
runtime: Node.js 18+
framework: Express.js / NestJS
api: GraphQL (Apollo Server)
database: PostgreSQL 14+
orm: Prisma / TypeORM
blockchain: web3.js / ethers.js
cache: Redis
queue: Bull (Redis-based)
```

#### 9.2.3 Infrastructure

```yaml
hosting: AWS / GCP
cdn: CloudFront / Cloud CDN
database: RDS (PostgreSQL) / Cloud SQL
storage: S3 / Cloud Storage
blockchain: Polygon Amoy Testnet → Mainnet
monitoring: Sentry, DataDog
ci_cd: GitHub Actions, AWS CodePipeline
```

### 9.3 팀 구성 (예상)

| 역할 | 인원 | 책임 |
|------|------|------|
| **프로젝트 매니저** | 1명 | 전체 일정 관리, 이해관계자 조율 |
| **백엔드 개발자** | 2명 | GraphQL API, 스마트 컨트랙트, DB |
| **모바일 개발자 (Flutter)** | 2명 | 앱 개발, UI 구현, 블록체인 연동 |
| **블록체인 개발자** | 1명 | 스마트 컨트랙트 개발, 블록체인 인프라 |
| **UI/UX 디자이너** | 1명 | 디자인 시스템, 화면 설계 |
| **QA 엔지니어** | 1명 | 테스트, 버그 리포트 |
| **DevOps 엔지니어** | 1명 | 인프라, 배포, 모니터링 |

**총 9명**

### 9.4 참조 문서

1. BlockPick 요구사명세서 (`/share/요구사명세서.md`)
2. 화면별 기능 명세서 (`/share/화면별_기능_명세서_기획자용.md`)
3. 전체 페이지 기능명세서 (`/share/전체_페이지_기능명세서.md`)
4. UX 개선 요약 (`/docs/UX_IMPROVEMENT_SUMMARY.md`)
5. GraphQL API 명세서 (백엔드 문서)
6. 스마트 컨트랙트 ABI (블록체인 문서)

### 9.5 연락처

| 역할 | 담당자 | 이메일 |
|------|--------|--------|
| PM | (이름) | pm@adrock.com |
| Tech Lead | (이름) | tech@adrock.com |
| Design Lead | (이름) | design@adrock.com |

---

## 📌 요약 (Summary)

### BlockPick이란?

블록체인 기술로 공정성과 투명성을 보장하는 **모바일 럭키드로우 게임 플랫폼**입니다.

### 핵심 차별화 포인트

1. **세계 최초 대형 그리드 (1,000×1,000) 모바일 렌더링** (60fps)
2. **블록체인 기반 투명성**: 모든 참가 과정이 블록체인에 기록
3. **AES-256 암호화**: 사용자 선택 좌표를 백엔드조차 알 수 없게 보호
4. **Toss 스타일 프리미엄 UX/UI**

### 현재 상태

- **진행률**: 70% 완료
- **11월말 목표**: 블록체인 연동 게임 참가 완료 ✅
- **12월말 목표**: 4가지 게임 타입 (DAILY, SELECT, VIBE, PRIME) MVP 완성 📋

### 비즈니스 모델

- **수익**: 게임 참가비 수수료 (평균 90%)
- **목표 월간 수익**: 2.25억 원 (MAU 50,000명 기준)
- **연간 수익 예상**: 27억 원

### 투자 포인트

1. **기술 혁신**: 세계 최초 모바일 대형 그리드 렌더링
2. **시장 선점**: 블록체인 기반 럭키드로우 퍼스트 무버
3. **확장 가능성**: 쇼핑몰 연계, B2B 모델
4. **투명성**: 블록체인으로 신뢰 구축

---

**문서 버전**: 1.0.0
**최종 업데이트**: 2025-11-20
**다음 리뷰 예정일**: 2025-12-01

---

**END OF DOCUMENT**
