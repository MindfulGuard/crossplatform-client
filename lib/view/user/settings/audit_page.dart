import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/net/api/user/audit.dart';
import 'package:mindfulguard/view/components/deviceIcon.dart';

class AuditSettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  AuditSettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _AuditSettingsPageState createState() => _AuditSettingsPageState();
}

class _AuditSettingsPageState extends State<AuditSettingsPage>
    with TickerProviderStateMixin {
  int page = 1;
  Map<String, dynamic> auditApi = {};
  late AnimationController _controller;
  late Animation<double> _animation;

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
    var api = UserAuditGetApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      page: page
    );

    await api.execute();

    if(api.response.body == null) {
        Navigator.pop(context);
    } else {
      var apiResponse =
          json.decode(utf8.decode(api.response.body.runes.toList()));
      setState(() {
        auditApi = apiResponse;
      });
    }
  }

  Widget _buildAuditList() {
    if (auditApi['list'] != null && auditApi['list'].length > 0) {
      return ListView.builder(
        itemCount: auditApi['list'].length,
        itemBuilder: (context, index) {
          var item = auditApi['list'][index];
          return ListTile(
            title: Text(item['object']),
            subtitle: Text(item['action']),
            trailing: Text(item['device']),
            leading: Icon(Icons.access_time),
            onTap: () {
              _showAuditDetails(item);
            },
          );
        },
      );
    } else {
      return Center(
        child: Text(AppLocalizations.of(context)!.noAuditItemsFound),
      );
    }
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: page > 1 ? () {
            setState(() {
              page--;
              _getItems();
            });
          } : null,
        ),
        Text(AppLocalizations.of(context)!.pageValueOfPages(page, auditApi['total_pages'] ?? 1)),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: page < (auditApi['total_pages'] ?? 1) ? () {
            setState(() {
              page++;
              _getItems();
            });
          } : null,
        ),
      ],
    );
  }


  void _showAuditDetails(Map<String, dynamic> auditItem) {
    List<String> partsDevice = auditItem['device'].split('/');
    String deviceApplication = partsDevice[0];
    String deviceSystem = partsDevice[1];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.apps),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auditItem['object'],
                          style: TextStyle(fontSize: 17),
                        ), // Title
                        Text(
                          AppLocalizations.of(context)!.object,
                          style: TextStyle(fontSize: 13),
                        ), // Subtitle
                      ],
                    ),
                  ],
                ),
                Divider(color: Colors.black),
                Row(
                  children: [
                    Icon(Icons.check_box_outlined),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auditItem['action'],
                          style: TextStyle(fontSize: 17),
                        ), // Title
                        Text(
                          AppLocalizations.of(context)!.action,
                          style: TextStyle(fontSize: 13),
                        ), // Subtitle
                      ],
                    ),
                  ],
                ),
                Divider(color: Colors.black),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceSystem,
                            style: TextStyle(fontSize: 17),
                          ), // Title
                          Text(
                            AppLocalizations.of(context)!.system,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    defineDeviceIconByName(deviceSystem, iconSize: 28).animate().shimmer(duration: 618.67.ms),
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
                          Localization.formatUnixTimestamp(auditItem['created_at']),
                          style: TextStyle(fontSize: 17),
                        ), // Title
                        Text(
                          AppLocalizations.of(context)!.dateAndTimeOfCreation,
                          style: TextStyle(fontSize: 13),
                        ), // Subtitle
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
                          auditItem['ip'],
                          style: TextStyle(fontSize: 17),
                        ), // Title
                        Text(
                          AppLocalizations.of(context)!.ipAddress,
                          style: TextStyle(fontSize: 13),
                        ), // Subtitle
                      ],
                    ),
                  ],
                ),
                Divider(color: Colors.black),
                Row(
                  children: [
                    Icon(Icons.tag),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auditItem['id'],
                          style: TextStyle(fontSize: 17),
                        ), // Titler
                        Text(
                          AppLocalizations.of(context)!.identifier,
                          style: TextStyle(fontSize: 13),
                        ), // Subtitle
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.auditLog),
      ),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: _buildAuditList(),
            ),
          ),
          _buildPagination(),
        ],
      ),
    );
  }
}
