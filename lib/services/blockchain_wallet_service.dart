import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';

/// 블록체인 지갑 관리 서비스
///
/// - 지갑 생성 및 저장 (Flutter Secure Storage)
/// - 지갑 로드
/// - 개인키는 디바이스에만 저장 (백엔드에 전송하지 않음)
class BlockchainWalletService {
  static const String _privateKeyKey = 'blockchain_wallet_private_key';
  static const String _addressKey = 'blockchain_wallet_address';
  static const String _mnemonicKey = 'blockchain_wallet_mnemonic';

  final FlutterSecureStorage _secureStorage;

  BlockchainWalletService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// 지갑 생성 (앱 최초 실행 시)
  ///
  /// Returns: (Credentials, mnemonic)
  Future<(Credentials, String?)> createWallet() async {
    print('🔑 새 블록체인 지갑 생성 중...');

    // 랜덤 지갑 생성
    final random = Random.secure();
    final credentials = EthPrivateKey.createRandom(random);

    // 개인키와 주소 추출
    final privateKeyHex = hex.encode(credentials.privateKey);
    final address = credentials.address.hex;

    // Secure Storage에 저장
    await _secureStorage.write(key: _privateKeyKey, value: privateKeyHex);
    await _secureStorage.write(key: _addressKey, value: address);

    print('✅ 지갑 생성 완료');
    print('   주소: $address');
    print('   ⚠️  개인키는 안전하게 저장되었습니다. 절대 공유하지 마세요!');

    // mnemonic은 EthPrivateKey에서 직접 지원하지 않으므로 null 반환
    // 필요시 bip39 패키지로 mnemonic 생성 가능
    return (credentials, null);
  }

  /// 저장된 지갑 로드
  ///
  /// Returns: Credentials 또는 null (지갑이 없는 경우)
  Future<Credentials?> loadWallet() async {
    try {
      final privateKeyHex = await _secureStorage.read(key: _privateKeyKey);

      if (privateKeyHex == null || privateKeyHex.isEmpty) {
        print('ℹ️  저장된 지갑이 없습니다.');
        return null;
      }

      // 16진수 문자열을 바이트로 변환
      final Uint8List privateKey = Uint8List.fromList(hex.decode(privateKeyHex));
      final credentials = EthPrivateKey(privateKey);

      final address = await _secureStorage.read(key: _addressKey);
      print('✅ 지갑 로드 완료: $address');

      return credentials;
    } catch (e) {
      print('❌ 지갑 로드 실패: $e');
      return null;
    }
  }

  /// 지갑 주소 가져오기 (Credentials 없이)
  Future<String?> getWalletAddress() async {
    return await _secureStorage.read(key: _addressKey);
  }

  /// 지갑 존재 여부 확인
  Future<bool> hasWallet() async {
    final privateKey = await _secureStorage.read(key: _privateKeyKey);
    return privateKey != null && privateKey.isNotEmpty;
  }

  /// 지갑 삭제 (테스트용 또는 초기화)
  Future<void> deleteWallet() async {
    await _secureStorage.delete(key: _privateKeyKey);
    await _secureStorage.delete(key: _addressKey);
    await _secureStorage.delete(key: _mnemonicKey);
    print('🗑️  지갑 삭제 완료');
  }

  /// 지갑 또는 생성 (자동)
  ///
  /// - 저장된 지갑이 있으면 로드
  /// - 없으면 새로 생성
  Future<Credentials> getOrCreateWallet() async {
    print('🔍 지갑 확인 중...');

    // 1. 기존 지갑 로드 시도
    final existingWallet = await loadWallet();
    if (existingWallet != null) {
      return existingWallet;
    }

    // 2. 지갑이 없으면 새로 생성
    print('📝 지갑이 없습니다. 새로 생성합니다...');
    final (newWallet, mnemonic) = await createWallet();

    // mnemonic이 있으면 사용자에게 백업 안내 (UI에서 처리)
    if (mnemonic != null) {
      print('⚠️  시드 구문 백업 필요: $mnemonic');
    }

    return newWallet;
  }
}
