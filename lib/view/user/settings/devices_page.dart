import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mindfulguard/net/api/auth/sign_out.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/utils/time.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/user/settings/settings_list_page.dart';

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

  IconData _defineDeviceIconByName(String device) {
    IconData responseIcon = Icons.devices;

    device = device.toLowerCase();

    if (device.contains('android')) {
      responseIcon = Icons.android;
    } else if (device.contains('ios')) {
      responseIcon = Icons.apple;
    } else if (device.contains('macos') || device.contains('mac os')) {
      responseIcon = Icons.apple;
    } else if (device.contains('windows')) {
      responseIcon = Icons.window;
    } else if (device.contains('linux')) {
      responseIcon = Icons.laptop_chromebook;
    } else if (
        device.contains('chrome') ||
        device.contains('firefox') ||
        device.contains('safari') ||
        device.contains('edge') ||
        device.contains('opera')
    ) {
      responseIcon = Icons.web;
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.5 + (_animation.value * 0.7),
                            child: Icon(_defineDeviceIconByName(tokenInfo['device']), size: 70, color: Colors.blue),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.application(deviceApplication), style: TextStyle(fontSize: 20)),
                      Text(AppLocalizations.of(context)!.system(deviceSystem), style: TextStyle(fontSize: 20)),
                      Text(AppLocalizations.of(context)!.createdAt(formatUnixTimestamp(tokenInfo['created_at'])), style: TextStyle(fontSize: 20)),
                      Text(AppLocalizations.of(context)!.updatedAt(formatUnixTimestamp(tokenInfo['updated_at'])), style: TextStyle(fontSize: 20)),
                      Text(AppLocalizations.of(context)!.expirationTime(formatUnixTimestamp(tokenInfo['expiration'])), style: TextStyle(fontSize: 20)),
                      Text(AppLocalizations.of(context)!.ipAddress(tokenInfo['last_ip']), style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async{
                          await _deleteToken(tokenInfo['id']);
                        },
                        child: Text(AppLocalizations.of(context)!.terminateSession),
                      ),
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

  @override
  Widget build(BuildContext context) {
    List<dynamic> tokens = (devicesInfoApi).cast<Map<String, dynamic>>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.devices),
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
                      Text(AppLocalizations.of(context)!.createdAt(formatUnixTimestamp(token['created_at']))), // Formatted created at date and time
                      Text(AppLocalizations.of(context)!.updatedAt(formatUnixTimestamp(token['updated_at']))),
                      Text(AppLocalizations.of(context)!.ipAddress(token['last_ip'])),
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