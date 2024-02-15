import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class SafeDeleteApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String safeId;

  SafeDeleteApi(
    this.apiUrl,
    this.token,
    this.safeId,
  ) : super(ContentType.xWwwFormUrlencoded);

  Future<http.Response?> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      var response = await httpClient.delete(Uri.parse("$apiUrl/v1/safe/$safeId"), headers: headers);
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }

}