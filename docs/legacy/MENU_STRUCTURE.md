# BlockPick 메뉴 구조 (Menu Structure)

## 개요 (Overview)

BlockPick은 크게 **APP**, **OFFICIAL WEB**, **MALL** 3개의 플랫폼으로 구성되어 있습니다.

현재 개발 중인 Flutter 앱은 **APP > PICK** 영역에 해당합니다.

---

## 📱 APP

### PICK (현재 개발 중인 영역)

#### 1️⃣ STAGE
**Main** - 'stage' 메인 페이지
- **How to Play?** - 'stage' 를 설명 페이지
- **Now Picking** - 진행중인 게임 목록 화면
  - **Game Board** - 게임 플레이 화면 ✅ **현재 개발 완료**
    - 그리드 기반 블록 선택 시스템
    - 팬/줌 기능 (모바일, 웹 모두 지원)
    - 배경 이미지 렌더링 (제품 이미지)
    - 선택된 블록 바텀시트
    - LOD 및 Viewport Culling 최적화
- **Game History** - 종료된 게임 목록 화면
- **Up Coming Game** - 대기중인 게임 목록 화면

#### 2️⃣ SELECT
**Main** - 'stage' 메인 페이지
- **How to Play?** - 'stage' 를 설명 페이지
- **Now Picking** - 진행중인 게임 목록 화면
  - **Game Board** - 게임 플레이 화면
- **Game History** - 종료된 게임 목록 화면
- **Up Coming Game** - 대기중인 게임 목록 화면

#### 3️⃣ VIBE
**Main** - 'stage' 메인 페이지
- **How to Play?** - 'stage' 를 설명 페이지
- **Now Picking** - 진행중인 게임 목록 화면
  - **Game Board** - 게임 플레이 화면
- **Game History** - 종료된 게임 목록 화면
- **Up Coming Game** - 대기중인 게임 목록 화면

---

### MY

#### Payment & Bill
- 결제 내역, 포인트 충전 등
- **Add card** - 카드 등록
- **Charge Point** - 포인트 충전

#### My pick
- 게임 참여 이력, 당첨 체크 조회 등
- **STAGE**
  - **Claim Prize** - 상금 수령
- **SELECT**
  - **Claim Prize** - 상금 수령
- **VIBE**
  - **Claim Prize** - 상금 수령

#### Profile
- 배송지 등 프로필 정보 수정

#### Help
- 고객센터 상담

---

### Log in
- **Sign up** - 회원가입
- **Forgot PW?** - 비밀번호 찾기

---

## 🌐 OFFICIAL WEB

### Block Pick?
- 서비스 소개

### GAMES

#### STAGE
- 스테이지 게임 안내

#### SELECT
- 셀렉트 게임 안내

#### VIBE
- 바이브 게임 안내

---

### Credit

#### Cash
- 캐시 충전 안내

#### Point
- 포인트 시스템 안내

---

### Resource

#### Blog
- 블로그 링크

#### News
- 뉴스/공지사항

#### SNS
- 소셜 미디어 링크
- X (Twitter)
- Instagram
- Discord

#### Help center
- 고객센터

---

## 🛒 MALL

### SHOP

#### Main
- Mall 메인 화면

#### Category Page
- 카테고리별 검색 화면

#### SERP
- 키워드 검색 화면

#### PDP
- 제품 상세 페이지

---

### MY

#### Order
- 주문 내역

#### BILL
- 영수증

#### refund
- 환불/신청

#### change
- 교환/반품 신청

#### Profile
- 프로필 설정

#### Q&A
- 문의 내역

#### Address
- 배송지 관리

#### CART
- 장바구니

#### wishlist
- 찜

---

### payment

#### check-out
- 결제 페이지

#### completed
- 결제 완료

---

### Log in
- **Sign up** - 회원가입
- **Forgot PW?** - 비밀번호 찾기

---

## ✅ 현재 개발 완료 상태

### APP > PICK > STAGE/SELECT/VIBE > Now Picking > Game Board

#### 구현된 기능

1. **그리드 시스템**
   - CustomPaint 기반 렌더링
   - LOD (Level of Detail) 시스템
   - Sparse Grid 최적화
   - Viewport Culling
   - 최대 10,000 x 10,000 그리드 지원

2. **제스처 처리**
   - 팬/줌 (모바일 터치 + 웹 마우스)
   - 블록 선택/해제
   - 줌 레벨에 따른 셀 선택 임계값

3. **배경 이미지**
   - 제품 이미지 배경 렌더링
   - 그리드와 함께 팬/줌 동기화

4. **선택된 블록 바텀시트** (재사용 가능한 컴포넌트)
   - 모바일(터치) 및 웹(마우스) 드래그 지원
   - 선택된 블록 리스트
   - CLEAR 버튼
   - 제출 버튼
   - 바텀시트 닫기/열기 상태 관리

5. **재사용 가능한 컴포넌트**
   - `DraggableBottomSheet` - 범용 드래그 바텀시트
   - `BlockItemCard` - 블록 아이템 카드
   - `GradientButton` - 그라데이션 버튼

6. **상태 관리**
   - Riverpod 기반
   - `GridState` - 줌, 팬, 선택된 블록, 바텀시트 표시 여부

7. **플랫폼 지원**
   - ✅ Android (에뮬레이터 테스트 완료)
   - ✅ Web (Chrome, http://localhost:8081)
   - ⏳ iOS (향후 테스트 예정)

---

## 📁 프로젝트 구조

```
lib/
  components/              # 재사용 가능한 컴포넌트
    sheets/
      draggable_bottom_sheet.dart
    cards/
      block_item_card.dart
    buttons/
      gradient_button.dart
  features/
    game/
      game_screen.dart              # 게임 메인 화면
      selected_blocks_sheet.dart    # 선택된 블록 바텀시트
    grid/
      game_grid_widget.dart         # 그리드 위젯
      grid_painter.dart             # 그리드 렌더링
  models/
    block_model.dart                # 블록 데이터 모델
    game_round_model.dart           # 게임 라운드 모델
  providers/
    grid_state_provider.dart        # 그리드 상태 관리
  core/
    theme/
      app_colors.dart
      app_text_styles.dart
    constants/
      app_constants.dart
  data/
    mock_game_data.dart             # 목 데이터
```

---

## 🚀 다음 개발 예정 항목

1. **Now Picking (게임 목록 화면)**
   - Daily/Select/Vibe 게임 카드 리스트
   - 게임 상태별 필터링

2. **How to Play? (게임 설명 페이지)**
   - 게임 규칙 설명
   - 튜토리얼

3. **Game History / Up Coming Game**
   - 종료된 게임 / 예정된 게임 목록

4. **Payment & Bill**
   - 결제 시스템 연동
   - 포인트 충전

5. **My pick**
   - 참여한 게임 이력
   - 상금 수령 기능

---

## 📝 참고 사항

- 현재 개발은 **APP > PICK** 영역에 집중
- STAGE, SELECT, VIBE는 게임 방식만 다르고 UI/UX는 동일
- Mock 데이터를 사용하여 개발 중 (추후 API 연동 예정)
- 웹과 모바일 모두 지원하는 크로스 플랫폼 개발
