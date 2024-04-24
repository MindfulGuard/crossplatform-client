import 'package:http/http.dart' as http;
import 'package:mindfulguard/logger/logs.dart';

Future<bool> pingServer(String url) async {
  try {
    var response = await http.get(Uri.parse(url));
    return response.statusCode == 200;
  }
  catch (e){
    AppLogger.logger.w(e);
    return false;
  }
}