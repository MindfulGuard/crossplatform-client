import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatBytes(int bytes, BuildContext context) {
  List<String> units = List<String>.from(AppLocalizations.of(context)!.dataSizes.split(', '));
  if (bytes <= 0) return '0 ${units[0].replaceFirst('[', '')}';
  int i = 0;
  double val = bytes.toDouble();
  while (val >= 1024 && i < units.length - 1) {
    val /= 1024;
    i++;
  }
  return '${val.toStringAsFixed(2)} ${units[i]}';
}
