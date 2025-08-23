import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';
import 'index.dart';

import 'package:provider/provider.dart';
import '/providers/aqi_provider.dart';
import '/providers/theme_notifier.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

<<<<<<< Updated upstream
  await _requestPermissions();
  if (kDebugMode) {
    print('✅ Permissions requested');
  }

  await _initNotifications();
  if (kDebugMode) {
    print('✅ Notifications initialized');
  }

  await _showNotification('MIST', 'Welcome to MIST AQI!');
  if (kDebugMode) {
    print('✅ Welcome notification shown');
  }

  Position? userPosition;
  try {
    userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (kDebugMode) {
      print('📍 Got user location: ${userPosition.latitude}, ${userPosition.longitude}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Failed to get user location: $e');
    }
  }

  final aqiNotifier = AqiNotifier(flutterLocalNotificationsPlugin);

  if (userPosition != null) {
    await aqiNotifier.checkAndNotify(userPosition.latitude, userPosition.longitude);
    aqiNotifier.startPeriodicCheck(
      lat: userPosition.latitude,
      lon: userPosition.longitude,
    );
    if (kDebugMode) {
      print('✅ AQI check started with user location');
    }
  } else {
    if (kDebugMode) {
      print('⚠️ AQI check skipped: no location available');
    }
  }
=======
  await FlutterFlowTheme.initialize();
>>>>>>> Stashed changes

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AQIProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

<<<<<<< Updated upstream
Future<void> _requestPermissions() async {
  if (!kIsWeb) {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print('❌ Location permission denied');
      }
    } else {
      if (kDebugMode) {
        print('✅ Location permission granted');
      }
    }
  } else {
    if (kDebugMode) {
      print('🌐 Web: location permission handled by browser');
    }
  }

  if (Platform.isIOS) {
    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      print('📱 iOS notification permission requested');
    }
  } else {
    if (kDebugMode) {
      print('ℹ️ Notification permission on Android/Web handled by OS/browser');
    }
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

  const MISTApp({super.key, this.aqiNotifier});
=======
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  String getRoute([dynamic routeMatch]) {
    // Accepts RouteMatchBase, RouteMatch, or null
    final lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MIST',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
