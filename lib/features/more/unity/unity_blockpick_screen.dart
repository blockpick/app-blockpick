import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

/// Unity BlockPick 게임 화면
/// Unity에서 빌드한 3D 블록 선택 게임을 표시
class UnityBlockpickScreen extends StatefulWidget {
  final String? gameId;
  final int? gridRows;
  final int? gridCols;
  final String? imageUrl;  // 블록 색상용 이미지 URL
  final String? title;     // 게임 제목

  const UnityBlockpickScreen({
    super.key,
    this.gameId,
    this.gridRows,
    this.gridCols,
    this.imageUrl,
    this.title,
  });

  @override
  State<UnityBlockpickScreen> createState() => _UnityBlockpickScreenState();
}

class _UnityBlockpickScreenState extends State<UnityBlockpickScreen> {
  bool _isUnityReady = false;
  bool _isLoading = true;
  String? _errorMessage;

  // 블록 선택 바텀시트 설정 (디버그용)
  bool _showBlockInfoBottomSheet = true;
  Map<String, dynamic>? _lastSelectedBlock;

  // 카메라 설정값 (디버그용)
  double _panSensitivity = 0.002;
  double _deadZone = 25.0;
  double _zoomSensitivity = 0.03;
  double _smoothTime = 0.1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Unity에서 메시지를 받았을 때 호출
  void _onMessageFromUnity(String message) {
    debugPrint('[UnityBlockpick] Message from Unity: $message');

    try {
      final data = jsonDecode(message);
      final action = data['action'] as String?;

      switch (action) {
        case 'UNITY_READY':
          _handleUnityReady();
          break;
        case 'CELL_SELECTED':
          _handleCellSelected(data['data']);
          break;
        case 'GAME_RESULT':
          _handleGameResult(data['data']);
          break;
        case 'ERROR':
          _handleError(data['data']);
          break;
        default:
          debugPrint('[UnityBlockpick] Unknown action: $action');
      }
    } catch (e) {
      debugPrint('[UnityBlockpick] Error parsing message: $e');
    }
  }

  /// Unity 준비 완료 처리
  void _handleUnityReady() {
    setState(() {
      _isUnityReady = true;
      _isLoading = false;
    });

    // 게임 초기화 데이터 전송
    _initializeGame();
  }

  /// 게임 초기화
  void _initializeGame() {
    final initData = {
      'action': 'INIT_GAME',
      'data': jsonEncode({
        'gameId': widget.gameId ?? 'test_game',
        'gridRows': widget.gridRows ?? 100,
        'gridCols': widget.gridCols ?? 100,
        'theme': 'default',
        'imageUrl': widget.imageUrl ?? '',  // 이미지 URL 전달
        'title': widget.title ?? '',
      }),
    };

    _sendToUnity(initData);
  }

  /// 셀 선택 처리
  void _handleCellSelected(dynamic data) {
    debugPrint('[UnityBlockpick] Cell selected: $data');

    // 블록 정보 저장
    if (data is Map<String, dynamic>) {
      _lastSelectedBlock = data;
    } else if (data is String) {
      try {
        _lastSelectedBlock = jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        _lastSelectedBlock = {'raw': data};
      }
    } else {
      _lastSelectedBlock = {'raw': data.toString()};
    }

    // 바텀시트 표시 (설정이 켜져 있을 때만)
    if (_showBlockInfoBottomSheet && mounted) {
      _showBlockSelectedBottomSheet();
    }
  }

  /// 블록 선택 바텀시트 표시
  void _showBlockSelectedBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 제목
            const Row(
              children: [
                Icon(Icons.touch_app, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  '블록 선택됨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 좌표 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Row', _lastSelectedBlock?['row']?.toString() ?? '-'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Col', _lastSelectedBlock?['col']?.toString() ?? '-'),
                  if (_lastSelectedBlock?['color'] != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Color', _lastSelectedBlock!['color'].toString()),
                  ],
                  if (_lastSelectedBlock?['blockId'] != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Block ID', _lastSelectedBlock!['blockId'].toString()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Unity-Flutter 통신 상태
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Unity ↔ Flutter 통신 정상',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// 카메라 설정 바텀시트 표시
  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 제목
              const Row(
                children: [
                  Icon(Icons.settings, color: Colors.amber, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '카메라 설정 (테스트용)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 팬 민감도
              _buildSliderRow(
                label: '팬 민감도',
                value: _panSensitivity,
                min: 0.0005,
                max: 0.01,
                format: (v) => v.toStringAsFixed(4),
                onChanged: (v) {
                  setModalState(() => _panSensitivity = v);
                  setState(() {});
                  _sendSettingsToUnity();
                },
              ),

              // 데드존
              _buildSliderRow(
                label: '데드존 (px)',
                value: _deadZone,
                min: 5,
                max: 60,
                format: (v) => v.toStringAsFixed(0),
                onChanged: (v) {
                  setModalState(() => _deadZone = v);
                  setState(() {});
                  _sendSettingsToUnity();
                },
              ),

              // 줌 민감도
              _buildSliderRow(
                label: '줌 민감도',
                value: _zoomSensitivity,
                min: 0.005,
                max: 0.1,
                format: (v) => v.toStringAsFixed(3),
                onChanged: (v) {
                  setModalState(() => _zoomSensitivity = v);
                  setState(() {});
                  _sendSettingsToUnity();
                },
              ),

              // 스무딩
              _buildSliderRow(
                label: '스무딩 (초)',
                value: _smoothTime,
                min: 0.01,
                max: 0.3,
                format: (v) => v.toStringAsFixed(2),
                onChanged: (v) {
                  setModalState(() => _smoothTime = v);
                  setState(() {});
                  _sendSettingsToUnity();
                },
              ),

              const SizedBox(height: 16),

              // 코드에 복사할 값
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '코드에 복사할 값:',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'panSensitivity = ${_panSensitivity.toStringAsFixed(4)}f;\n'
                      'deadZone = ${_deadZone.toStringAsFixed(0)}f;\n'
                      'zoomSensitivity = ${_zoomSensitivity.toStringAsFixed(3)}f;\n'
                      'smoothTime = ${_smoothTime.toStringAsFixed(2)}f;',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 닫기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 슬라이더 행 위젯
  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              Text(
                format(value),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.amber,
              inactiveTrackColor: Colors.grey[700],
              thumbColor: Colors.amber,
              overlayColor: Colors.amber.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Unity로 설정값 전송
  void _sendSettingsToUnity() {
    if (!_isUnityReady) return;

    final settingsData = {
      'action': 'UPDATE_SETTINGS',
      'data': jsonEncode({
        'panSensitivity': _panSensitivity,
        'deadZone': _deadZone,
        'zoomSensitivity': _zoomSensitivity,
        'smoothTime': _smoothTime,
      }),
    };

    _sendToUnity(settingsData);
  }

  /// 게임 결과 처리
  void _handleGameResult(dynamic data) {
    debugPrint('[UnityBlockpick] Game result: $data');

    final won = data['won'] as bool? ?? false;
    final resultType = data['resultType'] as String? ?? '';
    final reward = data['reward'] as int? ?? 0;

    // 결과 다이얼로그 표시
    _showResultDialog(won, resultType, reward);
  }

  /// 에러 처리
  void _handleError(dynamic data) {
    final code = data['code'] as String? ?? 'UNKNOWN';
    final message = data['message'] as String? ?? 'Unknown error';

    setState(() {
      _errorMessage = '[$code] $message';
    });

    debugPrint('[UnityBlockpick] Error: $_errorMessage');
  }

  /// Unity로 메시지 전송
  void _sendToUnity(Map<String, dynamic> data) {
    final jsonMessage = jsonEncode(data);
    debugPrint('[UnityBlockpick] Sending to Unity: $jsonMessage');

    // flutter_embed_unity API 사용
    sendToUnity(
      'FlutterBridge',     // GameObject 이름
      'ReceiveMessage',    // 메서드 이름
      jsonMessage,         // 메시지 (string)
    );
  }

  /// 결과 다이얼로그 표시
  void _showResultDialog(bool won, String resultType, int reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? '축하합니다!' : '게임 오버'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.celebration : Icons.sentiment_dissatisfied,
              size: 64,
              color: won ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              resultType == 'TREASURE'
                  ? '보물을 찾았습니다!'
                  : resultType == 'BOMB'
                      ? '폭탄을 밟았습니다!'
                      : won
                          ? '승리!'
                          : '다음 기회에...',
              style: const TextStyle(fontSize: 18),
            ),
            if (reward > 0) ...[
              const SizedBox(height: 8),
              Text(
                '+$reward 코인',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 게임 화면도 닫기
            },
            child: const Text('확인'),
          ),
          if (won)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: const Text('다시 하기'),
            ),
        ],
      ),
    );
  }

  /// 게임 재시작
  void _restartGame() {
    _sendToUnity({'action': 'RESTART_GAME', 'data': ''});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Block Pick',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // 카메라 설정 버튼 (디버그용)
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettingsBottomSheet,
            tooltip: '카메라 설정',
          ),
          // 바텀시트 on/off 토글 (디버그용)
          IconButton(
            icon: Icon(
              _showBlockInfoBottomSheet ? Icons.notifications_active : Icons.notifications_off,
              color: _showBlockInfoBottomSheet ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showBlockInfoBottomSheet = !_showBlockInfoBottomSheet;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _showBlockInfoBottomSheet
                        ? '블록 선택 알림 ON'
                        : '블록 선택 알림 OFF',
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _showBlockInfoBottomSheet ? Colors.green : Colors.grey[700],
                ),
              );
            },
            tooltip: '블록 선택 알림 토글',
          ),
          if (_isUnityReady)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _restartGame,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Unity Widget (flutter_embed_unity)
          EmbedUnity(
            onMessageFromUnity: _onMessageFromUnity,
          ),

          // 로딩 오버레이
          if (_isLoading)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      '게임 로딩 중...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // 에러 표시
          if (_errorMessage != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
