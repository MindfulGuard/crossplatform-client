import 'dart:convert';

import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/items/safe/delete.dart';

class ImportPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  ImportPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _replaceExistingData = false;
  bool _deleteDataBeforeImport = false;

  Map<String, dynamic> _itemsApiResponse = {};

  Map<String, dynamic> _data = {};

  Future<void> _getItems() async {
    var api = ItemsApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token
    );

    await api.execute();

    var dataApiResponse = json.decode(utf8.decode(api.response.body.runes.toList()));

    setState(() {
      _itemsApiResponse = dataApiResponse;
    });
  }

  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );

    Map<String, dynamic> selectedFiles = {};
    if (result != null) {
      selectedFiles['path'] = result.paths.first!;
      selectedFiles['name'] = result.paths.first!.split('/').last;
      selectedFiles['data'] = result.files.first.bytes;
      selectedFiles['extension'] = result.files.first.extension;
    }

    setState(() {
      _data = selectedFiles;
    });
  }

  Future<void> _export() async{
    // path.extension(selectedFiles[0]['name']
    await _selectFiles();
    await _getItems();
    _Handling? handling;
    
    if (_data['extension'] == 'json'){
      handling = _HandlingJson(
        context: context,
        data: _data,
        itemsApiResponse: _itemsApiResponse,
        apiUrl: widget.apiUrl,
        token: widget.token
      );
    } else{
      return;
    }

    if (_replaceExistingData){
      await handling.handleReplaceExistingData();
    } else if(_deleteDataBeforeImport){
      await handling.handleDeleteDataBeforeImport();
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
                Row(
                  children: [
                    IgnorePointer(
                      ignoring: _replaceExistingData == true ? true : false,
                      child: Checkbox(
                        activeColor: Colors.blue,
                        value: _deleteDataBeforeImport,
                        onChanged: (bool? value) {
                          setState(() {
                            _deleteDataBeforeImport = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.deleteExistingDataBeforeImporting,
                        style: TextStyle(color: _replaceExistingData == true ? Colors.grey : Colors.black),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    IgnorePointer(
                      ignoring: _deleteDataBeforeImport == true ? true : false,
                      child: Checkbox(
                        activeColor: Colors.blue,
                        value: _replaceExistingData,
                        onChanged: (bool? value) {
                          setState(() {
                            _replaceExistingData = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.replaceExistingData,
                        style: TextStyle(color: _deleteDataBeforeImport == true ? Colors.grey : Colors.black),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _export,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload, color: Colors.black),
                      SizedBox(width: 8.0),
                      Text(
                        AppLocalizations.of(context)!.import,
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

abstract class _Handling{
  String apiUrl;
  String token;
  Map<String, dynamic> data;
  Map<String, dynamic> itemsApiResponse;
  BuildContext context;

  final db = AppDb();

  _Handling({
    required this.context,
    required this.itemsApiResponse,
    required this.data,
    required this.apiUrl,
    required this.token,
  });

  Future<void> handleDeleteDataBeforeImport();
  Future<void> handleReplaceExistingData();
  Future<void> handleWithoutParams();
}

class _HandlingJson extends _Handling{
  _HandlingJson({
    required super.itemsApiResponse,
    required super.data,
    required super.context,
    required super.apiUrl,
    required super.token
  });

  @override
  Future<void> handleDeleteDataBeforeImport() async{
    if (itemsApiResponse['safes'].isNotEmpty){
      for (var safeInfo in itemsApiResponse['safes']){
        await SafeDeleteApi(
          buildContext: context,
          apiUrl: apiUrl,
          token: token,
          safeId: safeInfo['id']
        ).execute();
      }
    }

    Map<String, dynamic> dataJson = json.decode(utf8.decode(data['data']));

    if (dataJson['decrypted'] == false){
      var dbData = await db.select(db.modelUser).getSingle();

      dataJson = await Crypto.crypto().decryptMapValues(
          dataJson,
          ['description', 'notes', 'value'],
          dbData.password!,
          Crypto.fromPrivateKeyToBytes(dbData.privateKey!)
      );
    }

    print(dataJson);
  }

  @override
  Future<void> handleReplaceExistingData() async {
    // TODO: implement handleDeleteDataBeforeImport
    throw UnimplementedError();
  }
  
  @override
  Future<void> handleWithoutParams() {
    // TODO: implement handleWithoutParams
    throw UnimplementedError();
  }
}