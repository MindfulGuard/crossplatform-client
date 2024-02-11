// Importing necessary Dart packages and dependencies
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mindfulguard/net/api/items/files/delete.dart';
import 'package:mindfulguard/net/api/items/files/download.dart';
import 'package:mindfulguard/net/api/items/files/upload.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/utils/disk.dart';
import 'package:mindfulguard/utils/time.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Defining a StatefulWidget for the FilesPage
class FilesPage extends StatefulWidget {
  final String apiUrl;
  final String token;
  final String password;
  final String privateKey;
  final Uint8List privateKeyBytes;
  String selectedSafeId;

  // Constructor to initialize the FilesPage
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

// State class for the FilesPage widget
class _FilesPageState extends State<FilesPage> {
  late List<dynamic> selectedSafeFiles = [];
  Map<String, dynamic> itemsApiResponse = {};
  bool isLoading = true;
  double _uploadProgress = 0.0;

  // initState method to initialize the state of the widget
  @override
  void initState() {
    super.initState();
    _getItems();
  }

  // Method to fetch items from the API
  Future<void> _getItems() async {
    var api = await ItemsApi(widget.apiUrl, widget.token).execute();

    if (api?.statusCode != 200 || api?.body == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
      return;
    } else {
      var decodedApiResponse = json.decode(utf8.decode(api!.body.runes.toList()));

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
    }
  }

  // Method to handle refresh action
  Future<void> _handleRefresh() async {
    await _getItems();
  }

  // Method to delete a file
  Future<void> _deleteFile(String fileId) async {
    await FileDeleteApi(
      widget.apiUrl,
      widget.token,
      widget.selectedSafeId,
      fileId
    ).execute();
  }

  // Method to download a file
  Future<void> _downloadFile(String contentPath, String fileName, BuildContext context) async {
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

    var api = await FilesDownloadApi(
      widget.apiUrl,
      widget.token,
      contentPath,
    ).execute();

    if (api?.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToDownloadFileStatusCode(api?.statusCode??0)),
        ),
      );
      return;
    }

    List<int>? fileBytes = api!.bodyBytes;

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToDownloadFileNoDataReceived),
        ),
      );
      return;
    }

    try {
      Directory? appDocDir = await getDownloadsDirectory();
      String filePath = '${appDocDir!.path}/$fileName';
      await File(filePath).writeAsBytes(fileBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fileDownloadedSuccessfully),
        ),
      );
      setState(() {
        // Updating the UI here to show the "Open" and "Delete" buttons
        selectedSafeFiles.firstWhere((file) => file['name'] == fileName)['isDownloaded'] = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving file: $e'),
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
      File file = fileData['file'];
      String fileName = fileData['name'];
      List<int> bytes = await file.readAsBytes();
      
      // Upload each file
      await FileUploadApi(
        widget.apiUrl,
        widget.token,
        widget.selectedSafeId,
        bytes,
        fileName,
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

  // Build method to create the UI
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
                          Text(AppLocalizations.of(context)!.fileName(file['name'])),
                          Text(AppLocalizations.of(context)!.size('${formatBytes(file['size'])}')),
                          Text(AppLocalizations.of(context)!.updatedAt(formatUnixTimestamp(file['updated_at']))),
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
                                future: _checkFile(file['name']), // Check if the file exists in the directory
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    bool isFileExists = snapshot.data ?? false;
                                    return isFileExists
                                        ? ElevatedButton(
                                            onPressed: () async{
                                              await _openFile(file['name'], context);
                                            },
                                            child: Text(AppLocalizations.of(context)!.open),
                                          )
                                        : SizedBox(); // Return empty SizedBox if file doesn't exist
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
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          : null,
    );
  }

  // Method to check if a file exists
  Future<bool> _checkFile(String fileName) async {
    Directory? appDocDir = await getDownloadsDirectory();
    String filePath = '${appDocDir!.path}/$fileName';
    return File(filePath).exists();
  }
}
