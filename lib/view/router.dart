import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mindfulguard/db/database.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/view/main/main_page.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Localization.getLocale(), // Fetch locale asynchronously
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          // Once the locale data is available, use it to set up the app
          return MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale(snapshot.data!), // Set locale using snapshot data
            ],
            title: 'Routes',
            initialRoute: '/main_page',
            routes: {
              '/main_page': (context) => MainPage(),
              '/sign_in': (context) => SignInPage(),
            },
          );
        } else {
          // Display a loading indicator or fallback while waiting for locale
          return Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Center(
              child: CircularProgressIndicator(),
            )
          );
        }
      },
    );
  }
}
