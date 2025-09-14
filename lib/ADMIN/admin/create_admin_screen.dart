// ignore_for_file: curly_braces_in_flow_control_structures, use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({Key? key}) : super(key: key);

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedOffice;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _offices = [
    'Academic Advisory',
    'Cafeteria',
    'Chapel',
    'College',
    'Department',
    'Finance',
    'Healthcare',
    'Hostel',
    'IT Support',
    'Library',
    'Student Affairs',
    'Technical Support',
  ];

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final office = _selectedOffice;

    setState(() => _isLoading = true);

    try {
      UserCredential cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'email': email,
        'role': 'Admin',
        'office': office,
        'disabled': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _showSnackBar('Admin created successfully!', Colors.green);
      _formKey.currentState!.reset();
      _emailController.clear();
      _passwordController.clear();
      setState(() => _selectedOffice = null);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Error creating admin.', Colors.red);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Admin'),
        backgroundColor: isDarkMode ? const Color(0xFF181A20) : Colors.blue,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: isDarkMode ? const Color(0xFF232526) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.blue.shade800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fill in the details below to create a new admin account.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      enabled: true,
                      autofocus: false,
                      readOnly: false,
                      decoration: InputDecoration(
                        labelText: 'Admin Email',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: Colors.blue.shade600),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDarkMode
                            ? const Color(0xFF2D2D2D)
                            : Colors.grey.shade50,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Email is required';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(val.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: true,
                      autofocus: false,
                      readOnly: false,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Colors.blue.shade600),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blue.shade600,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDarkMode
                            ? const Color(0xFF2D2D2D)
                            : Colors.grey.shade50,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'Password is required';
                        if (val.trim().length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    // Office Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedOffice,
                      items: _offices
                          .map((office) => DropdownMenuItem(
                                value: office,
                                child: Text(office),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedOffice = val),
                      decoration: InputDecoration(
                        labelText: 'Select Office',
                        prefixIcon:
                            Icon(Icons.business, color: Colors.blue.shade600),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDarkMode
                            ? const Color(0xFF2D2D2D)
                            : Colors.grey.shade50,
                      ),
                      validator: (val) =>
                          val == null ? 'Please select an office' : null,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Colors.blue.shade700,
                        ),
                        onPressed: _isLoading ? null : _createAdmin,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Create Admin',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
