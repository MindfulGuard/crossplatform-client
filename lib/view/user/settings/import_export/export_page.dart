import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  ExportPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _selectedFormat = 'json'; // JSON format is selected by default
  bool _shouldDecrypt = false; // Data is not decrypted by default

  Map<String, dynamic> _itemsApiResponse = {};
  List<int> _data = [];


  /// ```json
  /// {
  ///   "decrypted": false,
  ///   "safes": [
  ///     {
  ///       "safe_id": "UUID",
  ///       "name": "Safe",
  ///       "description": "Description",
  ///       "items": [
  ///         {
  ///           "item_id": "UUID",
  ///           "title": "Title",
  ///           "category": "LOGIN",
  ///           "notes": "There should be notes here",
  ///           "tags": [
  ///             "tag1",
  ///             "tag2"
  ///           ],
  ///           "favorite": true,
  ///           "sections": [
  ///             {
  ///               "section": "INIT",
  ///               "fields": [
  ///                 {
  ///                   "type": "STRING",
  ///                   "label": "login",
  ///                   "value": "user1"
  ///                 }
  ///               ]
  ///             }
  ///           ]
  ///         }
  ///       ]
  ///     }
  ///   ]
  /// }
  /// ```
  Future<void> _buildDataJson() async {
    Map<String, dynamic> result = {
      'decrypted': _shouldDecrypt,
      'safes': [],
    };

    // Bypass each safe in the source JSON
    for (var safe in _itemsApiResponse['safes']) {
      var correspondingSafe = _itemsApiResponse['list']
          .firstWhere((s) => s['safe_id'] == safe['id'], orElse: () => null);

      Map<String, dynamic> safeMap = {
        'safe_id': safe['id'],
        'name': safe['name'],
        'description': safe['description'],
        'items': [],
      };

      // If the safe is not found in the list of elements, add an empty safe
      if (correspondingSafe == null) {
        result['safes'].add(safeMap);
        continue;
      }

      // Bypass every item in the safe
      for (var item in correspondingSafe['items']) {
        Map<String, dynamic> itemMap = {
          'item_id': item['id'],
          'title': item['title'],
          'category': item['category'],
          'notes': item['notes'],
          'tags': List<String>.from(item['tags']),
          'favorite': item['favorite'],
          'sections': [],
        };

        // Bypass each section in the element
        for (var section in item['sections']) {
          List<Map<String, dynamic>> fields = [];
          // Bypass each field in the section
          for (var field in section['fields']) {
            fields.add({
              'type': field['type'],
              'label': field['label'],
              'value': field['value'],
            });
          }
          itemMap['sections'].add({
            'section': section['section'],
            'fields': fields,
          });
        }

        safeMap['items'].add(itemMap);
      }

      result['safes'].add(safeMap);
    }

    String resultJson = jsonEncode(result);

    _data = utf8.encode(resultJson);
  }
  
  Future<void> _getItems() async {
    var api = ItemsApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token
    );

    await api.execute();

    var dataApiResponse = json.decode(utf8.decode(api.response.body.runes.toList()));

    if (_shouldDecrypt){
      final db = AppDb();

      var dbData = await db.select(db.modelUser).getSingle();

      dataApiResponse = await Crypto.crypto().decryptMapValues(
          dataApiResponse,
          ['description', 'notes', 'value'],
          dbData.password!,
          Crypto.fromPrivateKeyToBytes(dbData.privateKey!)
      );
    }

    setState(() {
      _itemsApiResponse = dataApiResponse;
    });
  }

  
  void _exportData() async{
    await _getItems();
    if (_selectedFormat == 'json') {
      await _buildDataJson();
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

    try {
      Directory? appDocDir;
      String? path;

      if (Platform.isAndroid){
        appDocDir = await getExternalStorageDirectory();
        path = '/storage/emulated/0/Documents';
      } else {
        appDocDir = await getApplicationDocumentsDirectory();
        path = appDocDir.path;
      }

      String filePath = '$path/mindfulguard_data.json';
      print(filePath);
      await File(filePath).writeAsBytes(_data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fileHasBeenSuccessfullySavedInWithValue(
            AppLocalizations.of(context)!.documents
          )),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorSavingFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedFormat,
                  items: <String>['json'] // Formats
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFormat = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.format,
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Checkbox(
                      activeColor: Colors.blue,
                      value: _shouldDecrypt,
                      onChanged: (bool? value) {
                        setState(() {
                          _shouldDecrypt = value!;
                        });
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.decryptData,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _exportData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_download, color: Colors.black),
                      SizedBox(width: 8.0),
                      Text(
                        AppLocalizations.of(context)!.export,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
