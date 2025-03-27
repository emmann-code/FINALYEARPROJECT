import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtu_connect_hub/features/auth/presentation/login_screen.dart';
import 'package:mtu_connect_hub/features/auth/provider_services/auth_service.dart';
import 'package:mtu_connect_hub/features/widgets/components/animated_text.dart';
import 'package:mtu_connect_hub/features/widgets/components/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController matricController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  bool isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  void signUp() async {
    String matric = matricController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (matric.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format.")),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 8 characters")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      User? user = await _authService.signUp(email, password, matric);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification email sent. Please verify your email before logging in.")),
        );

        await Future.delayed(const Duration(seconds: 4));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up failed. Please try again.")),
        );
      }
    } catch (e) {
      print("Error signing up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 8),
              const Center(
                child: Text(
                  'Mtu ConnectHub',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Matric Number'),
              const SizedBox(height: 10),
              CustomTextField(hintText: '1010010011', obscureText: false, controller: matricController),
              const SizedBox(height: 10),
              const Text('E-mail address'),
              const SizedBox(height: 10),
              CustomTextField(hintText: 'seti@gmail.com', obscureText: false, controller: emailController),
              const SizedBox(height: 10),
              const Text('Password'),
              const SizedBox(height: 10),
              CustomTextField(hintText: '************', obscureText: true, controller: passwordController),
              const SizedBox(height: 10),
              const Text('Confirm Password'),
              const SizedBox(height: 10),
              CustomTextField(hintText: '************', obscureText: true, controller: confirmPasswordController),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(text: "Sign Up it's free!", onPressed: signUp),
              const SizedBox(height: 10),
              const Center(child: Text('Do you already have an account?')),
              CustomButton(text: 'Sign In', onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }, isPrimary: false),
            ],
          ),
        ),
      ),
    );
  }
}
