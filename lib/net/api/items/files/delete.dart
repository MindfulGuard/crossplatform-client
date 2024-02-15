import 'package:http/http.dart' as http;
import 'package:mindfulguard/net/api/base.dart';

class FileDeleteApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String safeId;
  String fileId;

  FileDeleteApi(
    this.apiUrl,
    this.token,
    this.safeId,
    this.fileId,
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      
      Map<String, String> body = <String, String>{};
      body['files'] = fileId;
      var response = await httpClient.delete(
        Uri.parse("$apiUrl/v1/safe/$safeId/content"),
        headers: headers,
        body: body
      );

      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}