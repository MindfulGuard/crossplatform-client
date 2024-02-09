import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mindfulguard/net/api/auth/sign_out.dart';
import 'package:mindfulguard/net/api/user/information.dart';
import 'package:mindfulguard/utils/time.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';

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
                      SizedBox(height: 20),
                      Text('Token Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Application: ${deviceApplication}', style: TextStyle(fontSize: 20)),
                      Text('System: ${deviceSystem}', style: TextStyle(fontSize: 20)),
                      Text('Created At: ${formatUnixTimestamp(tokenInfo['created_at'])}', style: TextStyle(fontSize: 20)),
                      Text('Updated At: ${formatUnixTimestamp(tokenInfo['updated_at'])}', style: TextStyle(fontSize: 20)),
                      Text('Expiration Time: ${formatUnixTimestamp(tokenInfo['expiration'])}', style: TextStyle(fontSize: 20)),
                      Text('Ip Address: ${tokenInfo['last_ip']}', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async{
                          await _deleteToken(tokenInfo['id']);
                        },
                        child: Text('Terminate Session'),
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
              'User Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Increased font size to 24
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Api Server: ${widget.apiUrl}', style: TextStyle(fontSize: 16)), // Set font size to 16
                Text('Username: ${information['username']}', style: TextStyle(fontSize: 16)), // Set font size to 16
                Text('Created At: ${formatUnixTimestamp(information['created_at'])}', style: TextStyle(fontSize: 16)), // Set font size to 16
                Text('IP Address: ${information['ip']}', style: TextStyle(fontSize: 16)), // Set font size to 16
              ],
            ),
            Divider(thickness: 1, color: Colors.black),
            SizedBox(height: 10),
            DiskSpaceBarWidget(
              totalSpace: widget.diskInfo['total_space'],
              filledSpace: widget.diskInfo['filled_space'],
            ),
            SizedBox(height: 10),
            Text(
              'Devices',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            for (var token in tokens)
              Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('Device: ${token['device']}'),
                  onTap: () {
                    _showTokenInformation(context, token);
                  },
                  subtitle: Column( // Using a Column to display multiple pieces of information vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Created At: ${formatUnixTimestamp(token['created_at'])}'), // Formatted created at date and time
                      Text('Updated At: ${formatUnixTimestamp(token['updated_at'])}'),
                      Text('IP Address: ${token['last_ip']}'),
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
              'Total Space: ${_formatBytes(totalSpace)}',
              style: TextStyle(fontSize: 16)
            ),
            Text(
              'Filled: ${_formatBytes(filledSpace)}',
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

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    int i = 0;
    double val = bytes.toDouble();
    while (val >= 1024 && i < units.length - 1) {
      val /= 1024;
      i++;
    }
    return '${val.toStringAsFixed(2)} ${units[i]}';
  }
}