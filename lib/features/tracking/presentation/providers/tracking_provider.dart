import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../../../core/utils/map_utils.dart';
import '../../../../core/utils/latlng_interpolator.dart';
import '../../../../core/theme/app_theme.dart';

class TrackingProvider extends ChangeNotifier {
  GoogleMapController? _mapController;
  
  // State Peta
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _currentCourierPosition;
  bool _isLoading = true;

  // Getters
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isLoading => _isLoading;
  LatLng? get currentCourierPosition => _currentCourierPosition;

  // Timers untuk Animasi & Mock GPS
  Timer? _gpsTimer;
  Timer? _animationTimer;
  int _currentRouteIndex = 0;

  // Dummy Rute (Area Bandung/Katapang)
  final List<LatLng> _mockRoute = const [
    LatLng(-7.001600, 107.545800),
    LatLng(-6.995000, 107.550000),
    LatLng(-6.990000, 107.555000),
    LatLng(-6.985000, 107.560000),
    LatLng(-6.975000, 107.570000),
  ];

  // Inisialisasi Peta
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isLoading = false;
    notifyListeners();

    _drawRoute();
    _startMockGpsStream();
  }

  // Menggambar garis rute
  void _drawRoute() {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route_1'),
        points: _mockRoute,
        color: AppTheme.primaryColor,
        width: 5,
        geodesic: true,
      ),
    );

    // Zoom agar semua rute terlihat
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_mapController != null) {
        LatLngBounds bounds = MapUtils.boundsFromLatLngList(_mockRoute);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    });

    notifyListeners();
  }

  // Menyimulasikan data GPS masuk setiap 3 detik
  void _startMockGpsStream() {
    _currentCourierPosition = _mockRoute.first;
    _updateCourierMarker(_currentCourierPosition!, 0.0);

    _gpsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentRouteIndex < _mockRoute.length - 1) {
        LatLng startPoint = _mockRoute[_currentRouteIndex];
        LatLng endPoint = _mockRoute[_currentRouteIndex + 1];
        
        _animateMarkerMovement(startPoint, endPoint);
        _currentRouteIndex++;
      } else {
        timer.cancel(); // Rute selesai
      }
    });
  }

  // Menggerakkan marker dengan sangat halus (60fps Interpolation)
  void _animateMarkerMovement(LatLng start, LatLng end) {
    _animationTimer?.cancel();
    int frameCount = 0;
    const int totalFrames = 60; // 1 detik dibagi 60 frame (16ms per frame)

    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      frameCount++;
      double fraction = frameCount / totalFrames;

      // Hitung posisi dan rotasi baru
      LatLng interpolatedPoint = LatLngInterpolator.interpolate(start, end, fraction);
      double bearing = LatLngInterpolator.calculateBearing(start, end);

      _updateCourierMarker(interpolatedPoint, bearing);
      
      // Mengikuti kamera jika diperlukan
      _mapController?.animateCamera(CameraUpdate.newLatLng(interpolatedPoint));

      if (frameCount >= totalFrames) {
        timer.cancel();
      }
    });
  }

  // Memperbarui Marker di Peta
  void _updateCourierMarker(LatLng position, double bearing) {
    _currentCourierPosition = position;
    _markers = {
      Marker(
        markerId: const MarkerId('courier_marker'),
        position: position,
        rotation: bearing,
        anchor: const Offset(0.5, 0.5),
        icon: MapUtils.getMarkerIcon(AppTheme.accentOrange),
        infoWindow: const InfoWindow(title: 'Kurir Sedang Jalan'),
      )
    };
    notifyListeners();
  }

  // Membersihkan memori
  @override
  void dispose() {
    _gpsTimer?.cancel();
    _animationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}