import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';

class ServiceNotAvailablePage extends StatefulWidget {
  ServiceNotAvailablePage({
    Key? key,
  }) : super(key: key);

  @override
  _ServiceNotAvailablePageState createState() => _ServiceNotAvailablePageState();
}

class _ServiceNotAvailablePageState extends State<ServiceNotAvailablePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.serviceNotAvailable),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.serviceNotAvailable,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Action when the "Reload" button is pressed.

                    RestartWidget.restartApp(context);
                  },
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    AppLocalizations.of(context)!.reload,
                    style: TextStyle(color: Colors.white)
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Action when pressing the "Exit" button

                    final db = AppDb();
                    db.delete(db.modelUser).go();
                    db.delete(db.modelSettings).go();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  icon: Icon(Icons.exit_to_app, color: Colors.white,),
                  label: Text(
                    AppLocalizations.of(context)!.signOut,
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
