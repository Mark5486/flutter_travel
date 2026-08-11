import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../errors/exceptions.dart';

abstract class RoutingService {
  Future<List<LatLng>> getRoute({required LatLng start, required LatLng end});
}

class RoutingServiceImpl implements RoutingService {
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

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw const ServerException('مقدرناش نحدد الطريق دلوقتي.');
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok') {
        throw const ServerException('مقدرناش نلاقي طريق بين المكانين.');
      }

      final routes = data['routes'];

      if (routes == null || routes.isEmpty) {
        throw const ServerException('مفيش طريق متاح بين المكانين.');
      }

      final geometry = routes.first['geometry'];

      final coordinates = geometry['coordinates'] as List;

      return coordinates.map<LatLng>((point) {
        return LatLng(
          (point[1] as num).toDouble(),
          (point[0] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }

      throw ServerException('حصل خطأ أثناء تحديد الطريق: ${e.toString()}');
    }
  }
}
