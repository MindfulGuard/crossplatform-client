import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mindfulguard/net/api/auth/sign_out.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/utils/disk.dart';
import 'package:mindfulguard/utils/time.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/user/settings/settings_list_page.dart';

class UserInfoPage extends StatefulWidget {
  Map<String, dynamic> userInfoApi;
  Map<String, dynamic> diskInfo;
  final String apiUrl;
  final String token;

  UserInfoPage({
    required this.userInfoApi,
    required this.diskInfo,
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> with TickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;

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
          widget.userInfoApi = Map<String, Object>.from(jsonDecode(userInfo!.body));
        });
        Navigator.pop(context); // Close the modal after successful token deletion
      }
    }
    print(api?.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    var information = widget.userInfoApi['information'] as Map<String, dynamic>;
    List<dynamic> tokens = (widget.userInfoApi['tokens'] as List<dynamic>).cast<Map<String, dynamic>>();

    return Scaffold(
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.userInformation,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Increased font size to 24
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.apiServer(': ${widget.apiUrl}'), style: TextStyle(fontSize: 16)), // Set font size to 16
                Text(AppLocalizations.of(context)!.username(information['username']), style: TextStyle(fontSize: 16)), // Set font size to 16
                Text(AppLocalizations.of(context)!.createdAt(formatUnixTimestamp(information['created_at'])), style: TextStyle(fontSize: 16)), // Set font size to 16
                Text(AppLocalizations.of(context)!.ipAddress(information['ip']), style: TextStyle(fontSize: 16)), // Set font size to 16
              ],
            ),
            Divider(thickness: 1, color: Colors.black),
            SizedBox(height: 10),
            DiskSpaceBarWidget(
              totalSpace: widget.diskInfo['total_space'],
              filledSpace: widget.diskInfo['filled_space'],
            ),
          ],
        ),
      ),
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsListPage(
            devicesInfoApi: tokens,
            userInfoApi: information,
            apiUrl: widget.apiUrl,
            token: widget.token,
          )),
        );
        },
        child: Icon(Icons.settings),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


class DiskSpaceBarWidget extends StatelessWidget {
  final int totalSpace; // Total space (in bytes)
  final int filledSpace; // Filled space (in bytes)

  DiskSpaceBarWidget({required this.totalSpace, required this.filledSpace});

  @override
  Widget build(BuildContext context) {
    double fillPercentage = filledSpace / totalSpace;
    Color progressBarColor = _getProgressBarColor(fillPercentage);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: fillPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
              borderRadius: BorderRadius.circular(10),
              minHeight: 10,
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.totalDiskSpace(formatBytes(totalSpace, context)),
              style: TextStyle(fontSize: 16)
            ),
            Text(
              AppLocalizations.of(context)!.availableDiskSpace(formatBytes(totalSpace-filledSpace, context)),
              style: TextStyle(fontSize: 16),
            ),
            Text(
              AppLocalizations.of(context)!.filledDiskSpace(formatBytes(filledSpace, context)),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressBarColor(double fillPercentage) {
    if (fillPercentage < 0.5) {
      return Colors.green;
    } else if (fillPercentage < 0.75) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}