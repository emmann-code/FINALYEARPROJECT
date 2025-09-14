// ignore_for_file: unused_import, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/academicadv_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/caferteria_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/chapel_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/college_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/department_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/finiance_assistance_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/healthcare_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/hostel_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/it_support_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/libraryhelp_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/student_affairs_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_main_admin/technical_support_office.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_virtual_admin/virtual_hub.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage>
    with TickerProviderStateMixin {
  bool isMainAdmin = true;
  String userEmail = "Guest";
  String displayName = "Guest";

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _slideController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? "Guest";
        displayName = userEmail.split('@').first;
      });
    }
  }

  String _getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good morning, $displayName";
    } else if (hour >= 12 && hour < 17) {
      return "Good afternoon, $displayName";
    } else if (hour >= 17 && hour < 21) {
      return "Good evening, $displayName";
    } else {
      return "Good night, $displayName";
    }
  }

  void _navigateToVirtualHub() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VirtualHubPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Color(0xFF1A1A1A),
                  Color(0xFF121212),
                  Color(0xFF1A1A1A),
                ]
              : [
                  Colors.blue.shade50,
                  Colors.white,
                  Colors.blue.shade50,
                ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBar(
                backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.blue.shade700),
                title: Text(
                  'MTU CONNECT HUB',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                    letterSpacing: 1.0,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blue.shade900.withOpacity(0.3)
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.notifications_outlined,
                          color: Colors.blue.shade700),
                      onPressed: () {
                        // Add notification functionality
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(isDarkMode ? 0.3 : 0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Toggle between Admins to get in touch!',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 20),

                            // Toggle Buttons
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildModernToggleButton(
                                        "Main Admins", isMainAdmin, () {
                                      setState(() {
                                        isMainAdmin = true;
                                      });
                                    }, isDarkMode),
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: _buildModernToggleButton(
                                        "Virtual Admin", !isMainAdmin, () {
                                      setState(() {
                                        isMainAdmin = false;
                                      });
                                    }, isDarkMode),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Content Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: isMainAdmin
                          ? _buildMainAdminGrid(isDarkMode)
                          : _buildVirtualAdminUI(isDarkMode),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernToggleButton(
      String text, bool isActive, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildMainAdminGrid(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: mainAdminOffices.length,
      itemBuilder: (context, index) {
        return _buildModernOfficeCard(
            mainAdminOffices[index], context, isDarkMode);
      },
    );
  }

  Widget _buildVirtualAdminUI(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Virtual Hub Card
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.blue.shade900.withValues(alpha: 0.3)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.feedback_outlined,
                  size: 40,
                  color: Colors.blue.shade600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Virtual Hub',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Submit complaints and voice your concerns',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade500, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _navigateToVirtualHub,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Access Virtual Hub",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Description Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade600, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                "Manage your virtual administrative tasks with ease. Virtual Admin provides an accessible, user-friendly, and secure platform for students to submit complaints and voice their concerns. By using the VIRTUAL Complaint Box, students can contribute to the ongoing improvement of MTU's academic and non-academic environment, ensuring a positive and productive learning experience for all.",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color:
                      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Rules Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.blue.shade900.withValues(alpha: 0.3)
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade200,
                width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.rule_outlined,
                      color: Colors.blue.shade600, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Rules to follow",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                  "Be professional, specific and detailed", isDarkMode),
              _buildRuleItem("Use respectful language", isDarkMode),
              _buildRuleItem("Provide evidence or examples", isDarkMode),
              _buildRuleItem(
                  "Avoid submitting duplicate complaints", isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String rule, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              rule,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOfficeCard(
      String office, BuildContext context, bool isDarkMode) {
    final Map<String, String> officeImages = {
      "Department Office": "assets/department.png",
      "College Office": "assets/college.png",
      "Hostel Office": "assets/hostemain.png",
      "Chapel Office": "assets/chapel.png",
      "Health Care Office": "assets/healthcare.png",
      "Cafeteria Office": "assets/caferteria.png",
      "IT Support": "assets/ICT.png",
      "Library Help": "assets/library.png",
      "Student Affairs": "assets/studentaffairs.png",
      "Finance Assistance": "assets/finiance.png",
      "Academic Advisory": "assets/academicadvise.png",
      "Technical Support": "assets/technicalsupport.png",
    };

    final Map<String, Widget Function()> officePages = {
      "Department Office": () => DepartmentComplaintsPage(),
      "College Office": () => CollegeComplaintsPage(),
      "Hostel Office": () => HostelComplaintsPage(),
      "Chapel Office": () => ChapelComplaintsPage(),
      "Health Care Office": () => HealthcareComplaintsPage(),
      "Cafeteria Office": () => CafeteriaComplaintsPage(),
      "IT Support": () => ITSupportComplaintsPage(),
      "Library Help": () => LibraryHelpComplaintsPage(),
      "Student Affairs": () => StudentAffairsComplaintsPage(),
      "Finance Assistance": () => FinanceComplaintsPage(),
      "Academic Advisory": () => AcademicAdvisoryComplaintsPage(),
      "Technical Support": () => TechnicalSupportComplaintsPage(),
    };

    String imagePath = officeImages[office] ?? "assets/studentaffairs.png";

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (officePages.containsKey(office)) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => officePages[office]!()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Page not found for $office'),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.blue.shade900.withValues(alpha: 0.3)
                        : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  office,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.grey.shade200
                        : Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.blue.shade900.withValues(alpha: 0.5)
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Access",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
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
}

Widget virtualhub(BuildContext context) {
  return Container(
    margin: EdgeInsets.all(10),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ImageIcon(
          AssetImage('assets/complaints_box.png'),
          size: 100.0,
          color: Colors.blueAccent,
        ),
        Text(
          'Virtual Hub',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

List<String> mainAdminOffices = [
  "Department Office",
  "College Office",
  "Hostel Office",
  "Chapel Office",
  "Health Care Office",
  "Cafeteria Office",
  "IT Support",
  "Library Help",
  "Student Affairs",
  "Finance Assistance",
  "Academic Advisory",
  "Technical Support"
];
