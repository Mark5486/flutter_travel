enum RideStatus { pending, accepted, arrived, onTrip, completed, cancelled }

extension RideStatusX on RideStatus {
  String get value {
    switch (this) {
      case RideStatus.pending:
        return 'pending';
      case RideStatus.accepted:
        return 'accepted';
      case RideStatus.arrived:
        return 'arrived';
      case RideStatus.onTrip:
        return 'onTrip';
      case RideStatus.completed:
        return 'completed';
      case RideStatus.cancelled:
        return 'cancelled';
    }
  }

  static RideStatus fromValue(String? value) {
    switch (value) {
      case 'pending':
        return RideStatus.pending;
      case 'accepted':
        return RideStatus.accepted;
      case 'arrived':
        return RideStatus.arrived;
      case 'onTrip':
        return RideStatus.onTrip;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.pending;
    }
  }
}
