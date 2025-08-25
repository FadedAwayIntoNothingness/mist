import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';

class AqiService {
  static const String _token = '7b2ed38ad4ad1782e0305c54968283fb202085ee';

  Future<int?> fetchCurrentAQI(double lat, double lon) async {
    try {
      final url =
          Uri.parse('https://api.waqi.info/feed/geo:$lat;$lon/?token=$_token');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok' && data['data']?['aqi'] != null) {
          return data['data']['aqi'] as int;
        } else {
          print('API error: ${data['data']}');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Exception: $e');
      print('Stack trace: $stackTrace');
    }
    return null;
  }
}

class AqiNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer? _timer;

  AqiNotifier(this.flutterLocalNotificationsPlugin);

  Future<void> showStickyAQINotification(int aqi, String locationName) async {
    String advice = _getAdvice(aqi);
    String time = DateFormat('hh:mm a').format(DateTime.now());

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'aqi_channel_id',
      'AQI Notifications',
      channelDescription: 'Persistent AQI notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      styleInformation: BigTextStyleInformation(
        'AQI $aqi • $advice\n📍 $locationName',
      ),
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '🌫️ Air Quality at $time',
      'AQI $aqi • $advice', // ใช้ข้อความย่อใน collapsed view
      platformDetails,
    );
  }

  Future<void> checkAndNotify(double latitude, double longitude) async {
    try {
      final aqi = await AqiService().fetchCurrentAQI(latitude, longitude);

      String locationName = 'Unknown Location';
      try {
        final placemarks =
            await geo.placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          locationName =
              '${place.locality ?? place.subAdministrativeArea ?? 'Unknown'}, ${place.administrativeArea ?? ''}';
        }
      } catch (e) {
        print('❌ Reverse geocoding failed: $e');
      }

      if (aqi != null) {
        // Debug: แสดงข้อมูล AQI ใน Console
        print('🔔 Notification triggered: AQI $aqi at ($latitude, $longitude)');
        print('✅ Current AQI: $aqi at $locationName');

        // สร้าง Notification แบบ Sticky
        await showStickyAQINotification(aqi, locationName);

        // สร้าง Notification แบบทั่วไป
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'aqi_channel', // Channel ID
          'AQI Notifications', // Channel Name
          importance: Importance.high,
          priority: Priority.high,
        );

        const NotificationDetails notificationDetails =
            NotificationDetails(android: androidDetails);

        await flutterLocalNotificationsPlugin.show(
          1, // Notification ID
          'Air Quality Index Update', // Title
          'AQI: $aqi', // Body
          notificationDetails,
        );
      } else {
        print('❌ Failed to fetch AQI for notification');
      }
    } catch (e) {
      print('❌ Error in checkAndNotify: $e');
    }
  }

  void startPeriodicCheck({
    required double lat,
    required double lon,
    Duration interval = const Duration(minutes: 5),
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await checkAndNotify(lat, lon);
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  String _getAdvice(int aqi) {
    if (aqi <= 50) return "Great air today! 🟢 Enjoy the outdoors.";
    if (aqi <= 100) return "Moderate air. 🟡 Sensitive people be cautious.";
    if (aqi <= 150) return "Unhealthy for sensitive groups. 🟠 Limit outdoor time.";
    if (aqi <= 200) return "Unhealthy. 🔴 Consider staying inside.";
    if (aqi <= 300) return "Very Unhealthy. 🟣 Avoid going outside.";
    return "Hazardous! 🛑 Stay indoors and keep windows closed.";
  }
}
