import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/updater/desktop_windows.dart';

class UpdateApplicationSettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  UpdateApplicationSettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateApplicationSettingsPageState createState() =>
      _UpdateApplicationSettingsPageState();
}

class _UpdateApplicationSettingsPageState
    extends State<UpdateApplicationSettingsPage> {
  bool isPreReleaseSelected = false;
  var updaterDesktopWindows = UpdaterDesktopWindows();
  bool updateAvailable = false;
  bool isLoaded = false;
  String _currentVersion = "";
  String _lastVersion = "";
  bool downloading = false;

  @override
  void initState() {
    super.initState(); 
    init();
  }

  Future<void> _checkUpdates() async{
    int currentVersion = int.parse(_currentVersion.replaceAll(".", ""));
    
    String tempLastVersionRelease = _lastVersion;
    int lastVersionRelease = int.parse(tempLastVersionRelease.replaceAll(".", ""));

    if (lastVersionRelease > currentVersion){
      setState(() {
        updateAvailable = true;
      });
    }
  }

  Future<void> init() async{
    await updaterDesktopWindows.init();
    _currentVersion = updaterDesktopWindows.getAppVersion();
    _lastVersion = await updaterDesktopWindows.getLastVersionReleaseGithub();

    _checkUpdates();

    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updatingApplication),
      ),
      body: Center(
        child: isLoaded
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: downloading ? CircularProgressIndicator() : null,
                    ),
                    SizedBox(height: 45),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.currentVersionWithValue(_currentVersion),
                        style: TextStyle(
                          fontSize: 14
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.latestVersionWithValue(_lastVersion),
                        style: TextStyle(
                          fontSize: 14
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    IgnorePointer(
                      ignoring: updateAvailable && !downloading ? false : true,
                      child: ElevatedButton(
                        onPressed: updateAvailable ? _handleUpdate : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: updateAvailable && !downloading ? Colors.blue : Colors.grey,
                          foregroundColor: Colors.black,
                          minimumSize: Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.update,
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
            : CircularProgressIndicator(),
      ),
    );
  }



  Future<void> _handleUpdate() async{
    setState(() {
      downloading = true;
    });
    await updaterDesktopWindows.update();
    setState(() {
      downloading = false;
    });
  }
}
