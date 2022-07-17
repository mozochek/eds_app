import 'package:dio/dio.dart';
import 'package:eds_app/modules/core/data/database/database.dart';
import 'package:flutter/material.dart';

@immutable
class AppStore {
  final Dio dio;
  final IAppDatabase database;

  const AppStore({
    required this.dio,
    required this.database,
  });

  void dispose() {
    dio.close();
    database.close();
  }
}

class DependenciesScope extends StatefulWidget {
  final Widget child;

  const DependenciesScope({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<DependenciesScope> createState() => _DependenciesScopeState();

  static AppStore of(BuildContext context) {
    final inhWidget = context.findAncestorWidgetOfExactType<_DependenciesInhScope>();

    if (inhWidget is! _DependenciesInhScope) {
      throw Exception('_DependenciesInhScope was not found above \'${context.widget}\' widget.');
    }

    return inhWidget.store;
  }
}

class _DependenciesScopeState extends State<DependenciesScope> {
  late final AppStore _store;

  @override
  void initState() {
    super.initState();

    _store = AppStore(
      dio: Dio()
        ..options = BaseOptions(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          connectTimeout: 7000,
          sendTimeout: 7000,
          receiveTimeout: 7000,
        ),
      database: AppDatabase(),
    );
  }

  @override
  void dispose() {
    _store.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DependenciesInhScope(
      store: _store,
      child: widget.child,
    );
  }
}

class _DependenciesInhScope extends InheritedWidget {
  final AppStore store;

  const _DependenciesInhScope({
    required this.store,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
