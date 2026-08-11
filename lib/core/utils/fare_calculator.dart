/// حساب سعر الرحلة التقريبي بناءً على المسافة.
/// عدّل الأرقام دي براحتك حسب التسعيرة اللي حابب تشتغل بيها.
class FareCalculator {
  static const double baseFare = 15; // الأجرة الأساسية بالجنيه
  static const double perKmRate = 4.5; // سعر الكيلومتر
  static const double minimumFare = 20; // أقل سعر ممكن للرحلة

  static double estimate(double distanceKm) {
    final fare = baseFare + (distanceKm * perKmRate);
    return fare < minimumFare ? minimumFare : double.parse(
      fare.toStringAsFixed(0),
    );
  }
}
