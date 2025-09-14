// ignore_for_file: use_build_context_synchronously, deprecated_member_use, prefer_interpolation_to_compose_strings, control_flow_in_finally, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/home/presentation/mainscreen.dart';
import 'package:mtu_connect_hub/features/auth/presentation/register_screen.dart';
import 'package:mtu_connect_hub/ADMIN/admin/dashboard.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminInfo {
  final String role;
  final String? office;
  AdminInfo({required this.role, this.office});
}

final adminInfoProvider = StateProvider<AdminInfo?>((ref) => null);

/// LoginScreen: Handles user authentication and login UI
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // --- Controllers & State ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _isDisposed = false; // Add disposal flag

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void dispose() {
    _isDisposed = true; // Set disposal flag
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- Animation Setup ---
  void _initAnimations() {
    if (_isDisposed) return; // Check if disposed

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Add defensive checks before starting animations
    if (!_isDisposed && mounted) {
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_isDisposed && mounted) {
          _slideController.forward();
        }
      });
    }
  }

  // --- Validation ---
  bool _validateInputs() {
    if (_isDisposed) return false; // Check if disposed

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(
          "Please enter both email and password.", Colors.red.shade400);
      return false;
    }
    if (!_isValidEmail(email)) {
      _showSnackBar("Invalid email format.", Colors.red.shade400);
      return false;
    }
    if (password.length < 6) {
      _showSnackBar(
          "Password must be at least 6 characters.", Colors.red.shade400);
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    return emailRegex.hasMatch(email);
  }

  // --- SnackBar Helper ---
  void _showSnackBar(String message, Color color) {
    if (_isDisposed || !mounted) return; // Check if disposed or not mounted

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // --- Sign In Logic ---
  Future<void> signIn() async {
    if (_isDisposed) return; // Check if disposed

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (!_validateInputs()) return;

    // --- SuperAdmin Hardcoded Check ---

    // --- Normal User Login ---
    if (!_isDisposed && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (_isDisposed) return; // Check again after async operation

      User? user = userCredential.user;
      if (user != null) {
        // Check if user is disabled in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (_isDisposed) return; // Check after Firestore operation

        final userData = userDoc.data();
        if (userData != null && userData['disabled'] == true) {
          await _auth.signOut();
          _showSnackBar(
              "Your account has been disabled. Please contact admin for support.",
              Colors.red.shade400);
          return;
        }

        // Set admin info provider for access control
        if (userData != null) {
          ref.read(adminInfoProvider.notifier).state = AdminInfo(
            role: userData['role'] ?? '',
            office: userData['office'],
          );
        }

        // --- Admin/SuperAdmin Routing (No email verification required) ---
        if (userData != null &&
            (userData['role'] == 'Admin' || userData['role'] == 'SuperAdmin')) {
          if (!_isDisposed && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          }
          return; // Exit early - no email verification needed for admins
        }

        // --- Regular User: Require Email Verification ---
        if (user.emailVerified) {
          if (!_isDisposed && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        } else {
          _showSnackBar("Please verify your email before logging in.",
              Colors.orange.shade400);
          await user.sendEmailVerification();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (_isDisposed) return; // Check after exception

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password. Try again.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'user-disabled':
          errorMessage = "This user account has been disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many attempts. Please try again later.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled.";
          break;
        default:
          errorMessage = e.message ?? "An error occurred. Please try again.";
      }
      _showSnackBar(errorMessage, Colors.red.shade400);
    } catch (e) {
      if (_isDisposed) return; // Check after general exception
      _showSnackBar("Error: " + e.toString(), Colors.red.shade400);
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    if (_isDisposed)
      return const SizedBox.shrink(); // Return empty widget if disposed

    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF121212),
                    const Color(0xFF1A1A1A)
                  ]
                : [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // --- Header Section ---
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // App Logo
                      const SizedBox(height: 30),
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blueAccent,
                                Colors.blue,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // App Title
                      Center(
                        child: Text(
                          'MTU CONNECT HUB',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.blue.shade700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      Center(
                        child: Text(
                          'Welcome back',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // --- Form Section ---
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form Title
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        _buildModernFormField(
                          label: 'Email Address',
                          hint: 'Enter your email address',
                          controller: emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        _buildModernPasswordField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          onToggle: () {
                            if (!_isDisposed && mounted) {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            }
                          },
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 30),
                        // Login Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade500,
                                Colors.blue.shade700,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: isLoading || _isDisposed ? null : signIn,
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "Sign In",
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
                        const SizedBox(height: 30),
                        // Sign Up Link
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Don't have an account?",
                                style: GoogleFonts.poppins(
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Consumer(
                                        builder: (context, ref, child) =>
                                            const SignUpScreen(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    "Sign Up",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Modern Form Field ---
  Widget _buildModernFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required bool isDarkMode,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: Colors.blue.shade600, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              filled: false,
            ),
            cursorColor: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  // --- Modern Password Field ---
  Widget _buildModernPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Colors.blue,
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.blue.shade600,
                  size: 22,
                ),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              filled: false,
            ),
            cursorColor: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }
}
