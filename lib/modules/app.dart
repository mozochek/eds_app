import 'package:eds_app/modules/app_scope.dart';
import 'package:eds_app/modules/dependencies_scope.dart';
import 'package:eds_app/modules/user/modules/all_users/presentation/all_users_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        return DependenciesScope(
          child: AppScope(
            child: child!,
          ),
        );
      },
      home: const AllUsersScreen(),
    );
  }
}
