// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/auth/presentation/register_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SingInOptions extends ConsumerStatefulWidget {
  const SingInOptions({super.key});

  @override
  ConsumerState<SingInOptions> createState() => _SingInOptionsState();
}

class _SingInOptionsState extends ConsumerState<SingInOptions>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _slideController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 102, 90, 90),
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade800,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                SizedBox(height: 40),

                // Header Section
                FadeTransition(
                  opacity: _fadeAnimation,
          child: Column(
            children: [
                      // App Logo/Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.2),
                              Colors.blueAccent.withOpacity(0.1),
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

                      // App Title
              Text(
                        "MTU CONNECT HUB",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                          fontWeight: FontWeight.w700,
                  color: Colors.white,
                          letterSpacing: 1.5,
                  shadows: [
                            Shadow(
                                blurRadius: 15,
                                color: Colors.blueAccent.withOpacity(0.6),
                                offset: Offset(0, 4))
                          ],
                        ),
                      ),

                      SizedBox(height: 15),

                      // Subtitle
                      Text(
                        "Choose your preferred sign-up method",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),

                SizedBox(height: 50),

                // Sign-up Options
                SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Social Sign-up Options
                      _buildSocialButton(
                icon: Icons.apple,
                        text: "Continue with Apple",
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Apple Sign-up coming soon'),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                  );
                },
              ),

                      SizedBox(height: 16),

                      _buildSocialButton(
                icon: Icons.g_mobiledata,
                        text: "Continue with Google",
                        backgroundColor: Colors.white,
                        textColor: Colors.black87,
                        iconColor: Colors.black87,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google Sign-up coming soon'),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                  );
                },
              ),

                      SizedBox(height: 16),

                      _buildSocialButton(
                icon: Icons.facebook,
                        text: "Continue with Facebook",
                        backgroundColor: Color(0xFF1877F2),
                        textColor: Colors.white,
                        iconColor: Colors.white,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Facebook Sign-up coming soon'),
                              backgroundColor: Colors.blueAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                  );
                },
              ),

                      SizedBox(height: 30),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: Colors.white.withOpacity(0.3),
                                  thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "or",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.white.withOpacity(0.3),
                                  thickness: 1)),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Email Sign-up Option
                      _buildSocialButton(
                        icon: Icons.email_outlined,
                        text: "Sign up with Email",
                        backgroundColor: Colors.transparent,
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.3),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                              builder: (context) => Consumer(
                                    builder: (context, ref, child) =>
                                        const SignUpScreen(),
                                  )),
                ),
              ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Terms and Privacy
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "By continuing, you agree to our Terms of Service and Privacy Policy. We may send you notifications about our services.",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                textAlign: TextAlign.center,
              ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : null,
        boxShadow: backgroundColor != Colors.transparent
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 24),
                SizedBox(width: 12),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmailSignUpPage extends StatelessWidget {
  const EmailSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Email Sign Up")),
      body: const Center(child: Text("Email Sign Up Page")),
    );
  }
}
