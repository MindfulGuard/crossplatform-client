import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/items/safe/create.dart';
import 'package:mindfulguard/net/api/items/safe/delete.dart';
import 'package:mindfulguard/net/api/items/safe/update.dart';
import 'package:mindfulguard/view/components/glass_morphism.dart';
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

  void Function()? _cardInfoOnLongPress;
  Function(TapDownDetails)? _cardInfoOnSecondaryTapDown;

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
    var api = ItemsApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token
    );

    await api.execute();

    var decodedApiResponse = json.decode(utf8.decode(api.response.body.runes.toList()));
    try{
      var decryptedApiResponse = await Crypto.crypto().decryptMapValues(
          decodedApiResponse,
          ['description'],
          widget.password,
          widget.privateKeyBytes
      );
      setState(() {
        widget.itemsApiResponse = decryptedApiResponse; // Update itemsApiResponse
        fileCounts = _calculateFileCount(widget.itemsApiResponse); // Recalculate fileCounts
      });
    } catch (e){
      setState(() {
        widget.itemsApiResponse = decodedApiResponse; // Update itemsApiResponse
        fileCounts = _calculateFileCount(widget.itemsApiResponse); // Recalculate fileCounts
      });
    }

  }

  Future<void> _createSafe(BuildContext ctx, String name, String description) async{
    var api = SafeCreateApi(
      buildContext: ctx,
      apiUrl: widget.apiUrl,
      token: widget.token,
      name: name,
      description: await Crypto.crypto().encrypt(description, widget.password, widget.privateKeyBytes),
    );

    await api.execute();

    await _getItems();
    Navigator.pop(ctx); // Close the modal
  }

  Future<void> _updateSafe(BuildContext ctx, String safeId, String name, String description) async{
    var api = SafeUpdateApi(
      buildContext: ctx,
      apiUrl: widget.apiUrl,
      token: widget.token,
      safeId: safeId,
      name: name,
      description: await Crypto.crypto().encrypt(description, widget.password, widget.privateKeyBytes),
    );

    await api.execute();

    await _getItems();
    Navigator.pop(ctx); // Close the modal
   
  }

  Future<void> _deleteSafe(String safeId) async{
    await SafeDeleteApi(
        buildContext: context,
        apiUrl: widget.apiUrl,
        token: widget.token,
        safeId: safeId
    ).execute();

    await _getItems();
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

  void _buildCard(Map<String, dynamic> safe){
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS){
      _cardInfoOnSecondaryTapDown = (details){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return GlassMorphismItemActionsWidget(
              functions: [
                GlassMorphismActionRow(
                  icon: Icons.edit,
                  label: AppLocalizations.of(context)!.edit,
                  onTap: () {
                    Navigator.pop(context);
                    _showEditSafeModal(
                      context,
                      safe["id"],
                      TextEditingController(text: safe["name"]),
                      TextEditingController(text: safe["description"])
                      );
                  }
                ),
                GlassMorphismActionRow(
                  icon: Icons.delete,
                  label: AppLocalizations.of(context)!.delete,
                  onTap: () async{
                    Navigator.pop(context);
                    await _deleteSafe(safe["id"]);
                  }
                ),
              ],
            );
          },
        );
      };
    } else {
        _cardInfoOnLongPress = (){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return GlassMorphismItemActionsWidget(
              functions: [
                GlassMorphismActionRow(
                  icon: Icons.edit,
                  label: AppLocalizations.of(context)!.edit,
                  onTap: () {
                    Navigator.pop(context);
                    _showEditSafeModal(
                      context,
                      safe["id"],
                      TextEditingController(text: safe["name"]),
                      TextEditingController(text: safe["description"])
                      );
                  }
                ),
                GlassMorphismActionRow(
                  icon: Icons.delete,
                  label: AppLocalizations.of(context)!.delete,
                  onTap: () async{
                    Navigator.pop(context);
                    await _deleteSafe(safe["id"]);
                  }
                ),
              ],
            );
          },
        );
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  RefreshIndicator(
        onRefresh: _getItems,
        child: ListView.builder(
          itemCount: (widget.itemsApiResponse["safes"] as List<dynamic>).length,
          itemBuilder: (context, index) {
            var safe = widget.itemsApiResponse["safes"]![index] as Map<String, dynamic>;
            _buildCard(safe);
            String safeid = safe["id"];
            int? fileCount = fileCounts[safeid] ?? 0;
            return Material(
              child:  Card(
                child: InkWell(
                  onSecondaryTapDown: _cardInfoOnSecondaryTapDown,
                  onLongPress: _cardInfoOnLongPress,
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
                          safesApiResponse: widget.itemsApiResponse["safes"],
                          itemsApiResponse: widget.itemsApiResponse,
                        ),
                      ),
                    );
                  },
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.nameWithValue(safe["name"])),
                        subtitle: safe["description"] != "" && safe["description"] != null
                        ? Text(AppLocalizations.of(context)!.descriptionWithValue(safe["description"]))
                        : null,
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.updatedAt(Localization.formatUnixTimestamp(safe["updated_at"] as int))),
                        subtitle: Text(AppLocalizations.of(context)!.createdAtWithValue(Localization.formatUnixTimestamp(safe["created_at"] as int))),
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
                      AppLogger.logger.i("Safe id: $safeId");
                      await _updateSafe(
                        context,
                        safeId,
                        name.text,
                        description.text,
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
