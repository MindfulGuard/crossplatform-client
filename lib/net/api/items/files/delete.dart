import 'package:mindfulguard/net/api/base.dart';

class FileDeleteApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;
  String fileId;

  FileDeleteApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
    required this.fileId,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      
      Map<String, String> body = <String, String>{};
      body['files'] = fileId;
      response_ = await httpClient.delete(
        Uri.parse("$apiUrl/v1/safe/$safeId/content"),
        headers: headers,
        body: body
      );

      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}