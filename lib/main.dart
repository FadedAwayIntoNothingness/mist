import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';
import '/providers/aqi_provider.dart';
import '/services/aqi_service.dart';
import 'index.dart';
import 'package:provider/provider.dart';
import '/providers/theme_notifier.dart';
import 'package:go_router/go_router.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await FlutterFlowTheme.initialize();

  await _requestPermissions();
  await _initNotifications();

  Position? userPosition;
  try {
    userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print(
        '📍 Got user location: ${userPosition.latitude}, ${userPosition.longitude}');
  } catch (e) {
    print('❌ Failed to get user location: $e');
  }

  final aqiProvider = AQIProvider();
  final aqiNotifier = AqiNotifier(flutterLocalNotificationsPlugin);
  final themeNotifier = ThemeNotifier();

  if (userPosition != null) {
    try {
      final aqi = await AqiService()
          .fetchCurrentAQI(userPosition.latitude, userPosition.longitude);
      if (aqi != null) {
        aqiProvider.updateAQI('Bangkok', aqi); // อัปเดต UI ผ่าน AQIProvider
        await aqiNotifier.checkAndNotify(
            userPosition.latitude, userPosition.longitude);

        print('✅ AQI check started with user location');
      } else {
        print('❌ Failed to fetch AQI');
      }
    } catch (e) {
      print('❌ Error during AQI check: $e');
    }
  } else {
    print('⚠️ AQI check skipped: no location available');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => aqiProvider),
        ChangeNotifierProvider(create: (_) => themeNotifier),
      ],
      child: MyApp(aqiNotifier: aqiNotifier),
    ),
  );
}

Future<void> _requestPermissions() async {
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

  final iosPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  final bool? granted = await iosPlugin?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  if (granted == false) {
    print('❌ Notification permission denied');
  }
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  final AqiNotifier aqiNotifier;

  const MyApp({Key? key, required this.aqiNotifier}) : super(key: key);

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;

    // สร้าง GoRouter
    _router = createRouter(_appStateNotifier);

        // เรียก checkAndNotify ครั้งเดียวใน initState
    widget.aqiNotifier.checkAndNotify(
      13.736717, // Example latitude (Bangkok)
      100.523186, // Example longitude (Bangkok)
    );
  }

    @override
    void dispose() {
      widget.aqiNotifier?.dispose();
      super.dispose();
    }

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

