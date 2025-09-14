// ignore_for_file: unused_local_variable, camel_case_types, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/auth/presentation/sign_in_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mtu_connect_hub/features/profile/presentation/change_password_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);
  void toggle(bool value) => state = value;
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, bool>((ref) => ThemeNotifier());

class profilesettings extends ConsumerStatefulWidget {
  profilesettings({super.key});

  @override
  _profilesettingsState createState() => _profilesettingsState();
}

class _profilesettingsState extends ConsumerState<profilesettings>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  String? _matricNumber;
  String? _profileImageUrl;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _themeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _themeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _user = _auth.currentUser;
    _fetchUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _slideController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _themeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));
    _themeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _themeController, curve: Curves.easeInOut));

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
  if (_user != null) {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          if (mounted) {
          setState(() {
            _matricNumber = userData['matric'] ?? 'No Matric Number';
            _profileImageUrl = userData['profileImageUrl'];
          });
        }
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _isLoading = true;
      });

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
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profile picture updated successfully!"),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile picture"),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    final isDarkMode = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.blue.shade600),
                  ),
                  title: Text(
                    "Take a Photo",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.grey.shade200
                          : Colors.grey.shade800,
                    ),
                  ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.photo_library, color: Colors.green.shade600),
                  ),
                  title: Text(
                    "Choose from Gallery",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.grey.shade200
                          : Colors.grey.shade800,
                    ),
                  ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
                SizedBox(height: 20),
            ],
            ),
          ),
        );
      },
    );
  }

  void _toggleDarkMode(bool value) {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Animate the theme change
    _themeController.forward().then((_) {
      _themeController.reverse();
    });

    // Update the theme
    ref.read(themeProvider.notifier).toggle(value);

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? "Dark mode enabled" : "Light mode enabled",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: value ? Colors.grey.shade800 : Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _logout() async {
    final isDarkMode = ref.read(themeProvider);
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
    await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SingInOptions()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.grey.shade50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                  _buildProfileHeader(isDarkMode),
                  SizedBox(height: 32),
                  _buildSettingsOptions(isDarkMode),
            SizedBox(height: 20),
          ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.blue.shade800,
                  Colors.blue.shade900,
                ]
              : [
                  Colors.blue.shade600,
                  Colors.blue.shade800,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(isDarkMode ? 0.4 : 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 3),
                ),
                child: CircleAvatar(
              radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!) as ImageProvider
                      : AssetImage('assets/user_icon.png'),
                ),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                  onTap: _isLoading ? null : _showImagePickerOptions,
                child: Container(
                    padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                    shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                ),
              ),
            ),
          ],
        ),
          SizedBox(height: 16),
        Text(
          _matricNumber ?? 'Admin',
          style: GoogleFonts.poppins(
            fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
        Text(
          _user?.email ?? 'complaintadmin@gmail.com',
         style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Student Account',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildSettingsOptions(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Settings Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
        children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.settings, color: Colors.blue.shade600, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "Account Settings",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _buildSettingsSection([
          _buildOptionTile(
            Icons.lock_outline,
            'Change Password',
            'Update your account password',
            () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
            );
            },
            isDarkMode,
          ),
          _buildThemeToggleTile(isDarkMode),
        ], isDarkMode),
        SizedBox(height: 24),

        // Support & Help Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.support_agent,
                    color: Colors.green.shade600, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                "Support & Help",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _buildSettingsSection([
          _buildOptionTile(
            Icons.info_outline,
            'About',
            'Learn more about MTU Connect-Hub',
            () => _showAboutDialog(isDarkMode),
            isDarkMode,
          ),
          _buildOptionTile(
            Icons.help_outline,
            'Help',
            'Get assistance and support',
            () => _showHelpDialog(isDarkMode),
            isDarkMode,
          ),
          _buildOptionTile(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'View our privacy policies',
            () => _showPrivacyDialog(isDarkMode),
            isDarkMode,
          ),
          _buildOptionTile(
            Icons.report_problem_outlined,
            'Report Problem',
            'Report issues or bugs',
            () => _showReportDialog(isDarkMode),
            isDarkMode,
          ),
        ], isDarkMode),
        SizedBox(height: 24),
        _buildLogoutTile(isDarkMode),
      ],
    );
  }

  Widget _buildSettingsSection(List<Widget> children, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle,
      VoidCallback onTap, bool isDarkMode) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue.shade600, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeToggleTile(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _themeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_themeAnimation.value * 0.05),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF2A2A2A) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.orange.shade900.withOpacity(0.3)
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
              ),
              title: Text(
                'Dark Mode',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              trailing: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isDarkMode
                      ? Colors.orange.shade600
                      : Colors.grey.shade300,
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 200),
                      left: isDarkMode ? 22 : 2,
                      top: 2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          size: 14,
                          color: isDarkMode
                              ? Colors.orange.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () => _toggleDarkMode(!isDarkMode),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutTile(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.logout, color: Colors.red.shade600, size: 20),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red.shade600,
          ),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        onTap: _logout,
      ),
    );
  }

  void _showAboutDialog(bool isDarkMode) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'About MTU Connect-Hub',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        content: Text(
          'MTU Connect-Hub is a comprehensive student support and complaint management platform for MTU. Easily submit, track, and resolve issues related to academics, hostels, and campus life.',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        content: Text(
          'For assistance, contact your department or use the chatbot in the Virtual Hub. You can also email support@mtuconnect.com for technical support.',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        content: Text(
          'Your data is securely stored and only used for complaint resolution and student support. We do not share your personal information with third parties.',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Report a Problem',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        content: Text(
          'Describe any issues you face in the app or with MTU services. Our team will address them promptly.',
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.blue.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
