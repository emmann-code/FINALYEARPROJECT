import 'dart:io';
import 'package:mtu_connect_hub/features/auth/presentation/sign_in_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mtu_connect_hub/features/profile/presentation/change_password_screen.dart';

class profilesettings extends StatefulWidget {
  const profilesettings({super.key});

  @override
  _profilesettingsState createState() => _profilesettingsState();
}

class _profilesettingsState extends State<profilesettings> {
  bool isDarkMode = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  String? _matricNumber;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
  if (_user != null) {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists && userDoc.data() != null) {  // ✅ Ensure data() is not null
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (mounted) {  // ✅ Prevent updating if widget is disposed
          setState(() {
            _matricNumber = userData['matric'] ?? 'No Matric Number';
            _profileImageUrl = userData['profileImageUrl'];
          });
        }
      } else {
        print("⚠️ User document does not exist or has no data.");
      }
    } catch (e) {
      print("🔥 Error fetching user data: $e");
    }
  }
}


  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String fileName = 'profile_pics/${_user!.uid}.jpg';

      try {
        // Upload to Firebase Storage
        TaskSnapshot uploadTask =
            await _storage.ref(fileName).putFile(imageFile);
        String downloadUrl = await uploadTask.ref.getDownloadURL();

        // Update Firestore with new image URL
        await _firestore.collection('users').doc(_user!.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile picture: $e")),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SingInOptions()));
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => SignInOption()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? Colors.black : const Color.fromARGB(255, 46, 44, 53),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildSettingsOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!) as ImageProvider
                  : const AssetImage('assets/profile.png'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _matricNumber ?? 'Loading...',
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          _user?.email ?? 'No Email Found',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildOptionTile(Icons.lock, 'Change Password', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
            );
          }),
          _buildToggleTile(Icons.nightlight_round, 'Dark Mode', isDarkMode, _toggleDarkMode),
          _buildOptionTile(Icons.help, 'Help', () {}),
          _buildOptionTile(Icons.policy, 'Policies', () {}),
          _buildOptionTile(Icons.report, 'Report Problem', () {}),
          _buildLogoutTile(),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      leading: const Icon(Icons.exit_to_app, color: Colors.red),
      title: const Text('Logout', style: TextStyle(color: Colors.red)),
      onTap: _logout,
    );
  }
}
