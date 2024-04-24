import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/base.dart';

class ItemDeleteApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;
  String itemId;

  ItemDeleteApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
    required this.itemId,
  }) : super(
    contentType: ContentType.applicationJson
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      
      response_ = await httpClient.delete(
        Uri.parse("$apiUrl/v1/safe/$safeId/item/$itemId"),
        headers: headers,
      );

      return;
    } catch (e) {
      AppLogger.logger.w(e);
      return;
    }
  }
}