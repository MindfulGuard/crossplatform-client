import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/net/api/auth/sign_out.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/components/icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

class _DevicesSettingsPageState extends State<DevicesSettingsPage> with TickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;
  Map<String, dynamic> userInfoApi = {};
  List<dynamic> devicesInfoApi = [];

  bool _sortByUpdatedAt = true; // default sorting by updatedAt
  bool _ascending = false; // default sorting in descending order

  Icon _defineDeviceIconByName(String device) {
    const double iconSize = 60;
    Icon responseIcon = Icon(Icons.devices, size: iconSize, color: Colors.black);

    device = device.toLowerCase();

    if (device.contains('android')) {
      responseIcon = Icon(Icons.android, size: iconSize, color: Colors.green[800]);
    } else if (device.contains('ios')) {
      responseIcon = Icon(Icons.apple, size: iconSize, color: Colors.black);
    } else if (device.contains('macos') || device.contains('mac os')) {
      responseIcon = Icon(Icons.apple, size: iconSize, color: Colors.black);
    } else if (device.contains('windows')) {
      responseIcon = Icon(Icons.window, size: iconSize, color: Colors.blue[400]);
    } else if (device.contains('linux')) {
      responseIcon = Icon(CustomIcons.linux, size: iconSize, color: Colors.orange[800]);
    } else if (
        device.contains('chrome') ||
        device.contains('firefox') ||
        device.contains('safari') ||
        device.contains('edge') ||
        device.contains('opera')
    ) {
      responseIcon = Icon(Icons.web, size: iconSize, color: Colors.blue[800]);
    }

    return responseIcon;
  }

  @override
  void initState() {
    super.initState();
    _getItems();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getItems() async {
    var api = await UserInfoApi(widget.apiUrl, widget.token).execute();

    if (api?.statusCode != 200 || api?.body == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
    } else {
      var apiResponse = json.decode(utf8.decode(api!.body.runes.toList()));
      setState(() {
        devicesInfoApi = List<dynamic>.from(apiResponse['tokens']);
      });
    }
  }

  Future<void> _deleteToken(String tokenId) async {
    var api = await SignOutApi(widget.apiUrl, tokenId, widget.token).execute();
    if (api?.statusCode == 200) {
      var userInfo = await UserInfoApi(widget.apiUrl, widget.token).execute();

      if (userInfo?.statusCode != 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } else {
        setState(() {
          devicesInfoApi = List<dynamic>.from(jsonDecode(userInfo!.body)['tokens']);
        });
        Navigator.pop(context); // Close the modal after successful token deletion
      }
    }
    print(api?.statusCode);
  }

  void _showTokenInformation(BuildContext context, Map<String, dynamic> tokenInfo) {
    _controller.value = 0.0;
    List<String> partsDevice = tokenInfo['device'].split('/');
    String deviceApplication = partsDevice[0];
    String deviceSystem = partsDevice[1];

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
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.5 + (_animation.value * 0.7),
                            child: Center(
                              child: _defineDeviceIconByName(tokenInfo['device']),
                            )
                          );
                        },
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
                      SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                          onPressed: () async {
                            await _deleteToken(tokenInfo['id']);
                          },
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(150, 50)), // Укажите желаемый размер
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.terminateSession,
                            style: TextStyle(
                              color: Colors.red,
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
    _controller.forward();
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
                  subtitle: Column( // Using a Column to display multiple pieces of information vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.updatedAt(Localization.formatUnixTimestamp(token['updated_at']))),
                      Text(AppLocalizations.of(context)!.createdAt(Localization.formatUnixTimestamp(token['created_at']))), // Formatted created at date and time
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
