import 'package:flutter/material.dart';
import '../../data/datasources/tracking_api_service.dart';
import '../../data/models/tracking_model.dart';

class CekResiProvider extends ChangeNotifier {
  final TrackingApiService _apiService = TrackingApiService();

  String _awb = '';
  CourierModel _selectedCourier = CourierModel(code: 'jnt', name: 'J&T Express');
  bool _isLoading = false;
  String? _errorMessage;
  TrackingModel? _trackingResult;

  // Getters
  String get awb => _awb;
  CourierModel get selectedCourier => _selectedCourier;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TrackingModel? get trackingResult => _trackingResult;

  // Daftar Kurir Tersedia
  final List<CourierModel> availableCouriers = [
    CourierModel(code: 'jnt', name: 'J&T Express'),
    CourierModel(code: 'jne', name: 'JNE Express'),
    CourierModel(code: 'sicepat', name: 'SiCepat Ekspres'),
    CourierModel(code: 'anteraja', name: 'AnterAja'),
  ];

  void setAwb(String value) {
    _awb = value;
    notifyListeners();
  }

  void setCourier(CourierModel courier) {
    _selectedCourier = courier;
    notifyListeners();
  }

  Future<void> trackReceipt() async {
    if (_awb.isEmpty) {
      _errorMessage = 'Nomor resi tidak boleh kosong!';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _trackingResult = null;
    notifyListeners();

    try {
      _trackingResult = await _apiService.trackReceipt(_awb, _selectedCourier.code);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}