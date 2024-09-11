// ? ----------------------------------------------------------------
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'init.dart';

typedef LogPrintFunc = Void Function(Pointer<Utf8>);
typedef LogPrint = void Function(Pointer<Utf8>);
typedef VoidStringF = void Function(Pointer<Utf8>);

VoidStringF? screenShot;

void initSSLib() {
  screenShot = dynamicLib!.lookupFunction<LogPrintFunc, LogPrint>('take_s');
  debugPrint('ss init in flutter');
}
