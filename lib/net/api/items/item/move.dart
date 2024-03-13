import 'package:mindfulguard/net/api/base.dart';

class ItemMoveToNewSafeApi extends BaseApi{
  String apiUrl;
  String token;
  String oldSafeId;
  String newSafeId;
  String itemId;

  ItemMoveToNewSafeApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.oldSafeId,
    required this.newSafeId,
    required this.itemId,
  }) : super(
    contentType: ContentType.xWwwFormUrlencoded
  );

  @override
  Future<void> execute() async {
    try {
      await init();
      this.setAuthTokenHeader(token);
      response_ = await httpClient.put(
        Uri.parse("$apiUrl/v1/safe/$oldSafeId/$newSafeId/item/$itemId"),
        headers: headers
      );
      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}