import 'package:intl/intl.dart';

/// 시간 유틸리티 함수
class TimeUtils {
  /// 상대 시간 문자열 반환
  /// - 방금 전 (Just now): 0초 ~ 59초
  /// - n분 전 (nn minutes ago): 1분 ~ 59분
  /// - n시간 전 (nn hours ago): 1시간 ~ 23시간 59분
  /// - n일 전 (nn days ago): 1일 ~ 30일
  /// - n개월 전 (nn months ago): 1개월 ~ 11개월
  /// - yyyy.mm.dd: 1년 이상
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // 음수 (미래 시간)인 경우
    if (difference.isNegative) {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }

    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    // 방금 전 (0~59초)
    if (seconds < 60) {
      return '방금 전';
    }

    // n분 전 (1~59분)
    if (minutes < 60) {
      return '$minutes분 전';
    }

    // n시간 전 (1~23시간)
    if (hours < 24) {
      return '$hours시간 전';
    }

    // n일 전 (1~30일)
    if (days < 31) {
      return '$days일 전';
    }

    // n개월 전 (1~11개월)
    final months = (days / 30).floor();
    if (months < 12) {
      return '$months개월 전';
    }

    // 1년 이상
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }

  /// 영어 상대 시간 문자열 반환
  static String getRelativeTimeEn(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }

    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (seconds < 60) {
      return 'Just now';
    }

    if (minutes < 60) {
      return '$minutes minutes ago';
    }

    if (hours < 24) {
      return '$hours hours ago';
    }

    if (days < 31) {
      return '$days days ago';
    }

    final months = (days / 30).floor();
    if (months < 12) {
      return '$months months ago';
    }

    return DateFormat('yyyy.MM.dd').format(dateTime);
  }
}
