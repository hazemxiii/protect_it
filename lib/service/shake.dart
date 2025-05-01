import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Shake {
  static StreamSubscription? stream;
  static Map<String, VoidCallback> onShakeListeners = {};
  final int threshold = 20;

  void start() {
    if (stream != null || kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    stream = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        if (event.x > threshold || event.y > threshold || event.z > threshold) {
          for (var listener in onShakeListeners.values) {
            listener();
          }
          onShakeListeners.clear();
        }
      },
      onError: (error) {
        debugPrint("Error detecting shake: ${error.toString()}");
      },
      cancelOnError: true,
    );
  }

  void stop() {
    stream?.cancel();
  }
}
