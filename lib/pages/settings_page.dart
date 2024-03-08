import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void popPage(BuildContext context) {
    Navigator.pop(context);
  }

  Future signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () => popPage(context),
                    icon: const Icon(Icons.arrow_back)),
              ),
            ],
          ),
          TextButton(
              child: const Text("Sign Out"), onPressed: () => signOut(context))
        ],
      ),
    )));
  }
}
