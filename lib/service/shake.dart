import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Shake {
  static StreamSubscription? stream;
  static Map<String, VoidCallback> onShakeListeners = {};

  void start() {
    if (stream != null) {
      return;
    }
    stream = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        if (event.x > 10) {
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
