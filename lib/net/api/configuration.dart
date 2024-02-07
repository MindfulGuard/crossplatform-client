import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class ConfigurationApi extends BaseApi<http.Response> {
  String apiUrl;

  ConfigurationApi(
    this.apiUrl,
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      var response = await http.get(
        Uri.parse("$apiUrl/v1/public/configuration"),
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}