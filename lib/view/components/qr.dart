import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGenerator extends StatelessWidget {
  String data;
  double size;
  int qrVersion;
  int errorCorrectionLevel;
  Color backgroundColor;
  QrEyeStyle eyeStyle;
  QrDataModuleStyle dataModuleStyle;
  bool gapless;

  QrGenerator({
    required this.data,
    required this.size,
    this.qrVersion = QrVersions.auto,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
    this.backgroundColor = Colors.white,
    this.eyeStyle = const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
    this.dataModuleStyle = const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
    this.gapless = true,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: qrVersion,
      errorCorrectionLevel: errorCorrectionLevel,
      backgroundColor: backgroundColor,
      size: size,
      gapless: gapless,
      eyeStyle: eyeStyle,
      dataModuleStyle: dataModuleStyle
    );
  }
}