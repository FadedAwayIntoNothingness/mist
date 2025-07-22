import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import 'providers/aqi_provider.dart';
import 'screens/initialize_screen.dart';
import 'services/aqi_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _requestPermissions();
  print('✅ Permissions requested');

  await _initNotifications();
  print('✅ Notifications initialized');

  await _showNotification('MIST', 'Welcome to MIST AQI!');
  print('✅ Welcome notification shown');

  final aqiNotifier = AqiNotifier(flutterLocalNotificationsPlugin);
  await aqiNotifier.checkAndNotify();
  aqiNotifier.startPeriodicCheck();
  print('✅ AQI check started');

  runApp(MISTApp(
    aqiNotifier: aqiNotifier,
  ));
}

Future<void> _requestPermissions() async {
  if (!kIsWeb) {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('❌ Location permission denied');
    } else {
      print('✅ Location permission granted');
    }
  } else {
    print('🌐 Web: location permission handled by browser');
  }

  if (Platform.isIOS) {
    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    print('📱 iOS notification permission requested');
  } else {
    print('ℹ️ Notification permission on Android/Web handled by OS/browser');
  }
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'aqi_channel',
    'AQI Updates',
    channelDescription: 'Shows AQI updates',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    1,
    title,
    body,
    platformChannelSpecifics,
  );
}

class MISTApp extends StatefulWidget {
  final AqiNotifier? aqiNotifier;

  const MISTApp({Key? key, this.aqiNotifier}) : super(key: key);

  @override
  State<MISTApp> createState() => _MISTAppState();
}

class _MISTAppState extends State<MISTApp> {
  @override
  void dispose() {
    widget.aqiNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AQIProvider>(
      create: (_) => AQIProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MIST AQI',
        theme: ThemeData.dark(),
        home: const InitializeScreen(),
      ),
    );
  }
}
