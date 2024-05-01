import 'dart:io';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/updater/base.dart';
import 'package:open_file/open_file.dart';

class UpdaterAndroid extends BaseUpdater {
  UpdaterAndroid() : super();

  @override
  Future<void> openScript({
    String appFullPath = "",
    required  String updatesFullPath,
    String archiveFullPath = ""
  }) async{
    await OpenFile.open(updatesFullPath);
  }

  @override
  Future<void> update() async {
    await init();

    const String fileName = 'MindfulGuard_android.apk';
    String filePath = "/storage/emulated/0/Download/$fileName";

    try{
      var fileBytes = await downloadRelease();
      if (fileBytes.isNotEmpty){
        await File(filePath).writeAsBytes(fileBytes);
      } else{
        return;
      }
    } catch(e){
      AppLogger.logger.e("Failed to download the file, for the update. Platform: Android. Error: $e.");
      return;
    }
    await openScript(updatesFullPath: filePath);
  }
}