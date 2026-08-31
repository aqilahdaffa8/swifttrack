class TrackingModel {
  final String awb; // Nomor Resi (Airway Bill)
  final String courier;
  final String service;
  final String status;
  final String receiver;
  final String origin;
  final String destination;
  final List<TrackingHistory> history;

  TrackingModel({
    required this.awb,
    required this.courier,
    required this.service,
    required this.status,
    required this.receiver,
    required this.origin,
    required this.destination,
    required this.history,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    var historyList = json['history'] as List? ?? [];
    List<TrackingHistory> parsedHistory = 
        historyList.map((i) => TrackingHistory.fromJson(i)).toList();

    return TrackingModel(
      awb: json['summary']['awb'] ?? '-',
      courier: json['summary']['courier'] ?? '-',
      service: json['summary']['service'] ?? '-',
      status: json['summary']['status'] ?? 'UNKNOWN',
      receiver: json['summary']['receiver'] ?? '-',
      origin: json['summary']['origin'] ?? '-',
      destination: json['summary']['destination'] ?? '-',
      history: parsedHistory,
    );
  }
}

class TrackingHistory {
  final String date;
  final String desc;
  final String location;

  TrackingHistory({
    required this.date,
    required this.desc,
    required this.location,
  });

  factory TrackingHistory.fromJson(Map<String, dynamic> json) {
    return TrackingHistory(
      date: json['date'] ?? '-',
      desc: json['desc'] ?? '-',
      location: json['location'] ?? '',
    );
  }
}

// Model sederhana untuk pilihan Kurir di UI nanti
class CourierModel {
  final String code;
  final String name;

  CourierModel({required this.code, required this.name});
}