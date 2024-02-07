import 'dart:async';
import 'package:mindfulguard/net/api/base.dart';
import 'package:http/http.dart' as http;

class FilesDownloadApi extends BaseApi<http.Response> {
  String apiUrl;
  String token;
  String pathToFile;

  FilesDownloadApi(
    this.apiUrl,
    this.token,
    this.pathToFile,
  ) : super(ContentType.xWwwFormUrlencoded);

  @override
  Future<http.Response?> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      var response = await http.get(
        Uri.parse("$apiUrl/v1/$pathToFile"),
        headers: headers,
      );
      return response;
    } catch (e) {
      print(e);
      return null;
    }
  }
}