import 'dart:io';

import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/updater/base.dart';

class UpdaterDesktopWindows extends BaseUpdater {
  UpdaterDesktopWindows() : super();

  @override
  Future<void> openScript({
    required String appFullPath,
    required String updatesFullPath,
    required String archiveFullPath
  }) async {
    String executablePath = "$appFullPath/$getUpdaterFileName.exe";
    await Process.start(executablePath, [
      "--APP_FULL_PATH=$appFullPath",
      "--UPDATES_FULL_PATH=$updatesFullPath",
      "--ARCHIVE_FILE_FULL_PATH=$archiveFullPath",
      "--FILE_IGNORE=$getUpdaterFileName.exe",
      "--MAIN_PROGRAM_NAME=mindfulguard.exe",
      "--FILE_DELETE_AFTER=/mindfulguard_windows_x64",
      "--RUN_FILE_AFTER=$appFullPath/mindfulguard.exe",
    ]);
  }

  @override
  Future<void> update() async {
    await init();

    const String archiveName = 'archive.zip';
    String filePath = appCurrentDir.path;

    try{
      var fileBytes = await downloadRelease();
      if (fileBytes.isNotEmpty){
        await File("$filePath/$archiveName").writeAsBytes(fileBytes);
      } else{
        return;
      }
    } catch(e){
      AppLogger.logger.e("Failed to download the file, for the update. Platform: Windows. Error: $e.");
      return;
    }
    await openScript(
      appFullPath: filePath,
      updatesFullPath: "$filePath/mindfulguard_windows_x64",
      archiveFullPath: "$filePath/$archiveName"
    );
  }
}