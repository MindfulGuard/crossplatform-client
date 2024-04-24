import 'package:http/http.dart' as http;
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class ConfigurationApi extends BaseApi {
  String apiUrl;

  ConfigurationApi({
    required this.apiUrl,
  }) : super(
    buildContext: null,
    contentType: ContentType.xWwwFormUrlencoded,
  );

  @override
  http.Response get response{
    return response_;
  }

  @override
  Future<void> execute() async {
    try {
      await init();
      response_ = await httpClient.get(
        Uri.parse("$apiUrl/v1/public/configuration"),
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}