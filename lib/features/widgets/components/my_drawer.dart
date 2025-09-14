// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_unnecessary_containers, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtu_connect_hub/features/home/presentation/mainscreen.dart';
import 'package:mtu_connect_hub/features/home/presentation/blog_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtu_connect_hub/features/auth/presentation/login_screen.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';

// --- MAIN DRAWER WIDGET ---
/// The main navigation drawer for the app, providing quick access to
/// main sections, tools, and account actions.
class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final user = FirebaseAuth.instance.currentUser;
    final String userName =
        user?.displayName ?? (user?.email?.split('@').first ?? 'Guest');
    final String userEmail = user?.email ?? 'No email available';
    final Color headerColor = isDarkMode
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).primaryColor;

    return Drawer(
      elevation: 8,
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          // --- HEADER ---
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: headerColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 32.0, left: 16, right: 16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.transparent, // for spacing only
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 70,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: AssetImage('assets/avatar.jpg'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 54),
          // --- USER INFO ---
          Text(
            userName,
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            userEmail,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          // --- MENU ITEMS ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerTile(
                  context,
                  text: 'Home',
                  icon: Icons.home_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerTile(
                  context,
                  text: 'Blog',
                  icon: Icons.article_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BlogPage()),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerTile(
                  context,
                  text: 'Notifications',
                  icon: Icons.notifications_rounded,
                  onTap: () => _showFeatureComingSoon(context, 'Notifications'),
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerTile(
                  context,
                  text: 'Insights',
                  icon: Icons.insights_rounded,
                  onTap: () => _showFeatureComingSoon(context, 'Insights'),
                  isDarkMode: isDarkMode,
                ),
                _buildDrawerTile(
                  context,
                  text: 'Scan Me',
                  icon: Icons.qr_code_scanner_rounded,
                  onTap: () => _showFeatureComingSoon(context, 'Scan Me'),
                  isDarkMode: isDarkMode,
                ),
                Divider(
                  height: 28,
                  thickness: 1.1,
                  indent: 24,
                  endIndent: 24,
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                _buildDrawerTile(
                  context,
                  text: 'Settings',
                  icon: Icons.settings_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => profilesettings()),
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
          // --- LOGOUT & VERSION ---
          Divider(
            height: 18,
            thickness: 1.1,
            indent: 24,
            endIndent: 24,
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          _buildLogoutSection(context, isDarkMode),
          _buildVersionInfo(isDarkMode),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // --- DRAWER TILE ---
  Widget _buildDrawerTile(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
          onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
      splashColor: isDarkMode
          ? Colors.blue.shade900.withOpacity(0.15)
          : Colors.blue.shade100.withOpacity(0.18),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: ListTile(
          leading: Icon(
                    icon,
            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
                  ),
          title: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          trailing: null,
        ),
      ),
    );
  }

  // --- LOGOUT SECTION ---
  /// Builds the logout button at the bottom of the drawer.
  Widget _buildLogoutSection(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode
            ? Colors.red.shade900.withOpacity(0.2)
            : Colors.red.shade50,
        border: Border.all(
          color: isDarkMode
              ? Colors.red.shade800.withOpacity(0.3)
              : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Sign out and navigate to login
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- VERSION INFO ---
  /// Displays the app version at the bottom of the drawer.
  Widget _buildVersionInfo(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            "Version 1.0.1",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // --- UTILITY: FEATURE COMING SOON ---
  /// Shows a snackbar for features that are not yet implemented.
  void _showFeatureComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }
}
