import 'dart:ui';

import 'package:desktop_screen_log_capture/ffi/init.dart';
import 'package:desktop_screen_log_capture/view.dart';
import 'package:flutter/material.dart';

void main() async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await initDynamicLib();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Screenshot Capture',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScreenshotCapture(),
    );
  }
}
