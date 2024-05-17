import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/view/components/text.dart';
import 'package:mindfulguard/view/main/main_page.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Localization.getLocale(), // Fetch locale asynchronously
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          // Once the locale data is available, use it to set up the app
          return FutureBuilder<String>(
            future: TextFontFamily().init(), // Fetch font family asynchronously
            builder: (BuildContext context, AsyncSnapshot<String> fontSnapshot) {
              if (fontSnapshot.hasData) {
                // Once the font family data is available, use it to set up the app
                return MaterialApp(
                  theme: ThemeData(
                    textTheme: GoogleFonts.getTextTheme(fontSnapshot.data!)
                  ),
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
                return Container(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Center(
                    child: CircularProgressIndicator(),
                  )
                );
              }
            },
          );
        } else {
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
