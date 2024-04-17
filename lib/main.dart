import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/router.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux){
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: Size(650, 700),
      minimumSize: Size(390, 660),
      maximumSize: Size(650, 700),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    RestartWidget(child: const App())
  );
}