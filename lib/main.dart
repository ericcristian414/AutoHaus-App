import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:auto_haus/l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'dart:async';
import 'dart:io';

import 'flutter/theme.dart';
import 'flutter/util.dart';
import 'flutter/internationalization.dart';
import 'flutter/nav/nav.dart';
import 'index.dart';
import 'mqtt/mqtt_service.dart';
import 'Dispositivos/dispositivos_provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'mqtt/mqtt_background_service.dart';

late final MQTTService mqttService;


Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeService();

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await FlutterTheme.initialize();

  final appState = FlutterAppState();
  await appState.initializePersistedState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appState),
        ChangeNotifierProvider(create: (context) => DispositivosProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterTheme.themeMode;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    
    if (Platform.isAndroid) {
        Timer(const Duration(seconds: 2), () {
            FlutterBackgroundService().invoke('setAsForeground');
        });
    }
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'AutoHaus',
      locale: _locale ?? const Locale('pt'),
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}