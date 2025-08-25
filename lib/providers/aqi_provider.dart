import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/aqi_service.dart';
import '../utils/constants.dart';

class AQIProvider extends ChangeNotifier {
  final AqiService _aqiService = AqiService();

  int? currentAQI;
  String selectedProvince = 'Bangkok';
  List<Marker> aqiMarkers = [];

  Map<String, int?> provinceAQIs = {};

  Timer? _autoRefreshTimer;

  // เพิ่มเมธอด updateAQI
  void updateAQI(String province, int aqi) {
    provinceAQIs[province] = aqi;
    notifyListeners(); // แจ้งเตือน UI เมื่อค่า AQI เปลี่ยนแปลง
  }

  Future<void> fetchAllProvincesAQI() async {
    provinceAQIs.clear();
    List<Marker> markers = [];
    for (final entry in provinceCoordinates.entries) {
      final province = entry.key;
      final coord = entry.value;
      try {
        final aqi =
            await _aqiService.fetchCurrentAQI(coord.latitude, coord.longitude);
        provinceAQIs[province] = aqi;
        markers.add(
          Marker(
            point: coord,
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                selectedProvince = province;
                notifyListeners();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: getAQIColor(aqi ?? 0),
                    size: 40,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      aqi != null ? '$aqi' : '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        provinceAQIs[province] = null;
      }
    }
    aqiMarkers = markers;
    notifyListeners();
  }

  Future<void> fetchAQIByProvince(String province) async {
    selectedProvince = province;

    LatLng? coord = provinceCoordinates[province];
    if (coord == null) return;

    try {
      final aqi =
          await _aqiService.fetchCurrentAQI(coord.latitude, coord.longitude);
      currentAQI = aqi;

      // เพิ่มหรืออัปเดตหมุดของจังหวัดที่ถูกเลือกใน aqiMarkers
      final existingMarkerIndex = aqiMarkers.indexWhere(
        (marker) => marker.point == coord,
      );

      if (existingMarkerIndex != -1) {
        // อัปเดตหมุดที่มีอยู่แล้ว
        aqiMarkers[existingMarkerIndex] = Marker(
          point: coord,
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () {
              selectedProvince = province;
              notifyListeners();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: getAQIColor(aqi ?? 0),
                  size: 40,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    aqi != null ? '$aqi' : '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // เพิ่มหมุดใหม่
        aqiMarkers.add(
          Marker(
            point: coord,
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                selectedProvince = province;
                notifyListeners();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: getAQIColor(aqi ?? 0),
                    size: 40,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      aqi != null ? '$aqi' : '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching AQI: $e');
    }
  }

  void startAutoRefresh({Duration interval = const Duration(minutes: 5)}) {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(interval, (_) async {
      await fetchAllProvincesAQI();
    });
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
