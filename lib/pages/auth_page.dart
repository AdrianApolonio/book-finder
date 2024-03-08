import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'search_page.dart';
import 'signin_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return const SearchPage();
        }
        return const SignInPage();
      },
    ));
  }
}
