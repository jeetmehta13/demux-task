import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

bool isIOS() {
  
  return foundation.defaultTargetPlatform == TargetPlatform.iOS;

  // return global.isIOS;
  // return true;
  //return foundation.defaultTargetPlatform == TargetPlatform.iOS;
}