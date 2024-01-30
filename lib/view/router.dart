import 'package:flutter/material.dart';
import 'package:mindfulguard/view/sign_in_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Routes Example',
      initialRoute: '/sign_in',
      routes: {
        '/sign_in': (context) => SignInPage(),
      },
    );
  }
}