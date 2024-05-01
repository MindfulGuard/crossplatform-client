import 'package:flutter/material.dart';
import 'package:mindfulguard/view/components/icons.dart';

final class AppIcons extends CustomIcons {
  /// Note that if you create a new `CustomIcons` class,
  /// you must run the `scripts/configure_icons.py` script,
  /// which modifies the file for the code to work properly.
  AppIcons() : super();

  Icon defineDeviceIconByName(String device, {double iconSize = 64}) {
    Icon responseIcon = Icon(Icons.devices, size: iconSize, color: Colors.black);

    device = device.toLowerCase();

    if (device.contains('android')) {
      responseIcon = Icon(Icons.android, size: iconSize, color: Colors.green[800]);
    } else if (device.contains('ios')) {
      responseIcon = Icon(Icons.apple, size: iconSize, color: Colors.black);
    } else if (device.contains('macos') || device.contains('mac os')) {
      responseIcon = Icon(Icons.apple, size: iconSize, color: Colors.black);
    } else if (device.contains('windows')) {
      responseIcon = Icon(windows, size: iconSize, color: Colors.blue[400]);
    } else if (device.contains('linux')) {
      responseIcon = Icon(linux, size: iconSize, color: Colors.orange[800]);
    } else if (
        device.contains('chrome') ||
        device.contains('firefox') ||
        device.contains('safari') ||
        device.contains('edge') ||
        device.contains('opera')
    ) {
      responseIcon = Icon(Icons.web, size: iconSize, color: Colors.blue[800]);
    }
    return responseIcon;
  }
}