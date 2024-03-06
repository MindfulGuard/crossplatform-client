import 'package:flutter/material.dart';
import 'package:mindfulguard/view/components/icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ApplicationInfoSettingsPage extends StatefulWidget {
  const ApplicationInfoSettingsPage({Key? key}) : super(key: key);

  @override
  _ApplicationInfoSettingsPageState createState() => _ApplicationInfoSettingsPageState();
}

class _ApplicationInfoSettingsPageState extends State<ApplicationInfoSettingsPage> {
  String appName = "";
  String license = "";
  String version = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    _loadAppInfo(context);
  }

  Future<void> _loadAppInfo(BuildContext context) async {
    PackageInfo appInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = appInfo.version;
      appName = "${appInfo.appName[0].toUpperCase() + appInfo.appName.substring(1)} Client";
      description = AppLocalizations.of(context)!.aboutAppDescription(appInfo.appName[0].toUpperCase() + appInfo.appName.substring(1));
      license = AppLocalizations.of(context)!.aboutAppLicense;
    });
  }

  Future<void> _openGitHub() async {
    const url = 'https://github.com/MindfulGuard/crossplatform-client';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.aboutApp,
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              license,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.aboutAppVersionWithValue(version),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(CustomIcons.github),
              onPressed: _openGitHub,
              iconSize: 40,
            ),
          ],
        ),
      ),
    );
  }
}
