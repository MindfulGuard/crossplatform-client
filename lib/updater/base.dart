import 'dart:convert';
import 'dart:io';

import 'package:mindfulguard/net/api_github/release.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class BaseUpdater{
  final _githubReleaseApi = GithubReleaseApi();
  late Map<String, dynamic> json; 
  late PackageInfo appInfo;
  String getUpdaterFileName = "updater";
  Directory appCurrentDir = Directory.current;

  Future<void> init() async{
    var response = await _githubReleaseApi.getLast();
    json =  jsonDecode(response.body);
    appInfo = await PackageInfo.fromPlatform();
  }

  Future<String> getLastVersionReleaseGithub() async{
    return json['tag_name']; // version of release
  }

  String getAppVersion(){
    return appInfo.version;
  }

  String _getUploadUrl() {
    String uploadUrl = "";
    String fileName_ = "";

    for (var value in json['assets']){
      if (Platform.isWindows){
        String fileName = value['name'];
        fileName = fileName.toLowerCase();

        if (fileName.contains("windows")){
          fileName_ = value['name'];
          uploadUrl = value['browser_download_url'];
        }
      } else if(Platform.isLinux){
          String fileName = value['name'];
          fileName = fileName.toLowerCase();

          if (fileName.contains("linux")){
            fileName_ = value['name'];
            uploadUrl = value['browser_download_url'];
          }
      } else if (Platform.isAndroid){
          String fileName = value['name'];
          fileName = fileName.toLowerCase();

          if (fileName.contains("android")){
            fileName_ = value['name'];
            uploadUrl = value['browser_download_url'];
          }
      } else{
        fileName_ = "";
      }
    }

    return uploadUrl;
  }

  Future<List<int>> downloadRelease() async{
    List<int> fileBytes = [];
    String uploadUrl = _getUploadUrl();
    var response = await _githubReleaseApi.downloadRelease(uploadUrl);

    if (response.statusCode == 200){
      if (Platform.isWindows || Platform.isLinux || Platform.isAndroid){
        fileBytes = response.bodyBytes;
      }
    }

    return fileBytes;
  }

  Future<void> update();
  Future<void> openScript({
    required String appFullPath,
    required String updatesFullPath,
    required String archiveFullPath
  });
}