import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/auth/presentation/login_screen.dart';
import 'package:mtu_connect_hub/features/auth/presentation/sign_in_options.dart';
import 'package:mtu_connect_hub/features/widgets/components/floating_icon.dart';
import 'package:mtu_connect_hub/features/widgets/components/custom_button.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  double icon1Top = 150;
  double icon2Top = 250;
  double icon3Bottom = 220;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0, end: 2).animate(_controller);

    _controller.forward();

    // Floating animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        icon1Top = 130;
        icon2Top = 270;
        icon3Bottom = 200;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 60, 71), // Dark theme background
      body: Stack(
        children: [
          // Background Animated Floating Icons
          AnimatedPositioned(
            duration: const Duration(seconds: 3),
            top: icon1Top,
            left: 30,
            child: floatingIcon('assets/angry_to_happy.png', 70), // Using reusable component
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 4),
            top: icon2Top,
            right: 50,
            child: floatingIcon('assets/user_icon.png', 90), // Using reusable component
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            bottom: icon3Bottom,
            left: 60,
            child: floatingIcon('assets/complaints_box.png', 100), // Using reusable component
          ),

          // Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 2.5),

                  // App Title with Gradient Effect
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.blueAccent, Colors.white],
                    ).createShader(bounds),
                    child: Text(
                      'MTU ConnectHub',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Tagline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Make your complaints heard with\n"Virtual Complaint Box"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins( 
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // Buttonsr
                  customButton(text: "Get started", color: Colors.blueAccent, 
                  onPressed: () {
                    // Navigate to Registration Screen
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SingInOptions()));
                  }),

                  const SizedBox(height: 25),

                  customButton(text: "I have an account", color: Colors.grey, onPressed: () {
                    // Navigate to Login Screen
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
