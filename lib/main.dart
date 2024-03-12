import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/router.dart';

void main() async {
  MediaKit.ensureInitialized();
  runApp(
    RestartWidget(child: const App())
  );
}