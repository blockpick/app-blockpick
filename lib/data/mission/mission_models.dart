// Mission 도메인 DTO + enum

enum MissionType { signUp, appInstall, channelAdd, pageVisit, offlineVerify }

MissionType missionTypeFromString(String? s) {
  if (s == null) return MissionType.signUp;
  switch (s) {
    case 'SIGN_UP':
      return MissionType.signUp;
    case 'APP_INSTALL':
      return MissionType.appInstall;
    case 'CHANNEL_ADD':
      return MissionType.channelAdd;
    case 'PAGE_VISIT':
      return MissionType.pageVisit;
    case 'OFFLINE_VERIFY':
      return MissionType.offlineVerify;
    default:
      return MissionType.signUp;
  }
}

enum MissionStatus { active, inactive }

MissionStatus missionStatusFromString(String? s) {
  if (s == null) return MissionStatus.inactive;
  return MissionStatus.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => MissionStatus.inactive,
  );
}

enum MissionCompletionStatus { pending, verified, rejected }

MissionCompletionStatus? missionCompletionStatusFromStringNullable(String? s) {
  if (s == null) return null;
  return MissionCompletionStatus.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => MissionCompletionStatus.pending,
  );
}

class Mission {
  final String id;
  final MissionType missionType;
  final String title;
  final String? description;
  final int rewardTickets;
  final String? externalUrl;
  final String? blockpickId;
  final MissionStatus status;
  final MissionCompletionStatus? completionStatus;
  final String? completedAt;

  const Mission({
    required this.id,
    required this.missionType,
    required this.title,
    this.description,
    required this.rewardTickets,
    this.externalUrl,
    this.blockpickId,
    required this.status,
    this.completionStatus,
    this.completedAt,
  });

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'] as String,
        missionType: missionTypeFromString(json['missionType'] as String?),
        title: json['title'] as String,
        description: json['description'] as String?,
        rewardTickets: (json['rewardTickets'] as num?)?.toInt() ?? 0,
        externalUrl: json['externalUrl'] as String?,
        blockpickId: json['blockpickId'] as String?,
        status: missionStatusFromString(json['status'] as String?),
        completionStatus: missionCompletionStatusFromStringNullable(
            json['completionStatus'] as String?),
        completedAt: json['completedAt'] as String?,
      );
}
