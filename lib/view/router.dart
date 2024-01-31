import 'package:flutter/material.dart';
import 'package:mindfulguard/view/main/main_page.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routes',
      initialRoute: '/main_page',
      routes: {
        '/main_page': (context) => MainPage(),
        '/sign_in': (context) => SignInPage(),
      },
    );
  }
}