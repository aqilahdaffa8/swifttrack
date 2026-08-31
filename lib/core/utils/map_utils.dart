import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapUtils {
  /// Mengambil rute jalan nyata (Polyline) menggunakan API gratis dari OSRM.
  /// Tidak perlu API Key dan tidak ada batasan tagihan!
  static Future<List<LatLng>> getRealRouteOSRM({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final dio = Dio();
      // Format URL OSRM: longitude,latitude (berbeda dengan format standar lat,lon)
      final String url = 'http://router.project-osrm.org/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}'
          '?geometries=geojson';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final List routes = data['routes'];
        
        if (routes.isNotEmpty) {
          // Mengambil array koordinat dari GeoJSON
          final List coordinates = routes[0]['geometry']['coordinates'];
          
          // Mapping dari array [longitude, latitude] ke objek LatLng(latitude, longitude)
          return coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      }
      return [];
    } catch (e) {
      // Return list kosong jika gagal (misal tidak ada koneksi)
      return [];
    }
  }

  /// Menghitung batas kotak (Bounds) agar kamera bisa Auto-Zoom
  /// dan memuat seluruh koordinat rute di dalam layar (Versi flutter_map)
  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      LatLng(x0!, y0!), // Titik Barat Daya (SouthWest)
      LatLng(x1!, y1!), // Titik Timur Laut (NorthEast)
    );
  }
}