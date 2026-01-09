import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verification_state_provider.g.dart';

/// SMS/이메일 인증 상태를 관리하는 Provider
/// 인증 완료 후 뒤로갔다가 다시 와도 인증 상태 유지
class VerificationState {
  final String? verifiedPhoneE164;
  final String? verifiedEmail;
  final DateTime? phoneVerifiedAt;
  final DateTime? emailVerifiedAt;

  const VerificationState({
    this.verifiedPhoneE164,
    this.verifiedEmail,
    this.phoneVerifiedAt,
    this.emailVerifiedAt,
  });

  /// SMS 인증이 완료되었는지 확인 (24시간 유효)
  bool isPhoneVerified(String phoneE164) {
    if (verifiedPhoneE164 != phoneE164) return false;
    if (phoneVerifiedAt == null) return false;

    final now = DateTime.now();
    final diff = now.difference(phoneVerifiedAt!);
    return diff.inHours < 24;
  }

  /// 이메일 인증이 완료되었는지 확인 (24시간 유효)
  bool isEmailVerified(String email) {
    if (verifiedEmail != email) return false;
    if (emailVerifiedAt == null) return false;

    final now = DateTime.now();
    final diff = now.difference(emailVerifiedAt!);
    return diff.inHours < 24;
  }

  VerificationState copyWith({
    String? verifiedPhoneE164,
    String? verifiedEmail,
    DateTime? phoneVerifiedAt,
    DateTime? emailVerifiedAt,
  }) {
    return VerificationState(
      verifiedPhoneE164: verifiedPhoneE164 ?? this.verifiedPhoneE164,
      verifiedEmail: verifiedEmail ?? this.verifiedEmail,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}

@Riverpod(keepAlive: true)
class Verification extends _$Verification {
  @override
  VerificationState build() {
    return const VerificationState();
  }

  /// SMS 인증 완료 표시
  void markPhoneVerified(String phoneE164) {
    state = state.copyWith(
      verifiedPhoneE164: phoneE164,
      phoneVerifiedAt: DateTime.now(),
    );
  }

  /// 이메일 인증 완료 표시
  void markEmailVerified(String email) {
    state = state.copyWith(
      verifiedEmail: email,
      emailVerifiedAt: DateTime.now(),
    );
  }

  /// 인증 상태 초기화 (회원가입 완료 후 호출)
  void clear() {
    state = const VerificationState();
  }
}
