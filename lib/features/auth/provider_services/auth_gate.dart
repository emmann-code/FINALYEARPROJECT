import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtu_connect_hub/features/home/presentation/mainscreen.dart';
import 'package:mtu_connect_hub/features/home/presentation/welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            // User is signed in, go to home page
            return MainScreen();
          } else {
            // User is not signed in, go to login screen
            return WelcomeScreen();
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
