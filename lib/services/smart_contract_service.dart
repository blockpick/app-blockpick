import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

/// 스마트 컨트랙트 서비스
///
/// - Ronin Mainnet RPC 연결
/// - requestEncryptionKey() 호출
/// - 트랜잭션 서명 및 전송
class SmartContractService {
  // Ronin Mainnet RPC URL
  static const List<String> _rpcUrls = [
    'https://api.roninchain.com/rpc',
  ];

  static const int _chainId = 2020; // Ronin Mainnet

  late Web3Client _client;
  late String _currentRpcUrl;

  SmartContractService() {
    _currentRpcUrl = _rpcUrls[0];
    _client = Web3Client(_currentRpcUrl, http.Client());
  }

  /// RPC 연결 테스트
  Future<bool> testConnection() async {
    try {
      final blockNumber = await _client.getBlockNumber();
      print('✅ RPC 연결 성공: Block #$blockNumber');
      return true;
    } catch (e) {
      print('❌ RPC 연결 실패: $e');

      // Fallback RPC 시도
      if (_rpcUrls.length > 1) {
        print('🔄 Fallback RPC로 재시도...');
        _currentRpcUrl = _rpcUrls[1];
        _client = Web3Client(_currentRpcUrl, http.Client());

        try {
          final blockNumber = await _client.getBlockNumber();
          print('✅ Fallback RPC 연결 성공: Block #$blockNumber');
          return true;
        } catch (e) {
          print('❌ Fallback RPC도 실패: $e');
        }
      }

      return false;
    }
  }

  /// 암호화 키 생성 요청 (스마트 컨트랙트 호출)
  ///
  /// [contractAddress]: 게임별 스마트 컨트랙트 주소
  /// [userIndex]: 사용자 고유 인덱스 (예: "wallet-timestamp")
  /// [credentials]: 사용자 지갑 (트랜잭션 서명용)
  ///
  /// Returns: (encryptionKey, transactionHash)
  Future<(String, String)> requestEncryptionKey({
    required String contractAddress,
    required String userIndex,
    required Credentials credentials,
  }) async {
    print('🔑 암호화 키 생성 요청 시작...');
    print('   컨트랙트: $contractAddress');
    print('   인덱스: $userIndex');

    try {
      // 컨트랙트 ABI 정의
      final contract = DeployedContract(
        ContractAbi.fromJson(
          '''
          [
            {
              "inputs": [
                {
                  "internalType": "string",
                  "name": "_index",
                  "type": "string"
                }
              ],
              "name": "requestEncryptionKey",
              "outputs": [
                {
                  "internalType": "string",
                  "name": "",
                  "type": "string"
                }
              ],
              "stateMutability": "nonpayable",
              "type": "function"
            },
            {
              "anonymous": false,
              "inputs": [
                {
                  "indexed": true,
                  "internalType": "string",
                  "name": "index",
                  "type": "string"
                },
                {
                  "indexed": true,
                  "internalType": "address",
                  "name": "sender",
                  "type": "address"
                },
                {
                  "indexed": false,
                  "internalType": "string",
                  "name": "key",
                  "type": "string"
                }
              ],
              "name": "EncryptionKeyGenerated",
              "type": "event"
            }
          ]
          ''',
          'BlockpickContract',
        ),
        EthereumAddress.fromHex(contractAddress),
      );

      // 함수 호출
      final function = contract.function('requestEncryptionKey');

      print('📤 트랜잭션 전송 중...');

      // 트랜잭션 전송
      final result = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [userIndex],
          maxGas: 500000, // Gas limit
        ),
        chainId: _chainId,
      );

      print('✅ 트랜잭션 전송 완료');
      print('   TX Hash: $result');

      // 트랜잭션 확인 대기
      print('⏳ 트랜잭션 확인 대기 중...');
      final receipt = await _waitForTransaction(result);

      if (receipt == null) {
        throw Exception('트랜잭션 receipt를 가져올 수 없습니다');
      }

      print('✅ 트랜잭션 확인됨 (Block: ${receipt.blockNumber})');

      // 이벤트에서 암호화 키 추출
      final encryptionKey = await _extractEncryptionKeyFromReceipt(
        receipt,
        contract,
      );

      if (encryptionKey == null || encryptionKey.isEmpty) {
        throw Exception('암호화 키를 추출할 수 없습니다');
      }

      print('🔑 암호화 키 수신 완료: ${encryptionKey.substring(0, 8)}...');

      return (encryptionKey, result);
    } catch (e) {
      print('❌ requestEncryptionKey 실패: $e');
      rethrow;
    }
  }

  /// 트랜잭션 확인 대기
  Future<TransactionReceipt?> _waitForTransaction(
    String txHash, {
    int maxAttempts = 60,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final receipt = await _client.getTransactionReceipt(txHash);
        if (receipt != null) {
          return receipt;
        }
      } catch (e) {
        // 계속 시도
      }

      await Future.delayed(delay);
      print('   확인 중... ($i/$maxAttempts)');
    }

    return null;
  }

  /// 이벤트에서 암호화 키 추출
  Future<String?> _extractEncryptionKeyFromReceipt(
    TransactionReceipt receipt,
    DeployedContract contract,
  ) async {
    try {
      // EncryptionKeyGenerated 이벤트 찾기
      final event = contract.event('EncryptionKeyGenerated');

      for (final log in receipt.logs) {
        if (log.topics == null || log.topics!.isEmpty) continue;

        // 이벤트 시그니처 확인
        final eventSignature = log.topics![0];

        // 이벤트 디코딩
        try {
          final decoded = event.decodeResults(
            log.topics!,
            log.data!,
          );

          // key는 세 번째 파라미터 (index, sender, key)
          if (decoded.length >= 3) {
            final key = decoded[2] as String;
            return key;
          }
        } catch (e) {
          // 이 로그는 다른 이벤트일 수 있음
          continue;
        }
      }

      print('⚠️  이벤트에서 키를 찾을 수 없습니다. 대안 방법 시도...');

      // 대안: call()로 직접 조회 (이미 저장된 키 조회)
      // 하지만 이 경우 추가 구현 필요

      return null;
    } catch (e) {
      print('❌ 키 추출 실패: $e');
      return null;
    }
  }

  /// 암호화 키 조회 (View 함수 - 가스비 없음)
  ///
  /// 서버가 이미 생성한 암호화 키를 블록체인에서 조회합니다.
  /// View 함수이므로 트랜잭션 서명이나 가스비가 필요 없습니다.
  ///
  /// [contractAddress]: 게임별 스마트 컨트랙트 주소
  /// [userIndex]: 사용자 고유 인덱스 (예: "wallet-timestamp")
  /// [credentials]: 사용자 지갑 (조회 권한 확인용 - msg.sender 검증)
  ///
  /// Returns: 암호화 키 (16진수 문자열)
  Future<String> getEncryptionKey({
    required String contractAddress,
    required String userIndex,
    required Credentials credentials,
  }) async {
    final senderAddress = credentials.address;

    print('      🔍 온체인 조회 파라미터:');
    print('         • RPC: $_currentRpcUrl');
    print('         • 컨트랙트: $contractAddress');
    print('         • userIndex: $userIndex');
    print('         • sender (msg.sender): ${senderAddress.hex}');

    try {
      // 컨트랙트 ABI 정의 (getEncryptionKey view 함수)
      final contract = DeployedContract(
        ContractAbi.fromJson(
          '''
          [
            {
              "inputs": [
                {
                  "internalType": "string",
                  "name": "_index",
                  "type": "string"
                }
              ],
              "name": "getEncryptionKey",
              "outputs": [
                {
                  "internalType": "string",
                  "name": "",
                  "type": "string"
                }
              ],
              "stateMutability": "view",
              "type": "function"
            }
          ]
          ''',
          'BlockpickContract',
        ),
        EthereumAddress.fromHex(contractAddress),
      );

      // View 함수 호출 (가스비 없음, msg.sender로 권한 검증)
      final function = contract.function('getEncryptionKey');

      print('         📡 RPC call 시작...');
      final result = await _client.call(
        sender: senderAddress,
        contract: contract,
        function: function,
        params: [userIndex],
      );
      print('         📥 RPC 응답: $result');

      if (result.isEmpty) {
        print('         ❌ 결과가 비어있음');
        throw Exception('암호화 키를 찾을 수 없습니다 (빈 응답)');
      }

      final encryptionKey = result[0] as String;
      print('         🔑 조회된 키: "$encryptionKey" (길이: ${encryptionKey.length})');

      if (encryptionKey.isEmpty) {
        print('         ❌ 키가 빈 문자열');
        throw Exception('암호화 키가 비어있습니다');
      }

      print('         ✅ 키 조회 성공!');
      return encryptionKey;
    } catch (e) {
      print('         ❌ 온체인 조회 에러: $e');
      rethrow;
    }
  }

  /// 연결 종료
  void dispose() {
    _client.dispose();
  }
}
