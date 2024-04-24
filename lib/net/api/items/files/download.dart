import 'dart:async';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class FilesDownloadApi extends BaseApi {
  String apiUrl;
  String token;
  String pathToFile;

  FilesDownloadApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.pathToFile,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await httpClient.get(
        Uri.parse("$apiUrl/v1/$pathToFile"),
        headers: headers,
      );
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}