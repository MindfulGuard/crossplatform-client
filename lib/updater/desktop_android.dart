import 'dart:io';

import 'package:mindfulguard/updater/base.dart';
import 'package:open_file/open_file.dart';

class UpdaterDesktopAndroid extends BaseUpdater {
  UpdaterDesktopAndroid() : super();


  @override
  Future<void> update() async {
    await init();

    const String fileName = 'MindfulGuard_android.apk';
    String filePath = "/storage/emulated/0/Download/$fileName";

    var fileBytes = await downloadRelease();
    await File(filePath).writeAsBytes(fileBytes);
    await OpenFile.open(filePath);
  }
}