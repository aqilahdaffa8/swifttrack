import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

class LatLngInterpolator {
  static LatLng interpolate(LatLng from, LatLng to, double fraction) {
    final double lat = (to.latitude - from.latitude) * fraction + from.latitude;
    final double lng = (to.longitude - from.longitude) * fraction + from.longitude;
    return LatLng(lat, lng);
  }

  static double calculateBearing(LatLng startPoint, LatLng endPoint) {
    final double startLat = toRadians(startPoint.latitude);
    final double startLat2 = toRadians(startPoint.longitude);
    final double endLat = toRadians(endPoint.latitude);
    final double endLng = toRadians(endPoint.longitude);

    final double dLng = endLng - startLat2;

    final double y = math.sin(dLng) * math.cos(endLat);
    final double x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    final double bearing = math.atan2(y, x);
    return (toDegrees(bearing) + 360) % 360;
  }

  static double toRadians(double degree) {
    return degree * math.pi / 180;
  }

  static double toDegrees(double radian) {
    return radian * 180 / math.pi;
  }
}