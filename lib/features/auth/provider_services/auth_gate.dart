import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtu_connect_hub/features/home/presentation/mainscreen.dart';
import 'package:mtu_connect_hub/features/home/presentation/welcome_screen.dart';
import 'package:mtu_connect_hub/ADMIN/admin/dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _getUserRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return FutureBuilder<String?>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final role = roleSnapshot.data;
                if (role == 'Admin' || role == 'SuperAdmin') {
                  return const AdminDashboard();
                } else {
                  return const MainScreen();
                }
              },
            );
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
