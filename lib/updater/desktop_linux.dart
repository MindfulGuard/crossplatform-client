import 'dart:io';

import 'package:mindfulguard/updater/base.dart';

class UpdaterDesktopLinux extends BaseUpdater {
  UpdaterDesktopLinux() : super();

  Future<void> _openScript({
    required String appFullPath,
    required String updatesFullPath,
    required String archiveFullPath
  }) async {
    String executablePath = "$appFullPath/$getUpdaterFileName.sh";
    await Process.start(executablePath, [
      "--APP_FULL_PATH=$appFullPath",
      "--UPDATES_FULL_PATH=$updatesFullPath",
      "--ARCHIVE_FILE_FULL_PATH=$archiveFullPath",
      "--FILE_IGNORE=$getUpdaterFileName.sh", // !
      "--MAIN_PROGRAM_NAME=mindfulguard",
      "--FILE_DELETE_AFTER=/mindfulguard_linux_x64",
      "--RUN_FILE_AFTER=$appFullPath/mindfulguard",
    ]);
  }


  @override
  Future<void> update() async {
    await init();

    const String archiveName = 'archive.tar.gz';
    String filePath = appCurrentDir.path;

    try{
      var fileBytes = await downloadRelease();
      if (fileBytes.isNotEmpty){
        await File("$filePath/$archiveName").writeAsBytes(fileBytes);
      } else{
        return;
      }
    } catch(e){
      return;
    }
    await _openScript(
      appFullPath: filePath,
      updatesFullPath: "$filePath/mindfulguard_linux_x64",
      archiveFullPath: "$filePath/$archiveName"
    );
  }
}