import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../errors/exceptions.dart';

abstract class RoutingService {
  Future<List<LatLng>> getRoute({required LatLng start, required LatLng end});
}

class RoutingServiceImpl implements RoutingService {
  final http.Client _client;

  RoutingServiceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<LatLng>> getRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await _client.get(url);

      if (response.statusCode != 200) {
        throw const ServerException('تعذر تحديد المسار حالياً.');
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok') {
        throw const ServerException('لم نتمكن من إيجاد طريق بين النقطتين.');
      }

      final routes = data['routes'] as List?;

      if (routes == null || routes.isEmpty) {
        throw const ServerException('لا يوجد طريق متاح بين هاتين النقطتين.');
      }

      final geometry = routes.first['geometry'];
      final coordinates = geometry['coordinates'] as List;

      return coordinates.map<LatLng>((point) {
        return LatLng(
          (point[1] as num).toDouble(),
          (point[0] as num).toDouble(),
        );
      }).toList();
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const ServerException('حدث خطأ غير متوقع أثناء رسم المسار.');
    }
  }
}