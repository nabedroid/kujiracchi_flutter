import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kujiracchi_dart/features/remain/remain_view_page.dart';
import 'package:kujiracchi_dart/features/timer/timer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kujiracchi_dart/features/config/config_page.dart';
import 'package:kujiracchi_dart/features/remain/remain_page.dart';
import 'package:kujiracchi_dart/shared_preference.dart';
import 'package:kujiracchi_dart/features/stopwatch/stopwatch_page.dart';
import 'package:kujiracchi_dart/features/top/top_page.dart';

Future<void> main() async {
  // Show a loading indicator before running the full app (optional)
  // The platform's loading screen will be used while awaiting if you omit this.
  // runApp(ProviderScope(child: const MyApp()));
  // runApp(LoadingScreen());
  // Get the instance of shared preferences
  // 非同期事前処理
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  return runApp(
    ProviderScope(
      overrides: [
        // Override the unimplemented provider with the value gotten from the plugin
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Center(child: const Text('Loading.....')));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'くじらっち',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TopPage(),
      routes: <String, WidgetBuilder> {
        '/home': (context) => TopPage(),
        '/stopwatch': (context) => StopwatchPage(),
        '/config': (context) => ConfigPage(),
        '/remain': (context) => RemainPage(),
        '/timer': (context) => TimerPage(),
        '/remain_view': (context) => RemainViewPage(),
      },
    );
  }
}