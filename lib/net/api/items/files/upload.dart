import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'package:mindfulguard/net/api/base.dart';

class FileUploadApi extends BaseApi {
  String apiUrl;
  String token;
  String safeId;
  List<int> body;
  String fileName;

  FileUploadApi({
    required super.buildContext,
    required this.apiUrl,
    required this.token,
    required this.safeId,
    required this.body,
    required this.fileName,
  }) : super(
    contentType: ContentType.multipartFormData
  );

  @override
  Future<void> execute() async {
    try {
      HttpClient client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      IOClient httpClient = IOClient(client);

      await init();
      this.setAuthTokenHeader(token);

      // Create a MultipartRequest object and add a file to it
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$apiUrl/v1/safe/$safeId/content"),
      );
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        'files',
        body,
        filename: fileName,
      ));

      var streamedResponse = await httpClient.send(request);
      response_ = await http.Response.fromStream(streamedResponse);

      return;
    } catch (e) {
      print(e);
      return;
    }
  }
}
