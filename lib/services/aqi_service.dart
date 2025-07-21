import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class AqiService {
  static const String _token = '7b2ed38ad4ad1782e0305c54968283fb202085ee';

  Future<int?> fetchCurrentAQI(double lat, double lon) async {
    try {
      final url = Uri.parse('https://api.waqi.info/feed/geo:$lat;$lon/?token=$_token');
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

  Future<void> showStickyAQINotification(int aqi) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'aqi_channel_id',
      'AQI Notifications',
      channelDescription: 'Persistent AQI notifications',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Current AQI',
      'AQI is $aqi',
      platformDetails,
    );
  }

  Future<void> checkAndNotify() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('❌ Location service not enabled');
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('❌ Location permission not granted');
        return;
      }
    }

    final userLocation = await location.getLocation();
    final lat = userLocation.latitude ?? 13.7563;
    final lon = userLocation.longitude ?? 100.5018;

    final aqi = await AqiService().fetchCurrentAQI(lat, lon);
    if (aqi != null) {
      print('✅ Current AQI: $aqi');
      await showStickyAQINotification(aqi);
    } else {
      print('❌ Failed to fetch AQI');
    }
  }

  void startPeriodicCheck({Duration interval = const Duration(minutes: 5)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await checkAndNotify();
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
