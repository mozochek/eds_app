import 'dart:async';
import 'dart:developer' as dev;

import 'package:eds_app/modules/app.dart';
import 'package:flutter/foundation.dart';

// TODO: вынести некоторые виджеты
void main() {
  runZonedGuarded(
    () async {
      await App.initializeAndRun();
    },
    (error, stack) {
      if (kDebugMode) {
        dev.log('Unhandled exception in runZonedGuarded', error: error, stackTrace: stack);
      }
    },
  );
}
