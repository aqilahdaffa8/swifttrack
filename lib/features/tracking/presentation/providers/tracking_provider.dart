import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../../../core/utils/latlng_interpolator.dart';
import '../../../../core/theme/app_theme.dart';

class TrackingProvider extends ChangeNotifier {
  final MapController mapController = MapController();
  
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  LatLng? _currentCourierPosition;

  List<Marker> get markers => _markers;
  List<Polyline> get polylines => _polylines;

  Timer? _gpsTimer;
  Timer? _animationTimer;
  int _currentRouteIndex = 0;

  // Mock Data: Rute GPS Kurir area Katapang - Kopo
  final List<LatLng> _mockRoute = const [
    LatLng(-7.001600, 107.545800),
    LatLng(-6.995000, 107.550000),
    LatLng(-6.990000, 107.555000),
    LatLng(-6.985000, 107.560000),
    LatLng(-6.975000, 107.570000),
  ];

  void initializeMap() {
    _drawRoute();
    _startMockGpsStream();
  }

  void _drawRoute() {
    _polylines = [
      Polyline(
        points: _mockRoute,
        color: AppTheme.primaryColor,
        strokeWidth: 6.0,
      )
    ];
    notifyListeners();
  }

  void _startMockGpsStream() {
    _currentCourierPosition = _mockRoute.first;
    _updateCourierMarker(_currentCourierPosition!, 0.0);

    _gpsTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentRouteIndex < _mockRoute.length - 1) {
        LatLng startPoint = _mockRoute[_currentRouteIndex];
        LatLng endPoint = _mockRoute[_currentRouteIndex + 1];
        
        _animateMarkerMovement(startPoint, endPoint);
        _currentRouteIndex++;
      } else {
        timer.cancel(); // Kurir sampai di tujuan
      }
    });
  }

  void _animateMarkerMovement(LatLng start, LatLng end) {
    _animationTimer?.cancel();
    int frameCount = 0;
    const int totalFrames = 60; // 60 FPS untuk pergerakan mulus

    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      frameCount++;
      double fraction = frameCount / totalFrames;

      LatLng interpolatedPoint = LatLngInterpolator.interpolate(start, end, fraction);
      double bearing = LatLngInterpolator.calculateBearing(start, end);

      _updateCourierMarker(interpolatedPoint, bearing);
      mapController.move(interpolatedPoint, 15.0); // Kamera mengikuti marker

      if (frameCount >= totalFrames) {
        timer.cancel();
      }
    });
  }

  void _updateCourierMarker(LatLng position, double bearing) {
    _currentCourierPosition = position;
    _markers = [
      Marker(
        point: position,
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: LatLngInterpolator.toRadians(bearing),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                // DIPERBAIKI: Menggunakan withValues
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3), 
                  blurRadius: 10,
                )
              ],
            ),
            child: const Icon(
              Icons.navigation_rounded, 
              color: AppTheme.accentOrange, 
              size: 35,
            ),
          ),
        ),
      )
    ];
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    _animationTimer?.cancel();
    mapController.dispose();
    super.dispose();
  }
}