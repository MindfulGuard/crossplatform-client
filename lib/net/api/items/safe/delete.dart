import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class SafeDeleteApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;

  SafeDeleteApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await httpClient.delete(Uri.parse("$apiUrl/v1/safe/$safeId"), headers: headers);
      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }

}