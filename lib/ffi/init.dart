import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';
// import 'package:ffi/ffi.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path_packae;
import 'package:path_provider/path_provider.dart';

import 'ffi.dart';
// import 'ffi.dart';

DynamicLibrary? dynamicLib;

Future<void> initDynamicLib() async {
  final file = await getReleaseLibPath();
  if (dynamicLib != null) return;
  debugPrint('paht --> ${file.path}');
  final e = await file.exists();
  log('Is Path Exist : $e');
  try {
    // dynamicLib = DynamicLibrary.open('D:\\Projects\\screen_s\\target\\release\\screen_s.dll');
    dynamicLib = DynamicLibrary.open(file.path);
    initSSLib();
  } catch (e) {
    debugPrint('puck you self $e');
  }
  debugPrint('ffi init');
}

Future<File> getReleaseLibPath() async {
  const binName = 'screen_s.dll';
  const assetPath = 'assets/binary/screen_s.dll';
  log('Path :: $assetPath');

  try {
    final directory = await getApplicationSupportDirectory();
    final newPath = path_packae.join(directory.path, binName);
    File newFile = File(newPath);
    debugPrint('1');
    final exist = await newFile.exists();
    debugPrint('1.2');

    // if (exist) await newFile.delete();
    debugPrint('2 $exist');

    if (!exist) {
      debugPrint('3');

      final data = await rootBundle.load(assetPath);
      debugPrint('3.1');
      await newFile.writeAsBytes(data.buffer.asUint8List());

      debugPrint('4 ${await newFile.exists()}');
    }
    log('********** $newFile');
    return newFile;
  } catch (e) {
    debugPrint('\nError :: asset to dir :: $e \n');
    return File('');
  }
}

void takeAShot(String? s) {
  final m = s.toString().toNativeUtf8();
  screenShot!(m);
  calloc.free(m);
}
