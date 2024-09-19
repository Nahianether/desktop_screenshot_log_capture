import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image/image.dart' as img;

import 'ffi/init.dart';

class ScreenshotCapture extends StatefulWidget {
  const ScreenshotCapture({super.key});

  @override
  ScreenshotCaptureState createState() => ScreenshotCaptureState();
}

class ScreenshotCaptureState extends State<ScreenshotCapture> {
  static const platform = MethodChannel('screenshot_channel');
  Timer? logTimer;
  String windowsLogs = '';

  @override
  void initState() {
    super.initState();
    _captureScreenshotPeriodically();
    _fetchWindowsLogsPeriodically();
  }

  Future<void> _captureScreenshotPeriodically() async {
    const interval = Duration(minutes: 1);
    var i = 0;
    while (mounted) {
      await Future.delayed(interval);
      // await _captureScreenshot();
      takeAShot('D:\\Projects\\screenshot$i.png');
      takeLog('D:\\Projects\\screenshot.png');
      i++;
    }
  }

  Future<void> _captureScreenshot() async {
    try {
      final screenshotData = await platform.invokeMethod<List<int>>('captureScreenshot');
      if (screenshotData != null) {
        await _saveScreenshotToSharedPreferences(Uint8List.fromList(screenshotData));
        // await _saveScreenshot(Uint8List.fromList(screenshotData));
        debugPrint('Screenshot saved');
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to capture screenshot: ${e.message}");
    }
  }

  // Future<void> _saveScreenshot(Uint8List screenshotData) async {
  //   // final image = img.Image.fromBytes(1920, 1080, screenshotData); // Create an image from bytes
  //   final image = img.decodeImage(screenshotData); // Decode the image
  //   final pngBytes = Uint8List.fromList(img.encodePng(image!)); // Convert to PNG format

  //   // Save the PNG bytes or display it in your UI
  //   await _saveScreenshotToSharedPreferences(pngBytes);
  // }

  Future<void> _saveScreenshotToSharedPreferences(Uint8List screenshotData) async {
    final prefs = await SharedPreferences.getInstance();
    String base64Image = base64Encode(screenshotData);

    prefs.setString('screenshot', base64Image);
    debugPrint('Screenshot data saved in SharedPreferences');
  }

  Future<Uint8List?> _getScreenshotFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.clear(); // Clear the saved screenshot data
    String? base64Image = prefs.getString('screenshot');
    if (base64Image != null) {
      try {
        return base64Decode(base64Image);
      } catch (e) {
        debugPrint('Error decoding image: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _fetchWindowsLogsPeriodically() async {
    const logInterval = Duration(minutes: 1);
    logTimer = Timer.periodic(logInterval, (timer) async {
      await _getWindowsLogs();
    });
  }

  Future<void> _getWindowsLogs() async {
    try {
      final logs = await platform.invokeMethod<String>('getWindowsLogs');
      // debugPrint("Windows Logs: $logs");
      setState(() {
        windowsLogs = logs ?? '';
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to get Windows Logs: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screenshot Capture'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Screenshot capturing every 1 minutes'),
            // FutureBuilder<Uint8List?>(
            //   future: _getScreenshotFromSharedPreferences(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const CircularProgressIndicator();
            //     } else if (snapshot.hasData && snapshot.data != null) {
            //       final image = img.decodeImage(snapshot.data!);
            //       final pngBytes = Uint8List.fromList(img.encodePng(image!));
            //       return Image.memory(
            //         pngBytes,
            //         width: 400,
            //         height: 200,
            //         fit: BoxFit.cover,
            //       );
            //     } else {
            //       return const Text('No screenshot saved or invalid image data');
            //     }
            //   },
            // ),
            ElevatedButton(
              onPressed: _getWindowsLogs,
              child: const Text('Get Windows Logs'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(windowsLogs.isNotEmpty ? windowsLogs : 'No logs yet'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          takeAShot('D:\\Projects\\screenshot.png');
        },
        child: const Icon(Icons.screenshot),
      ),
    );
  }
}
