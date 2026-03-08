import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/env.dart';
import 'core/config/theme.dart';
import 'views/main_scaffold.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await Env.init();
    } catch (e, stack) {
      debugPrint('Warning: Failed to load .env file: $e');
      debugPrintStack(stackTrace: stack);
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint("FlutterError: ${details.exception}");
      debugPrintStack(stackTrace: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint("Platform error: $error");
      debugPrintStack(stackTrace: stack);
      return true;
    };

    runApp(const GitOrbitApp());
  }, (error, stack) {
    debugPrint("Zoned error: $error");
    debugPrintStack(stackTrace: stack);
  });
}

class GitOrbitApp extends StatelessWidget {
  const GitOrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<int>.value(value: 1),
      ],
      child: MaterialApp(
        title: 'GitOrbit',
        theme: TokyoDarkTheme.theme,
        home: const MainScaffold(),
      ),
    );
  }
}