import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MapUtils {
  /// Mengambil daftar koordinat (Polyline) antara 2 titik (Origin ke Destination)
  /// Catatan: Membutuhkan API Key Google Maps yang memiliki akses ke Directions API
  static Future<List<LatLng>> getRoutePolyline({
    required LatLng origin,
    required LatLng destination,
    required String googleApiKey,
  }) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    return polylineCoordinates;
  }

  /// Menghitung batas (Bounds) agar kamera Maps bisa melakukan Auto-Zoom
  /// dan memuat seluruh garis rute di dalam layar
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
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  /// Mendapatkan custom icon bawaan Google Maps dengan warna tertentu
  /// (Sebagai fallback sebelum kita menggunakan gambar asset custom)
  static BitmapDescriptor getMarkerIcon(Color color) {
    // Hue konversi dari Color untuk Marker bawaan Maps
    double hue = HSLColor.fromColor(color).hue;
    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }
}