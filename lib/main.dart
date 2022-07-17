import 'dart:async';
import 'dart:developer' as dev;

import 'package:eds_app/modules/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SystemChrome.setPreferredOrientations(
        <DeviceOrientation>[DeviceOrientation.portraitUp],
      );
      runApp(const App());
    },
    (error, stack) {
      if (kDebugMode) {
        dev.log('Unhandled exception in runZonedGuarded', error: error, stackTrace: stack);
      }
    },
  );
}
