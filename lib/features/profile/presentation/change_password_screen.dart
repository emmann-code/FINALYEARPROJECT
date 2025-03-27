import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _isLoading = false;
        _errorMessage = "New passwords do not match!";
      });
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );

        // Reauthenticate user
        await user.reauthenticateWithCredential(credential);

        // Change password
        await user.updatePassword(_newPasswordController.text);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Incorrect old password or an error occurred!";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
            const SizedBox(height: 10),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
