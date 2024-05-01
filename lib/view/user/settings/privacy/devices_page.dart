import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/auth/sign_out.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/components/app_icons.dart';
import 'package:mindfulguard/view/components/dialog_window.dart';

class DevicesSettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  DevicesSettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _DevicesSettingsPageState createState() => _DevicesSettingsPageState();
}

class _DevicesSettingsPageState extends State<DevicesSettingsPage>{
  final db = AppDb();

  Map<String, dynamic> userInfoApi = {};
  List<dynamic> devicesInfoApi = [];

  bool _sortByUpdatedAt = true; // default sorting by updatedAt
  bool _ascending = false; // default sorting in descending order
  String currentTokenId = "";

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getItems() async {
    var api = UserInfoApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token
    );

    await api.execute();

    var apiResponse = json.decode(utf8.decode(api.response.body.runes.toList()));
    setState(() {
      devicesInfoApi = List<dynamic>.from(apiResponse['tokens']);
    });

    var tokenHash = Crypto.hash().sha(widget.token).toString().substring(0, 28); // Hashing the token and extracts the first 28 characters.
  
    for (var val in apiResponse['tokens']){
      if (val['short_hash'] == null){ // Checks if the "short_hash" key exists.
        return;
      } else{
        if (val['short_hash'] == tokenHash){ // Retrieves the token id if the token hash matches the one found.
          setState(() {
            currentTokenId = val['id'];
          });
          break;
        }
      }
    }
  }

  Future<void> _deleteToken(String tokenId) async {
    var api = SignOutApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      tokenId:  tokenId
    );

    await api.execute();

    if (api.response.statusCode == 200) {
      var userInfo = UserInfoApi(
        buildContext: context,
        apiUrl: widget.apiUrl,
        token: widget.token
      );

      await userInfo.execute();

      setState(() {
        devicesInfoApi = List<dynamic>.from(jsonDecode(userInfo.response.body)['tokens']);
      });

      Navigator.pop(context); // Close the modal after successful token deletion
      
    }
    AppLogger.logger.d(api.response.statusCode);
  }

  void _showTokenInformation(BuildContext context, Map<String, dynamic> tokenInfo) {
    List<String> partsDevice = tokenInfo['device'].split('/');
    String deviceApplication = "";
    String deviceSystem = "";
    try{
      deviceApplication = partsDevice[0];
      deviceSystem = partsDevice[1];
    } catch(e){
      AppLogger.logger.i(e);
      deviceApplication = tokenInfo['device'];
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Center(
              child: SingleChildScrollView( // Wrap with SingleChildScrollView
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Animate(// defineDeviceIconByName(tokenInfo['device']).animate().shimmer(duration: 618.67.ms).flipV(duration: 618.67.ms).scale(duration: 450.ms).saturate()
                          child: AppIcons().defineDeviceIconByName(tokenInfo['device']).animate(delay: 0.2.seconds).shimmer(duration: 618.67.ms).flipH().saturate()
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.devices),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceApplication,
                                style: TextStyle(fontSize: 17),
                              ), // Title
                              Text(
                                AppLocalizations.of(context)!.application,
                                style: TextStyle(fontSize: 13),
                              ), // Subtitle
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Colors.black),
                      Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deviceSystem,
                                style:  TextStyle(fontSize: 17),
                              ),
                              Text(
                                AppLocalizations.of(context)!.system,
                                style:  TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Colors.black),
                      Row(
                        children: [
                          Icon(Icons.access_time),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.formatUnixTimestamp(tokenInfo['updated_at']),
                                style:  TextStyle(fontSize: 17),
                              ),
                              Text(
                                AppLocalizations.of(context)!.dateAndTimeOfLastActivity,
                                style:  TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Colors.black),
                      Row(
                        children: [
                          Icon(Icons.access_time),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.formatUnixTimestamp(tokenInfo['created_at']),
                                style:  TextStyle(fontSize: 17),
                              ),
                              Text(
                                AppLocalizations.of(context)!.dateAndTimeOfTheFirstLogin,
                                style:  TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Colors.black),
                      Row(
                        children: [
                          Icon(Icons.language),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tokenInfo['last_ip'],
                                style:  TextStyle(fontSize: 17),
                              ),
                              Text(
                                AppLocalizations.of(context)!.ipAddress,
                                style:  TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: Colors.black),
                      Row(
                        children: [
                          Icon(Icons.event_busy),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Localization.formatUnixTimestamp(tokenInfo['expiration']),
                                style:  TextStyle(fontSize: 17),
                              ),
                              Text(
                                AppLocalizations.of(context)!.dateAndTimeOfSessionEnd,
                                style:  TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      currentTokenId == tokenInfo['id'] ? Container() : SizedBox(height: 20),
                        currentTokenId == tokenInfo['id']
                        ? Container() 
                        : Center(
                          child: ElevatedButton(
                          onPressed: () async {
                            await _deleteToken(tokenInfo['id']);
                          },
                          style:ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.black,
                            minimumSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.terminateSession,
                            style: TextStyle(
                              fontSize: 16
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SortDialog(
          sortByUpdatedAt: _sortByUpdatedAt,
          ascending: _ascending,
        );
      },
    );

    if (result != null) {
      bool sortByUpdatedAt = result['sortByUpdatedAt'];
      bool ascending = result['ascending'];

      // Apply the selected sorting parameters
      setState(() {
        _sortByUpdatedAt = sortByUpdatedAt;
        _ascending = ascending;
        if (sortByUpdatedAt) {
          devicesInfoApi.sort((a, b) {
            int comparison = a['updated_at'].compareTo(b['updated_at']);
            return ascending ? comparison : -comparison;
          });
        } else {
          devicesInfoApi.sort((a, b) {
            int comparison = a['created_at'].compareTo(b['created_at']);
            return ascending ? comparison : -comparison;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> tokens = (devicesInfoApi).cast<Map<String, dynamic>>();

    return Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.devices),
      actions: [
        IconButton(
          iconSize: 30,
          onPressed: (){_showSortDialog(context);},
          icon: Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialogWindow(
                  title: AppLocalizations.of(context)!.helpReference,
                  content: AppLocalizations.of(context)!.devicesInfoInfo,
                );
              },
            );
          },
          icon: Icon(Icons.help_outline),
        ),
        ],
      ),
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            for (var token in tokens)
              Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.device(token['device'])),
                  onTap: () {
                    _showTokenInformation(context, token);
                  },
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.updatedAt(Localization.formatUnixTimestamp(token['updated_at']))),
                      Text(AppLocalizations.of(context)!.createdAtWithValue(Localization.formatUnixTimestamp(token['created_at']))),
                      Text(AppLocalizations.of(context)!.ipAddressWithValue(token['last_ip'])),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}

class SortDialog extends StatefulWidget {
  final bool sortByUpdatedAt;
  final bool ascending;

  SortDialog({
    this.sortByUpdatedAt = true,
    this.ascending = false,
  });

  @override
  _SortDialogState createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  late bool _sortByUpdatedAt;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _sortByUpdatedAt = widget.sortByUpdatedAt;
    _ascending = widget.ascending;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.sorting),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(AppLocalizations.of(context)!.dateAndTimeOfLastActivity),
            leading: Radio(
              value: true,
              groupValue: _sortByUpdatedAt,
              onChanged: (value) {
                setState(() {
                  _sortByUpdatedAt = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.dateAndTimeOfTheFirstLogin),
            leading: Radio(
              value: false,
              groupValue: _sortByUpdatedAt,
              onChanged: (value) {
                setState(() {
                  _sortByUpdatedAt = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.inDescendingOrder),
            leading: Checkbox(
              value: _ascending,
              onChanged: (value) {
                setState(() {
                  _ascending = value!;
                });
              },
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog box without applying changes
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'sortByUpdatedAt': _sortByUpdatedAt,
              'ascending': _ascending,
            }); // Pass the selected sorting parameters back to the calling widget
          },
          child: Text(AppLocalizations.of(context)!.apply),
        ),
      ],
    );
  }
}
