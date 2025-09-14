// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtu_connect_hub/features/home/presentation/dashboard/dashboard.dart';
import 'package:mtu_connect_hub/features/home/presentation/historynavbar/history_page.dart';
import 'package:mtu_connect_hub/features/home/presentation/spybox/my_spybox.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:mtu_connect_hub/features/widgets/bottom_navbar.dart';
import 'package:mtu_connect_hub/features/home/presentation/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mtu_connect_hub/features/auth/presentation/login_screen.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
// Import the custom nav bar

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0; // Default to HomeScreen

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userDocStream;
  User? _currentUser;
  bool _isDisposed = false; // Add disposal flag

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;

  void _handleDrawerChanged(bool isOpened) {
    if (!_isDisposed && mounted) {
      setState(() {
        _isDrawerOpen = isOpened;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _userDocStream = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .snapshots();
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Set disposal flag
    super.dispose();
  }

  // Function to update the selected tab from outside the bottom nav
  void _onItemTapped(int index) {
    if (!_isDisposed && mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void navigateToGallery() {
    if (!_isDisposed && mounted) {
      setState(() {
        _selectedIndex = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed)
      return const SizedBox.shrink(); // Return empty widget if disposed

    if (_userDocStream != null) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userDocStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data()?['disabled'] == true) {
            // Log out and show dialog
            Future.microtask(() async {
              await FirebaseAuth.instance.signOut();
              if (!_isDisposed && mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    title: const Text('Account Disabled'),
                    content: const Text(
                        'Your account has been disabled. Please contact admin for support.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          if (!_isDisposed && mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            });
            return const SizedBox.shrink();
          }
          return _buildMainScaffold(context);
        },
      );
    }
    return _buildMainScaffold(context);
  }

  Widget _buildMainScaffold(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const MyDrawer(),
      onDrawerChanged: _handleDrawerChanged,
      body: _getSelectedScreen(),
      bottomNavigationBar: _isDrawerOpen
          ? null
          : CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
    );
  }

  // Define the pages for each bottom navigation item
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return Consumer(
          builder: (context, ref, child) => Homepage(),
        );
      case 1:
        return DashboardPage();
      //  Page();
      // DashboardPage();
      case 2:
        return Spyboxpage();
      case 3:
        return HistoryScreen();
      default:
        return profilesettings();
    }
  }
}

// Dummy Pages for Each Sign-Up Option
class AppleSignUpPage extends StatelessWidget {
  const AppleSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("Apple Sign Up Page")),
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("Apple Sign Up Page")),
    );
  }
}
