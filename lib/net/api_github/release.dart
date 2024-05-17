import 'package:http/http.dart' as http;
import 'package:mindfulguard/logger/logs.dart';

class GithubReleaseApi{
  final String _apiUrlLastRelease = "https://api.github.com/repos/MindfulGuard/crossplatform-client/releases/latest";

  Future<http.Response> getLast() async {
    try {
      var response = await http.get(
        Uri.parse(_apiUrlLastRelease),
      );
      return response;
    } catch (e) {
      AppLogger.logger.w(e);
      return http.Response("", 500);
    }
  }

  Future<http.Response> downloadRelease(String uploadUrl) async {
    try {
      var response = await http.get(
        Uri.parse(uploadUrl),
      );
      return response;
    } catch (e) {
      AppLogger.logger.w(e);
      return http.Response("", 500);
    }
  }
}