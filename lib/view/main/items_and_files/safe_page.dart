import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/items/safe/create.dart';
import 'package:mindfulguard/net/api/items/safe/delete.dart';
import 'package:mindfulguard/net/api/items/safe/update.dart';
import 'package:mindfulguard/view/main/items_and_files/items_navigator_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SafePage extends StatefulWidget {
  final String apiUrl;
  final String token;
  final String password;
  final String privateKey;
  final Uint8List privateKeyBytes;
  Map<String, dynamic> itemsApiResponse;

  SafePage({
    required this.apiUrl,
    required this.token,
    required this.password,
    required this.privateKey,
    required this.privateKeyBytes,
    required this.itemsApiResponse,
    Key? key,
  }) : super(key: key);

  @override
  _SafePageState createState() => _SafePageState();
}

class _SafePageState extends State<SafePage> {
  Map<String, int> fileCounts = {};

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fileCounts = _calculateFileCount(widget.itemsApiResponse); // Recalculate fileCounts
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose(); // Dispose of the TextEditingController
    _descriptionController.dispose(); // Dispose of the TextEditingController
    super.dispose();
  }

  Future<void> _getItems() async {
    var api = await ItemsApi(widget.apiUrl, widget.token).execute();

    if (api?.statusCode != 200 || api?.body == null) {
      return;
    } else {
      var decodedApiResponse = json.decode(utf8.decode(api!.body.runes.toList()));
      var decryptedApiResponse = await Crypto.crypto().decryptMapValues(
          decodedApiResponse,
          widget.password,
          widget.privateKeyBytes
      );
      setState(() {
        widget.itemsApiResponse = decryptedApiResponse; // Update itemsApiResponse
        fileCounts = _calculateFileCount(widget.itemsApiResponse); // Recalculate fileCounts
      });
    }
  }

  Future<void> _createSafe(BuildContext ctx, String name, String description) async{
    var api = await SafeCreateApi(
      widget.apiUrl,
      widget.token,
      name,
      await Crypto.crypto().encrypt(description, widget.password, widget.privateKeyBytes),
    ).execute();
    if (api?.statusCode != 200){
      errorMessage = jsonDecode(api!.body)['msg'][AppLocalizations.of(context)?.localeName] ?? json.decode(api!.body)['msg']['en'];
    } else{
      await _getItems();
      Navigator.pop(ctx); // Close the modal
    }
  }

  Future<void> _updateSafe(BuildContext ctx, String safeId, String name, String description) async{
    var api = await SafeUpdateApi(
      widget.apiUrl,
      widget.token,
      safeId,
      name,
      await Crypto.crypto().encrypt(description, widget.password, widget.privateKeyBytes),
    ).execute();
    if (api?.statusCode != 200){
      errorMessage = jsonDecode(api!.body)['msg'][AppLocalizations.of(context)?.localeName] ?? json.decode(api!.body)['msg']['en'];
    } else{
      await _getItems();
      Navigator.pop(ctx); // Close the modal
    }
  }

  Future<void> _deleteSafe(String safeId) async{
    var api = await SafeDeleteApi(
        widget.apiUrl,
        widget.token,
        safeId
    ).execute();
    if (api?.statusCode != 200){
    } else{
      await _getItems();
    }
  }

  Map<String, int> _calculateFileCount(Map<String, dynamic> data) {
    Map<String, int> result = {};
    if (data.containsKey('files')) {
      for (var filesObj in data['files'] as List<dynamic>) {
        if (filesObj is Map<String, dynamic>) {
          var objects = filesObj['objects'];
          if (objects is List<dynamic>) {
            result[filesObj['safe_id'] as String] = objects.length;
          }
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: (widget.itemsApiResponse["safes"] as List<dynamic>).length,
        itemBuilder: (context, index) {
          var safe = widget.itemsApiResponse["safes"]![index] as Map<String, dynamic>;
          String safeid = safe["id"];
          int? fileCount = fileCounts[safeid] ?? 0;
          return Material(
            child: Card(
              child: InkWell(
                onLongPress: () {
                  _showItemActionsDialog(context, safe["id"], safe["name"], safe["description"]);
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemsNavigator(
                        apiUrl: widget.apiUrl,
                        token: widget.token,
                        selectedSafeId: safeid,
                        selectedSafeName: safe['name'],
                        password: widget.password,
                        privateKey: widget.privateKey,
                        privateKeyBytes: widget.privateKeyBytes,
                        itemsApiResponse: widget.itemsApiResponse,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.nameWithValue(safe["name"])),
                      subtitle: Text(AppLocalizations.of(context)!.descriptionWithValue(safe["description"])),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.updatedAt(Localization.formatUnixTimestamp(safe["updated_at"] as int))),
                      subtitle: Text(AppLocalizations.of(context)!.createdAt(Localization.formatUnixTimestamp(safe["created_at"] as int))),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(AppLocalizations.of(context)!.itemCount(safe["count_items"])),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(AppLocalizations.of(context)!.fileCount(fileCount)), // Display the number of files
                          ),
                        ),
                      ],
                    ),
                    // Add more ListTile widgets here for other safe properties if needed
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSafeModal(context); // Call a function to show the modal when the plus button is pressed
        },
        child: Icon(Icons.add),
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showItemActionsDialog(BuildContext context, String safeId, String name, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            constraints: BoxConstraints(maxHeight: 250),
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionRow(Icons.edit, AppLocalizations.of(context)!.edit, () {
                          Navigator.pop(context);
                          _showEditSafeModal(context, safeId, TextEditingController(text: name), TextEditingController(text: description));
                        }),
                        SizedBox(height: 8),
                        _buildActionRow(Icons.delete, AppLocalizations.of(context)!.delete, () async {
                          Navigator.pop(context);
                          await _deleteSafe(safeId);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionRow(IconData icon, String label, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSafeModal(BuildContext context) {
    _nameController.clear();
    _descriptionController.clear();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      await _createSafe(context, _nameController.text, _descriptionController.text);
                    },
                    child: Text(AppLocalizations.of(context)!.createSafe),
                  ),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.normal,
                    )
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditSafeModal(
    BuildContext context,
    String safeId,
    TextEditingController name,
    TextEditingController description
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: name,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                  ),
                  SizedBox(height: 12.0),
                  TextField(
                    controller: description,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      print(safeId);
                      await _updateSafe(
                        context,
                        safeId,
                        name.text,
                        description.text,
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.normal,
                    )
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
