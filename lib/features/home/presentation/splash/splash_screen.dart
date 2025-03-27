import 'package:flutter/material.dart';
import 'package:mtu_connect_hub/features/auth/provider_services/auth_gate.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateTowelcome();
  }

  _navigateTowelcome() async {
    await Future.delayed(const Duration(seconds: 5), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()), // Navigate to your home page
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashScreenUI(),
    );
  }
}
