import 'dart:async';
import 'dart:developer' as dev;

import 'package:eds_app/modules/app.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(
    () {
      runApp(const App());
    },
    (error, stack) {
      dev.log('Unhandled exception in runZonedGuarded', error: error, stackTrace: stack);
    },
  );
}
