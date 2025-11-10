import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:convert/convert.dart';

/// 좌표 암호화 서비스
///
/// - 스마트 컨트랙트에서 받은 암호화 키로 좌표를 암호화
/// - AES-256-CBC 알고리즘 사용
/// - 백엔드에 암호화된 좌표만 전송 (백엔드는 복호화 불가)
class CoordinateEncryptionService {
  /// 좌표 암호화
  ///
  /// [row]: 행 좌표 (0-999)
  /// [col]: 열 좌표 (0-999)
  /// [encryptionKeyHex]: 스마트 컨트랙트에서 받은 64자리 hex 키
  ///
  /// Returns: Base64로 인코딩된 암호문
  String encryptCoordinate({
    required int row,
    required int col,
    required String encryptionKeyHex,
  }) {
    try {
      print('🔐 좌표 암호화 시작...');
      print('   좌표: ($row, $col)');
      print('   키: ${encryptionKeyHex.substring(0, 8)}...');

      // 1. 암호화 키 준비 (Hex → Bytes)
      var keyBytes = Uint8List.fromList(hex.decode(encryptionKeyHex));

      // AES-256은 32바이트(256비트) 키 필요
      // 스마트 컨트랙트가 16바이트 키를 반환하는 경우 32바이트로 확장
      if (keyBytes.length == 16) {
        print('   ⚠️  16바이트 키 감지 → 32바이트로 확장 (키 반복)');
        // 16바이트 키를 2번 반복하여 32바이트로 확장
        keyBytes = Uint8List.fromList([...keyBytes, ...keyBytes]);
        print('   ✓ 키 확장 완료: ${keyBytes.length}바이트');
      } else if (keyBytes.length != 32) {
        throw Exception(
          '암호화 키 길이 오류: ${keyBytes.length}바이트 (16 또는 32바이트 필요)',
        );
      }

      final key = Key(keyBytes);

      // 2. IV (Initialization Vector) 생성
      // 스마트 컨트랙트 키의 앞 16바이트를 IV로 사용 (결정론적 암호화)
      final iv = IV(Uint8List.fromList(keyBytes.sublist(0, 16)));

      // 3. 암호화 객체 생성
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // 4. 좌표 데이터 준비 (JSON 형식)
      final coordinateData = {
        'row': row,
        'col': col,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final plaintext = jsonEncode(coordinateData);
      print('   평문: $plaintext');

      // 5. 암호화 수행
      final encrypted = encrypter.encrypt(plaintext, iv: iv);
      final ciphertext = encrypted.base64;

      print('✅ 좌표 암호화 완료');
      print('   암호문: ${ciphertext.substring(0, 20)}...');
      print('   ⚠️  서버에 전달할 정보:');
      print('      - coordCiphertext: $ciphertext');
      print('      - 원본 키 (16바이트): $encryptionKeyHex');
      print('      - 확장 키 (32바이트): ${hex.encode(keyBytes.toList())}');

      return ciphertext;
    } catch (e) {
      print('❌ 좌표 암호화 실패: $e');
      rethrow;
    }
  }

  /// 좌표 복호화 (검증용)
  ///
  /// [ciphertext]: Base64 암호문
  /// [encryptionKeyHex]: 스마트 컨트랙트에서 받은 64자리 hex 키
  ///
  /// Returns: {row, col, timestamp}
  Map<String, dynamic> decryptCoordinate({
    required String ciphertext,
    required String encryptionKeyHex,
  }) {
    try {
      print('🔓 좌표 복호화 시작...');

      // 1. 암호화 키 준비
      var keyBytes = Uint8List.fromList(hex.decode(encryptionKeyHex));

      // 16바이트 키인 경우 32바이트로 확장 (암호화와 동일한 방식)
      if (keyBytes.length == 16) {
        keyBytes = Uint8List.fromList([...keyBytes, ...keyBytes]);
      }

      final key = Key(keyBytes);
      final iv = IV(Uint8List.fromList(keyBytes.sublist(0, 16)));

      // 2. 복호화 객체 생성
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      // 3. 복호화 수행
      final encrypted = Encrypted.fromBase64(ciphertext);
      final plaintext = encrypter.decrypt(encrypted, iv: iv);

      // 4. JSON 파싱
      final data = jsonDecode(plaintext) as Map<String, dynamic>;

      print('✅ 좌표 복호화 완료: (${data['row']}, ${data['col']})');

      return data;
    } catch (e) {
      print('❌ 좌표 복호화 실패: $e');
      rethrow;
    }
  }

  /// 여러 좌표 일괄 암호화
  ///
  /// [coordinates]: [(row, col), ...] 좌표 리스트
  /// [encryptionKeyHex]: 암호화 키
  ///
  /// Returns: Base64 암호문 리스트
  List<String> encryptMultipleCoordinates({
    required List<(int, int)> coordinates,
    required String encryptionKeyHex,
  }) {
    print('🔐 ${coordinates.length}개 좌표 일괄 암호화 시작...');

    final results = <String>[];

    for (var i = 0; i < coordinates.length; i++) {
      final (row, col) = coordinates[i];
      try {
        final encrypted = encryptCoordinate(
          row: row,
          col: col,
          encryptionKeyHex: encryptionKeyHex,
        );
        results.add(encrypted);
      } catch (e) {
        print('❌ 좌표 #$i ($row, $col) 암호화 실패: $e');
        rethrow;
      }
    }

    print('✅ 일괄 암호화 완료: ${results.length}개');
    return results;
  }
}
