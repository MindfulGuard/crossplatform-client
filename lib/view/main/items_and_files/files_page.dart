import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/items/files/delete.dart';
import 'package:mindfulguard/net/api/items/files/download.dart';
import 'package:mindfulguard/net/api/items/files/upload.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilesPage extends StatefulWidget {
  final String apiUrl;
  final String token;
  final String password;
  final String privateKey;
  final Uint8List privateKeyBytes;
  String selectedSafeId;

  FilesPage({
    required this.apiUrl,
    required this.token,
    required this.password,
    required this.privateKey,
    required this.privateKeyBytes,
    required this.selectedSafeId,
    Key? key,
  }) : super(key: key);

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  late List<dynamic> selectedSafeFiles = [];
  Map<String, dynamic> itemsApiResponse = {};
  bool isLoading = true;
  double _uploadProgress = 0.0;
  int safeSizeBytes = 0;

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  // Method to fetch items from the API
  Future<void> _getItems() async {
    var api = ItemsApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token
    );

    await api.execute();

    var decodedApiResponse = json.decode(utf8.decode(api.response.body.runes.toList()));

    setState(() {
      itemsApiResponse = decodedApiResponse;
      selectedSafeFiles = (itemsApiResponse['files'] as List<dynamic>)
          .where((file) => file['safe_id'] == widget.selectedSafeId)
          .toList();

      if (selectedSafeFiles.isNotEmpty) {
        selectedSafeFiles = selectedSafeFiles[0]['objects'];
      }

      isLoading = false;
    });

    int resultSizeBytes = 0;

    for (var size in selectedSafeFiles){
      resultSizeBytes += size['size'] as int;
    }

    setState(() {
      safeSizeBytes = resultSizeBytes;
    });
  }

  // Method to handle refresh action
  Future<void> _handleRefresh() async {
    await _getItems();
  }

  // Method to delete a file
  Future<void> _deleteFile(String fileId) async {
    await FileDeleteApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      safeId: widget.selectedSafeId,
      fileId: fileId
    ).execute();
  }

  // Method to download a file
  Future<void> _downloadFile(String contentPath, String fileName, BuildContext context, {bool toDownload = false}) async {
    if (!Platform.isAndroid && toDownload == true){
      throw UnsupportedError("Attention parameter 'toDownloads', supported only on Android devices.");
    }

    var statusPermission = await Permission.manageExternalStorage.status;

    if (!statusPermission.isGranted){
      var permissionStatus = await Permission.manageExternalStorage.request();
      if (!permissionStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.permissionDeniedUnableToSaveFile),
          ),
        );
        return;
      }
    }

    var api = FilesDownloadApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      pathToFile: contentPath,
    );

    await api.execute();

    if (api.response.statusCode != 200 && api.response.statusCode != 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToDownloadFileStatusCode(api.response.statusCode??0)),
        ),
      );
      return;
    }

    List<int>? fileBytes = api.response.bodyBytes;

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToDownloadFileNoDataReceived),
        ),
      );
      return;
    }

    try {
      Directory? appDownloadDir = await getDownloadsDirectory();
      String filePath = '${appDownloadDir!.path}/$fileName';
      if (toDownload){
        filePath = '/storage/emulated/0/Download/$fileName';
      }
      await File(filePath).writeAsBytes(fileBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            toDownload
            ? AppLocalizations.of(context)!.fileHasBeenSuccessfullySavedInDownloadFolder
            : AppLocalizations.of(context)!.fileDownloadedSuccessfully
          ),
        ),
      );
      setState(() {
        // Updating the UI here to show the "Open" and "Delete" buttons
        selectedSafeFiles.firstWhere((file) => file['name'] == fileName)['isDownloaded'] = true;
      });
    } catch (e) {
      AppLogger.logger.w(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorSavingFile),
        ),
      );
    }
  }

  // Method to open a file
  Future<void> _openFile(String fileName, BuildContext context) async {
    Directory? appDocDir = await getDownloadsDirectory();
    String filePath = '${appDocDir!.path}/$fileName';
    if (await File(filePath).exists()) {
      await OpenFile.open(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fileDoesNotExist),
        ),
      );
    }
  }

  // Method to select files
  Future<List<Map<String, dynamic>>> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    List<Map<String, dynamic>> selectedFiles = [];
    if (result != null) {
      result.paths.forEach((path) {
        selectedFiles.add({
          'file': File(path!),
          'name': path.split('/').last,
        });
      });
    }

    return selectedFiles;
  }

  bool _isAscii(String str) {
    RegExp asciiRegex = RegExp(r'^[ -~]+$');
    return asciiRegex.hasMatch(str);
  }

  // Method to select and upload files
  Future<void> _selectAndUploadFiles() async {
    List<Map<String, dynamic>> selectedFiles = await _selectFiles();
    
    // Reset upload progress before starting a new upload
    setState(() {
      _uploadProgress = 0.0;
    });

    // Total number of files to upload
    int totalFiles = selectedFiles.length;
    int filesUploaded = 0;

    for (var fileData in selectedFiles) {
      String fileName = fileData['name'];
      if (!_isAscii(fileName)){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.fileNameMustContainOnlyASCIICharactersWarning),
            ),
          );
      } else{
          File file = fileData['file'];
          List<int> bytes = await file.readAsBytes();
          
          // Upload each file
          await FileUploadApi(
            buildContext: context,
            apiUrl: widget.apiUrl,
            token: widget.token,
            safeId: widget.selectedSafeId,
            body: bytes,
            fileName: fileName,
          ).execute();

          // Update upload progress after each file upload
          filesUploaded++;
          double progress = filesUploaded / totalFiles;
          setState(() {
            _uploadProgress = progress;
          });
        }
        await _getItems();
        setState(() {
          _uploadProgress = 0.0;
        });
      }
  }

  Future<void> _deleteFileFromDevice(String fileName, BuildContext context) async{
    try{
      Directory? appDownloadDir = await getDownloadsDirectory();
      String filePath = '${appDownloadDir!.path}/$fileName';
      await File(filePath).delete();
      await _getItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fileWasSuccessfullyDeletedFromDevice),
        ),
      );
    } catch (e){
      AppLogger.logger.w(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                itemCount: selectedSafeFiles.length,
                itemBuilder: (context, index) {
                  var file = selectedSafeFiles[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppLocalizations.of(context)!.fileName(file['name'])),
                                    Text(AppLocalizations.of(context)!.size(Localization.formatBytes(file['size'], context))),
                                    Text(AppLocalizations.of(context)!.updatedAt(Localization.formatUnixTimestamp(file['updated_at']))),
                                  ],
                                ),
                              ),
                              Platform.isAndroid
                                ? FutureBuilder<bool>(
                                    future: _checkFile(file['name']),
                                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container();
                                      } else {
                                        return snapshot.data == true
                                            ? PopupMenuButton<String>(
                                                itemBuilder: (BuildContext context) => [
                                                  PopupMenuItem<String>(
                                                    value: 'saveToDownloads',
                                                    child: Text(AppLocalizations.of(context)!.saveToDownloads),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'deleteLocally',
                                                    child: Text(AppLocalizations.of(context)!.removeFromDevice),
                                                  ),
                                                ],
                                                onSelected: (String action) {
                                                  switch (action) {
                                                    case 'saveToDownloads':
                                                      _downloadFile(file['content_path'], file['name'], context, toDownload: true);
                                                      break;
                                                    case 'deleteLocally':
                                                      _deleteFileFromDevice(file['name'], context);
                                                      break;
                                                  }
                                                },
                                              )
                                            : PopupMenuButton<String>(
                                                itemBuilder: (BuildContext context) => [
                                                  PopupMenuItem<String>(
                                                    value: 'saveToDownloads',
                                                    child: Text(AppLocalizations.of(context)!.saveToDownloads),
                                                  ),
                                                ],
                                                onSelected: (String action) {
                                                  switch (action) {
                                                    case 'saveToDownloads':
                                                      _downloadFile(file['content_path'], file['name'], context, toDownload: true);
                                                      break;
                                                  }
                                                },
                                              );
                                      }
                                    },
                                  )
                                : Container()
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _downloadFile(file['content_path'], file['name'], context);
                                },
                                child: Text(AppLocalizations.of(context)!.download),
                              ),
                              FutureBuilder<bool>(
                                future: _checkFile(file['name']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Container();
                                  } else {
                                    bool isFileExists = snapshot.data ?? false;
                                    return isFileExists
                                        ? ElevatedButton(
                                            onPressed: () async{
                                              await _openFile(file['name'], context);
                                            },
                                            child: Text(AppLocalizations.of(context)!.open),
                                          )
                                        : SizedBox();
                                  }
                                },
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await _deleteFile(file['id']);
                                  await _getItems();
                                },
                                child: Text(AppLocalizations.of(context)!.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectAndUploadFiles,
        child: Icon(Icons.add),
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
      ),
      // Upload progress bar
      bottomNavigationBar: _uploadProgress > 0.0
          ? LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          : null,
      persistentFooterButtons: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                AppLocalizations.of(context)!.totalFileSizeWithValue(Localization.formatBytes(safeSizeBytes, context)),
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Method to check if a file exists
  Future<bool> _checkFile(String fileName) async {
    Directory? appDocDir = await getDownloadsDirectory();
    String filePath = '${appDocDir!.path}/$fileName';
    return File(filePath).exists();
  }
}
