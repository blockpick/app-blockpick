// AdReward 도메인 DTO

class AdRewardLog {
  final String id;
  final String blockpickId;
  final String watchedAt;
  final bool ticketIssued;
  final String? ticketId;
  final String? externalNetworkRef;

  const AdRewardLog({
    required this.id,
    required this.blockpickId,
    required this.watchedAt,
    required this.ticketIssued,
    this.ticketId,
    this.externalNetworkRef,
  });

  factory AdRewardLog.fromJson(Map<String, dynamic> json) => AdRewardLog(
        id: json['id'] as String,
        blockpickId: json['blockpickId'] as String,
        watchedAt: json['watchedAt'] as String,
        ticketIssued: json['ticketIssued'] as bool? ?? false,
        ticketId: json['ticketId'] as String?,
        externalNetworkRef: json['externalNetworkRef'] as String?,
      );
}
