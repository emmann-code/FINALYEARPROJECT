import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtu_connect_hub/features/home/presentation/mainscreen.dart';
import 'package:mtu_connect_hub/features/auth/presentation/register_screen.dart';
import 'package:mtu_connect_hub/features/widgets/components/animated_text.dart';
import 'package:mtu_connect_hub/features/widgets/components/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

    bool isLoading = false;

  void signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password.")),
      );
      return;
    }

     setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please verify your email before logging in.")),
          );
          await user.sendEmailVerification();
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }  finally {
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
              SizedBox(height: MediaQuery.of(context).size.height / 6),
              Center(
                child: Text(
                  'Mtu ConnectHub',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Colors.blueAccent, Colors.white],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text('E-mail address'),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: 'seti@gmail.com',
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 20),
              const Text('Password'),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: '************',
                obscureText: true,
                controller: passwordController,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(text: "Login", onPressed: signIn),
              const SizedBox(height: 10),
              const Center(child: Text("Don't have an account?")),
              CustomButton(
                text: 'Sign Up',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
