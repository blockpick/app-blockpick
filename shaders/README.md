# BlockPick Shader Effects

BlockPick 게임 배경에 사용되는 Fragment Shader 모음입니다. 각 셰이더는 고유한 시각적 효과를 제공합니다.

## 📁 셰이더 목록

### 1. **glow_effect.frag** - Accretion (강착 디스크)
블랙홀 주변의 강착 디스크를 시뮬레이션한 효과입니다.

**특징:**
- 회전하는 소용돌이 패턴
- 중앙의 어두운 블랙홀
- 보라-청록-핑크-오렌지 색상 그라데이션
- 노이즈 기반 난류 효과
- 시간에 따라 천천히 회전

**사용 예시:**
```dart
_GlowBackground(shaderPath: 'shaders/glow_effect.frag')
```

---

### 2. **flowing_waves.frag** - Flowing Waves (흐르는 파도)
깊은 바다의 파도를 표현한 효과입니다.

**특징:**
- 다층 파도 애니메이션
- FBM(Fractional Brownian Motion) 노이즈
- 깊은 파랑 계열 색상
- 반짝이는 물결 효과
- 부드러운 비네팅

**사용 예시:**
```dart
_GlowBackground(shaderPath: 'shaders/flowing_waves.frag')
```

---

### 3. **ether.frag** - Ether (신비로운 에테르)
3D 공간을 떠다니는 신비로운 에테르 구름 효과입니다.

**특징:**
- 3D 노이즈 시뮬레이션
- 회전하는 구름 패턴
- 보라-청록-핑크 색상 변화
- 발광 효과
- 시간에 따라 변화하는 밀도

**사용 예시:**
```dart
_GlowBackground(shaderPath: 'shaders/ether.frag')
```

---

### 4. **shooting_stars.frag** - Shooting Stars (별똥별)
밤하늘의 유성과 별들을 표현한 효과입니다.

**특징:**
- 50개의 반짝이는 별
- 8개의 유성 애니메이션
- 유성 꼬리 효과
- 은하수 효과
- 깊은 밤하늘 그라데이션

**사용 예시:**
```dart
_GlowBackground(shaderPath: 'shaders/shooting_stars.frag')
```

---

### 5. **wavy_lines.frag** - Wavy Lines (물결치는 선)
무지개 색상의 물결치는 선들이 흐르는 효과입니다.

**특징:**
- 20개의 독립적인 파형
- 무지개 그라데이션
- 글로우 효과
- 노이즈 기반 불규칙성
- 시간에 따라 흐르는 애니메이션

**사용 예시:**
```dart
_GlowBackground(shaderPath: 'shaders/wavy_lines.frag')
```

---

### 6. **aurora.frag** - Aurora (오로라)
북극 오로라를 표현한 효과입니다.

**특징:**
- 흐르는 오로라 커튼
- FBM 노이즈 기반 흐름
- 녹색-청록-보라-핑크 색상
- 40개의 반짝이는 별
- 수직 그라데이션 강도

**사용 예시:**
```dart
_GlowBackground(shaderPath: 'shaders/aurora.frag')
```

---

## 🎨 사용 방법

### 1. 셰이더 선택
AppBar의 팔레트 아이콘(🎨)을 클릭하여 원하는 셰이더를 선택합니다.

### 2. 코드에서 직접 변경
```dart
String _currentShader = 'shaders/aurora.frag'; // 원하는 셰이더로 변경
```

---

## ⚙️ 커스터마이징

각 셰이더의 파라미터를 조정하여 원하는 효과를 만들 수 있습니다:

### 색상 변경
```glsl
// 셰이더 파일에서 색상 값 수정
vec3 color1 = vec3(0.48, 0.30, 1.0);  // RGB 값 (0.0 ~ 1.0)
```

### 애니메이션 속도 조정
```glsl
// 시간 곱셈 값 변경
float phase = uTime * 0.5;  // 0.5를 조정하여 속도 변경
```

### Dart 코드에서 애니메이션 속도 조정
```dart
_controller = AnimationController(
  duration: const Duration(seconds: 8), // 8초를 원하는 값으로 변경
  vsync: this,
)..repeat();
```

---

## 🔧 기술 스택

- **GLSL Version**: 460 core
- **Flutter**: Fragment Shader (dart:ui)
- **노이즈 함수**: Hash-based pseudo-random
- **애니메이션**: AnimationController

---

## 📝 참고사항

1. **성능**: 모든 셰이더는 모바일 디바이스에서 60fps를 유지하도록 최적화되었습니다.
2. **호환성**: Flutter 3.0 이상에서 작동합니다.
3. **메모리**: 셰이더 변경 시 이전 셰이더는 자동으로 dispose됩니다.

---

## 🎯 성능 팁

- 복잡한 셰이더(ether, aurora)는 저사양 기기에서 성능 저하가 있을 수 있습니다.
- 배터리 절약이 필요한 경우 flowing_waves나 wavy_lines를 추천합니다.
- 노이즈 반복 횟수를 줄이면 성능이 향상됩니다.

---

**Created by**: BlockPick Dev Team
**Last Updated**: 2025-11-20
