# Claude Code - Plane 프로젝트 자동화

> AI 에이전트와 Python 스크립트로 프로젝트 기획부터 Plane 업로드까지 자동화합니다.

---

## 📁 구조

```
.claude/
├── agents/
│   └── project-planner.md    # 기획서 자동 생성 에이전트
├── CONTEXT.md                # 프로젝트 컨텍스트
├── README.md                 # 이 파일
└── settings.local.json       # 권한 설정
```

---

## 🚀 사용 방법

### 1️⃣ 프로젝트 기획 (에이전트)

자연어로 요청하면 `project-planner` 에이전트가 자동 실행됩니다:

```
"음식 배달 앱 기획해줘"
"플럭 음식 나눔 서비스 기획서 만들어줘"
"소셜 커머스 플랫폼 3개월 개발 계획 작성해줘"
```

**에이전트가 자동으로**:
1. 대화형으로 정보 수집 (서비스명, 기능, 기간, 팀)
2. `PLANE_PROJECT_TEMPLATE.md` 기반으로 기획서 생성
3. `plans/[service-name].md` 파일 저장
4. Cycles, Modules, Issues 자동 계산
5. 요약 출력

**생성되는 내용**:
- ✅ 프로젝트 개요 (목표, KPI, 팀 구성)
- ✅ Cycles (2주 단위 스프린트)
- ✅ Modules (핵심 기능별 에픽)
- ✅ Issues (상세 작업, Story Points 포함)
- ✅ States, Labels 정의
- ✅ 기술 스택, 보안 체크리스트

---

### 2️⃣ Plane 업로드 (명령어)

생성된 기획서를 Plane에 업로드합니다:

```bash
/upload-plan plans/food-delivery-app.md
```

또는 자연어로:

```
"이 기획서 Plane에 올려줘"
"plans/pluck-food-sharing.md 업로드해줘"
```

**실행되는 작업**:
```bash
python3 md_to_plane.py plans/food-delivery-app.md \
    --workspace pluck \
    --project [PROJECT_ID] \
    --api-key [API_KEY] \
    --api-url http://localhost:8090 \
    --yes
```

**Plane에 생성**:
- 모든 Issues
- 모든 Modules (Epics)
- Labels 연결
- 우선순위, 담당자, 날짜 설정

---

### 3️⃣ 기획서 목록 확인

```bash
/list-plans
```

`plans/` 디렉토리의 모든 기획서를 요약 표시:
- 서비스명
- Cycles 개수
- Modules 개수
- 총 Story Points
- 파일 크기

---

## 🎯 워크플로우 예시

### 전체 플로우

```bash
# 1단계: 기획
"음식 배달 앱 기획해줘"

Claude: [project-planner 에이전트 실행]
  → 서비스명? "Food Delivery App"
  → 타겟 사용자? "1인 가구, 직장인"
  → 핵심 기능? "1) 실시간 추적, 2) 리뷰 시스템, ..."
  → 개발 기간? "3개월"
  → 팀 구성? "백엔드 2, 프론트 2"
  → [기획서 생성중...]
  → ✅ plans/food-delivery-app.md 완성!

# 2단계: 확인
"기획서 보여줘"

Claude: [파일 내용 표시]

# 3단계: 수정 (필요시)
"푸시 알림 기능 추가해줘"

Claude: [md 파일 수정]

# 4단계: Plane 업로드
/upload-plan plans/food-delivery-app.md

Claude: [Python 스크립트 실행]
  → ✅ 52개 Issues 생성
  → ✅ 5개 Modules 생성
  → ✅ Plane에서 확인하세요!
```

---

## 📚 주요 파일 설명

### `.claude/agents/project-planner.md`
- **역할**: 전문 PM 에이전트
- **기능**: 대화형 정보 수집 → 기획서 자동 생성
- **출력**: `plans/[service-name].md`

### `.claude/commands/upload-plan.md`
- **역할**: Plane 업로드 명령어
- **기능**: Python 스크립트 실행
- **필요 정보**: Project ID, API Key

### `.claude/commands/list-plans.md`
- **역할**: 기획서 목록 조회
- **기능**: `plans/` 디렉토리 스캔 → 요약 출력

### `.claude/CONTEXT.md`
- **역할**: Claude가 프로젝트를 이해하기 위한 컨텍스트
- **포함**: 프로젝트 구조, 워크플로우, Best Practices

### `.claude/settings.local.json`
- **역할**: 권한 설정
- **포함**: Context7, Python, Docker 등 자동 승인

---

## 🛠️ 설정 정보

### Plane 접속
- **URL**: http://localhost:8090
- **Workspace**: pluck
- **API Key**: Settings → API Tokens에서 발급

### Python 스크립트
- **파일**: `md_to_plane.py`
- **역할**: Markdown → Plane API 변환
- **요구사항**: `pip install requests`

### 템플릿
- **파일**: `PLANE_PROJECT_TEMPLATE.md`
- **역할**: 에이전트가 참고하는 마스터 템플릿
- **섹션**: 13개 (Cycles, Modules, Issues 등)

---

## 💡 Best Practices

### 기획서 작성 시
1. **명확한 정보 제공**: 에이전트에게 구체적으로 답변
2. **현실적인 기간**: 3-6개월 권장
3. **적절한 팀 규모**: 과도한 인원 지양

### Plane 업로드 시
1. **Project ID 확인**: Plane URL에서 복사
2. **API Key 발급**: Settings → API Tokens
3. **권한 확인**: Project Admin 이상 필요

### 기획서 수정 시
1. **부분 수정**: 특정 섹션만 수정 요청
2. **재생성**: 전체 재작성보다 수정 권장
3. **버전 관리**: Git으로 변경 이력 추적

---

## 🔗 관련 파일

| 파일 | 설명 |
|------|------|
| `../PLANE_PROJECT_TEMPLATE.md` | 기획서 마스터 템플릿 |
| `../md_to_plane.py` | Plane 업로드 스크립트 |
| `../plans/` | 생성된 기획서들 |
| `../README.md` | 프로젝트 메인 문서 |

---

## ❓ 문제 해결

### 에이전트가 실행 안 될 때
- Claude에게 명시적으로 요청: "project-planner 에이전트로 기획해줘"

### 업로드 실패 시
1. Plane이 실행 중인지 확인: `curl http://localhost:8090`
2. API 키가 유효한지 확인
3. Project ID가 정확한지 확인

### 기획서 생성 오류
1. `PLANE_PROJECT_TEMPLATE.md` 존재 확인
2. `plans/` 디렉토리 생성 확인
3. 에이전트에게 정보를 충분히 제공했는지 확인

---

**마지막 업데이트**: 2025-01-09
**버전**: 2.0.0 (에이전트 기반)
