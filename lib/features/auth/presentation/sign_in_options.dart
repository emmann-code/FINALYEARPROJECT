import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/auth/presentation/register_screen.dart';

class SingInOptions extends StatefulWidget {
  const SingInOptions({super.key});

  @override
  State<SingInOptions> createState() => _SingInOptionsState();
}

class _SingInOptionsState extends State<SingInOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 102, 90, 90), Colors.deepPurple.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Mtu ConnectHub",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(blurRadius: 10, color: Colors.blueAccent, offset: Offset(2, 2))
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SocialButton(
                icon: Icons.apple,
                text: "Sign up with Apple",
                color: Colors.black,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppleSignUpPage()),
                ),
              ),
              SocialButton(
                icon: Icons.g_mobiledata,
                text: "Sign up with Google",
                color: Colors.white,
                textColor: Colors.black,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoogleSignUpPage()),
                ),
              ),
              SocialButton(
                icon: Icons.facebook,
                text: "Sign up with Facebook",
                color: Colors.blue.shade300,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FacebookSignUpPage()),
                ),
              ),
              const SizedBox(height: 10),
              const Text("or", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              SocialButton(
                icon: Icons.email,
                text: "Sign up with E-mail",
                color: Colors.grey.shade700,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  const SignUpScreen()
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "By registering, you agree to our Terms of Use.\nLearn how we collect, use and share your data.",
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
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

  const SocialButton({super.key, 
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

// Dummy Pages for Each Sign-Up Option
class AppleSignUpPage extends StatelessWidget {
  const AppleSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apple Sign Up")),
      body: const Center(child: Text("Apple Sign Up Page")),
    );
  }
}

class GoogleSignUpPage extends StatelessWidget {
  const GoogleSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Sign Up")),
      body: const Center(child: Text("Google Sign Up Page")),
    );
  }
}

class FacebookSignUpPage extends StatelessWidget {
  const FacebookSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Facebook Sign Up")),
      body: const Center(child: Text("Facebook Sign Up Page")),
    );
  }
}

class EmailSignUpPage extends StatelessWidget {
  const EmailSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Sign Up")),
      body: const Center(child: Text("Email Sign Up Page")),
    );
  }
}
