import 'package:flutter/material.dart';
import 'package:mtu_connect_hub/features/home/presentation/dashboard/dashboard.dart';
import 'package:mtu_connect_hub/features/home/presentation/historynavbar/history_page.dart';
import 'package:mtu_connect_hub/features/home/presentation/spybox/my_spybox.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:mtu_connect_hub/features/widgets/bottom_navbar.dart';
import 'package:mtu_connect_hub/features/home/presentation/home_page.dart';
// Import the custom nav bar

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to HomeScreen

  // Function to update the selected tab from outside the bottom nav
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToGallery() {
    setState(() {
      _selectedIndex = 2; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      body: _getSelectedScreen(),
      bottomNavigationBar: custombottomnavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Define the pages for each bottom navigation item
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return Homepage();
      case 1:
        return DashboardPage();
        //  Page();
        // DashboardPage();
      case 2: 
        return Spyboxpage();
      case 3: 
        return HistoryScreen();
     default:
        return  profilesettings();
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