enum ActionType { markAsRead, delete }

class PendingAction {
  final String id;
  final String notificationId;
  final ActionType actionType;
  final DateTime createdAt;

  const PendingAction({
    required this.id,
    required this.notificationId,
    required this.actionType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationId': notificationId,
      'actionType': actionType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      id: json['id'] ?? '',
      notificationId: json['notificationId'] ?? '',
      actionType: ActionType.values.firstWhere(
        (e) => e.name == json['actionType'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
