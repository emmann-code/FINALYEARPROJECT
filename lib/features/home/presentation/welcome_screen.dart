// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/auth/presentation/login_screen.dart';
import 'package:mtu_connect_hub/features/auth/presentation/sign_in_options.dart';
import 'package:mtu_connect_hub/features/widgets/components/floating_icon.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  double icon1Top = 150;
  double icon2Top = 250;
  double icon3Bottom = 220;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _slideController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    // Start animations in sequence
    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(Duration(milliseconds: 600), () {
      _scaleController.forward();
    });

    // Floating animation for background icons
    Future.delayed(Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          icon1Top = 130;
          icon2Top = 270;
          icon3Bottom = 200;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Animated Floating Icons with reduced opacity
            AnimatedPositioned(
              duration: Duration(seconds: 3),
              top: icon1Top,
              left: 30,
              child: Opacity(
                opacity: 0.3,
                child: floatingIcon('assets/angry_to_happy.png', 60),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 4),
              top: icon2Top,
              right: 50,
              child: Opacity(
                opacity: 0.25,
                child: floatingIcon('assets/user_icon.png', 80),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 5),
              bottom: icon3Bottom,
              left: 60,
              child: Opacity(
                opacity: 0.2,
                child: floatingIcon('assets/complaints_box.png', 90),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top section with logo and branding
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // MTU Logo placeholder
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blueAccent.withOpacity(0.1),
                                      Colors.blueAccent.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: 50,
                                  color: Colors.blueAccent,
                                ),
                              ),

                              SizedBox(height: 30),

                              // App Title with enhanced gradient
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.blue.shade600,
                                    const Color.fromARGB(255, 206, 171, 171),
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                ).createShader(bounds),
                                child: Text(
                                  'MTU CONNECT HUB',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),

                              SizedBox(height: 15),

                              // Enhanced tagline
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Empowering students with a seamless\ncomplaint management system',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                              ?.withOpacity(0.8) ??
                                          Colors.white70,
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 25),

                              // Feature highlights
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildFeatureItem(
                                          Icons.security, 'Secure'),
                                      _buildFeatureItem(Icons.speed, 'Fast'),
                                      _buildFeatureItem(
                                          Icons.support_agent, '24/7 Support'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom section with buttons
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Primary CTA Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.blue.shade600
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SingInOptions()));
                                },
                                child: Center(
                                  child: Text(
                                    "Get Started",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 15),

                          // Secondary Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withOpacity(0.3) ??
                                    Colors.white30,
                                width: 1.5,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()));
                                },
                                child: Center(
                                  child: Text(
                                    "I have an account",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color ??
                                          Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 15),

                          // Version info
                          Text(
                            "Version 1.0.0",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withOpacity(0.5) ??
                                  Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: 20,
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color
                    ?.withOpacity(0.7) ??
                Colors.white70,
          ),
        ),
      ],
    );
  }
}
