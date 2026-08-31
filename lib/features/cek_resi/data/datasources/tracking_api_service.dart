import 'package:dio/dio.dart';
import '../models/tracking_model.dart';

class TrackingApiService {
  final Dio _dio = Dio();
  
  // Endpoint API asli (Misal: BinderByte / RajaOngkir)
  // Biarkan kosong untuk menggunakan mode Mock Data Portofolio
  final String _apiKey = ''; 
  final String _baseUrl = 'https://api.binderbyte.com/v1/track';

  Future<TrackingModel> trackReceipt(String awb, String courierCode) async {
    try {
      // Jika API Key tersedia, lakukan HTTP GET Request betulan
      if (_apiKey.isNotEmpty) {
        final response = await _dio.get(
          _baseUrl,
          queryParameters: {
            'api_key': _apiKey,
            'courier': courierCode,
            'awb': awb,
          },
        );

        if (response.statusCode == 200) {
          return TrackingModel.fromJson(response.data['data']);
        } else {
          throw Exception('Gagal melacak resi. Server merespons dengan error.');
        }
      } 
      // Jika API Key kosong (Mode Portofolio), kembalikan Mock Data realistis
      else {
        return _getMockResponse(awb, courierCode);
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: ${e.toString()}');
    }
  }

  /// Data simulasi realistis untuk keperluan Portofolio / Testing UI
  Future<TrackingModel> _getMockResponse(String awb, String courier) async {
    // Simulasi delay jaringan (latency) selama 1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));

    final Map<String, dynamic> mockJson = {
      "data": {
        "summary": {
          "awb": awb,
          "courier": courier.toUpperCase(),
          "service": "REGULAR",
          "status": "DELIVERED",
          "date": "2026-08-30 14:20:00",
          "receiver": "Bapak Anton",
          "origin": "JAKARTA",
          "destination": "BANDUNG"
        },
        "history": [
          {
            "date": "2026-08-30 14:20:00",
            "desc": "Paket telah diterima oleh [Bapak Anton] - (YBS)",
            "location": "BANDUNG"
          },
          {
            "date": "2026-08-30 08:15:00",
            "desc": "Paket dibawa oleh kurir menuju alamat tujuan",
            "location": "BANDUNG"
          },
          {
            "date": "2026-08-29 22:10:00",
            "desc": "Paket telah tiba di fasilitas sortir Katapang",
            "location": "BANDUNG"
          },
          {
            "date": "2026-08-29 15:30:00",
            "desc": "Paket diberangkatkan dari fasilitas sortir",
            "location": "JAKARTA"
          },
          {
            "date": "2026-08-29 10:00:00",
            "desc": "Paket telah diserahkan oleh pengirim ke gerai",
            "location": "JAKARTA"
          }
        ]
      }
    };

    return TrackingModel.fromJson(mockJson['data']);
  }
}