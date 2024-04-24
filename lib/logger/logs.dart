import 'package:logger/logger.dart';

class AppLogger{
  static get logger => Logger(
    printer: PrettyPrinter(
      printTime: true
    ),
  );
}