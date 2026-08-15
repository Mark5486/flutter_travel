enum RideStatus {
  pending('pending'),
  accepted('accepted'),
  arrived('arrived'),
  onTrip('onTrip'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const RideStatus(this.value);

  static RideStatus fromValue(String? value) {
    return RideStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => RideStatus.pending,
    );
  }

  bool get isPending => this == RideStatus.pending;
  bool get isAccepted => this == RideStatus.accepted;
  bool get isArrived => this == RideStatus.arrived;
  bool get isOnTrip => this == RideStatus.onTrip;
  bool get isCompleted => this == RideStatus.completed;
  bool get isCancelled => this == RideStatus.cancelled;

  bool get isActive =>
      this == RideStatus.accepted ||
      this == RideStatus.arrived ||
      this == RideStatus.onTrip;
}
