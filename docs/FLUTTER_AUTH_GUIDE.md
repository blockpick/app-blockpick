# Flutter GraphQL 인증 구현 가이드

Next.js 프로젝트의 GraphQL 인증을 Flutter Riverpod로 완벽히 이식했습니다.

## 📁 프로젝트 구조

```
lib/
├── core/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart    # GraphQL API 호출
│   │   │   │   └── token_local_datasource.dart    # 토큰 저장/불러오기
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart           # 인증 비즈니스 로직
│   │   └── domain/
│   │       ├── models/
│   │       │   └── user.dart                      # User 모델 (Freezed)
│   │       └── providers/
│   │           └── auth_provider.dart             # 인증 상태 Provider
│   ├── graphql/
│   │   └── graphql_client.dart                    # GraphQL 클라이언트
│   └── router/
│       └── router.dart                            # GoRouter 설정
└── features/
    └── auth/
        └── presentation/
            └── pages/
                └── login_page.dart                # 로그인 화면
```

## 🚀 설치된 패키지

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.5
  graphql_flutter: ^5.1.2
  flutter_secure_storage: ^9.0.0
  go_router: ^14.0.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.8
  riverpod_generator: ^2.4.0
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

## 📊 Next.js → Flutter 변환 맵핑

| Next.js | Flutter Riverpod |
|---------|------------------|
| `localStorage` | `flutter_secure_storage` (더 안전) |
| Apollo Client | `graphql_flutter` |
| Zustand Store | Riverpod `@riverpod` class |
| `useAuth` hook | `authProvider` |
| Middleware | GoRouter `redirect` |
| `AuthRequired` component | GoRouter guard |
| Cookie | SecureStorage |

## 🔑 핵심 기능

### 1. 인증 상태 관리

```dart
// lib/core/auth/domain/providers/auth_provider.dart

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    // 앱 시작 시 저장된 토큰 자동 복원
    final repository = await ref.watch(authRepositoryProvider.future);
    final token = await repository.getToken();

    if (token == null) {
      return const AuthState();
    }

    // 백그라운드에서 유저 정보 가져오기 (Next.js와 동일한 로직)
    repository.getCurrentUser().then((user) {
      if (user != null) {
        state = AsyncData(AuthState(user: user, token: token));
      }
    }).catchError((_) {
      print('JWT 토큰으로 인증 유지');
    });

    return AuthState(token: token);
  }

  Future<void> signIn(String email, String password) async { ... }
  Future<void> signOut() async { ... }
}
```

### 2. 토큰 저장 (Secure Storage)

```dart
// lib/core/auth/data/datasources/token_local_datasource.dart

class TokenLocalDataSource {
  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth-token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth-token');
  }
}
```

### 3. GraphQL 클라이언트 (자동 토큰 주입)

```dart
// lib/core/graphql/graphql_client.dart

@riverpod
Future<GraphQLClient> graphqlClient(GraphqlClientRef ref) async {
  final tokenDataSource = ref.watch(tokenLocalDataSourceProvider);
  final token = await tokenDataSource.getToken();

  final AuthLink authLink = AuthLink(
    getToken: () async => token != null ? 'Bearer $token' : null,
  );

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: authLink.concat(HttpLink('https://api-dev.blockpick.net/api/graphql')),
  );
}
```

### 4. 라우팅 가드 (GoRouter)

```dart
// lib/core/router/router.dart

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    redirect: (context, state) {
      final protectedRoutes = ['/block-select', '/my-pick', ...];
      final isProtectedRoute = protectedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      // 보호된 경로인데 인증 안 됨 -> 로그인으로
      if (isProtectedRoute && !isAuthenticated) {
        return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
      }

      return null;
    },
    routes: [ ... ],
  );
});
```

## 💻 사용법

### 로그인

```dart
// UI에서 사용
await ref.read(authProvider.notifier).signIn(email, password);
```

### 로그아웃

```dart
await ref.read(authProvider.notifier).signOut();
```

### 인증 상태 확인

```dart
// 1. boolean 값으로 확인
final isAuth = ref.watch(isAuthenticatedProvider);

// 2. 현재 유저 정보
final user = ref.watch(currentUserProvider);

// 3. 토큰
final token = ref.watch(authTokenProvider);

// 4. 전체 상태 (loading/error 포함)
final authState = ref.watch(authProvider);
```

### UI에서 상태별 렌더링

```dart
ref.watch(authProvider).when(
  data: (authState) => authState.isAuthenticated
    ? Text('Welcome ${authState.user?.email}')
    : const Text('Please login'),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

## 🎯 GraphQL Mutations

### 로그인 Mutation

```graphql
mutation Login($input: LoginInput!) {
  login(input: $input) {
    token
    email
  }
}
```

### 회원가입 Mutation

```graphql
mutation Signup($input: SignupInput!) {
  signup(input: $input) {
    token
    email
  }
}
```

### Me Query (사용자 정보)

```graphql
query Me {
  me {
    id
    email
    name
    role
  }
}
```

## 🔧 코드 생성

파일 수정 후 반드시 실행:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

자동 watch 모드:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 📱 실행

```bash
flutter run
```

## 🎨 로그인 페이지 예제

이미 구현된 `lib/features/auth/presentation/pages/login_page.dart` 참고:

- 이메일/비밀번호 입력
- Form validation
- 로딩 상태 표시
- 에러 메시지 표시
- AsyncValue 활용

## 🛡️ 보안

1. **토큰 저장**: `flutter_secure_storage` 사용 (암호화)
2. **자동 로그인**: 앱 시작 시 토큰 자동 복원
3. **토큰 자동 주입**: GraphQL 요청마다 자동으로 Bearer 토큰 추가
4. **라우팅 보호**: 미인증 사용자는 보호된 경로 접근 불가

## 🆚 Next.js와의 차이점

| 항목 | Next.js | Flutter |
|------|---------|---------|
| 토큰 저장 | localStorage + Cookie | SecureStorage (더 안전) |
| 상태 관리 | Zustand | Riverpod |
| 라우팅 | Middleware | GoRouter guard |
| 자동 로그인 | AuthProvider useEffect | Auth Provider build() |
| 에러 처리 | try-catch | AsyncValue |

## ✅ 완료된 기능

- [x] User 모델 (Freezed)
- [x] Token 저장소 (SecureStorage)
- [x] GraphQL 클라이언트 (자동 토큰 주입)
- [x] Auth Remote DataSource
- [x] Auth Repository
- [x] Auth Provider (Riverpod)
- [x] GoRouter 설정 (라우팅 가드)
- [x] 로그인 페이지
- [x] 자동 로그인
- [x] 로그아웃

## 🚧 TODO (추가 구현 필요)

- [ ] 회원가입 페이지
- [ ] 비밀번호 찾기
- [ ] 유저 프로필 편집
- [ ] 토큰 만료 처리
- [ ] 리프레시 토큰 (백엔드 지원 시)

## 🎓 참고사항

### Provider 의존성 주의사항

Riverpod의 Provider들이 서로 의존하고 있습니다:

```
authProvider
  ↓
authRepositoryProvider
  ↓
graphqlClientProvider
  ↓
tokenLocalDataSourceProvider
```

### 상태 갱신

- 로그인/로그아웃 시 `graphqlClientProvider`가 자동으로 갱신됩니다
- 토큰이 변경되면 GraphQL 요청에 자동으로 새 토큰이 반영됩니다

## 📞 문의

구현 중 문제가 발생하면 다음을 확인하세요:

1. `flutter pub get` 실행했는지
2. `build_runner` 실행했는지
3. GraphQL endpoint가 올바른지 (`graphql_client.dart`)
4. Mutation/Query 스키마가 백엔드와 일치하는지

## 🎉 완료!

Next.js 프로젝트의 GraphQL 인증이 Flutter로 완벽히 이식되었습니다!
