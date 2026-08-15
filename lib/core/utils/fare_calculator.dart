class FareCalculator {
  static const double baseFare = 15;
  static const double perKmRate = 4.5;
  static const double minimumFare = 20;

  static double estimate(double distanceKm) {
    final fare = baseFare + (distanceKm * perKmRate);
    return fare < minimumFare
        ? minimumFare
        : double.parse(fare.toStringAsFixed(0));
  }
}
