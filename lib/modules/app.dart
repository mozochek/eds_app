import 'package:eds_app/modules/core/presentation/dependencies_scope.dart';
import 'package:eds_app/modules/core/presentation/l10n/app_localizations.dart';
import 'package:eds_app/modules/user/modules/all_users/presentation/all_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  static Future<void> initializeAndRun() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
    Intl.defaultLocale = AppLocalizations.supportedLocales.first.toString();

    runApp(const App());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eds Test App',
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (_, child) {
        return DependenciesScope(child: child!);
      },
      home: const AllUsersScreen(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
