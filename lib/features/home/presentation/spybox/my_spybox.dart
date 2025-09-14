// ignore_for_file: prefer_const_constructors_in_immutables, use_build_context_synchronously, deprecated_member_use, sized_box_for_whitespace, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';

class Spyboxpage extends ConsumerStatefulWidget {
  Spyboxpage({super.key});

  @override
  ConsumerState<Spyboxpage> createState() => _SpyboxpageState();
}

class _SpyboxpageState extends ConsumerState<Spyboxpage>
    with TickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  bool isAnonymous = false;
  String? selectedCategory;
  String? selectedUrgency;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> categories = [
    "Crime",
    "Corruption",
    "Emergency",
    "Suspicious Activity",
    "Staff",
    "Other",
  ];

  final List<String> urgencyLevels = [
    "Normal",
    "High",
    "Critical",
  ];

  static const Map<String, IconData> categoryIcons = {
    "Crime": Icons.gavel,
    "Corruption": Icons.money_off,
    "Emergency": Icons.emergency,
    "Suspicious Activity": Icons.visibility_off,
    "Staff": Icons.people,
    "Other": Icons.more_horiz,
  };

  static const Map<String, Color> urgencyColors = {
    "Normal": Color(0xFF4CAF50),
    "High": Color(0xFFFF9800),
    "Critical": Color(0xFFF44336),
  };

  @override
  void initState() {
    super.initState();
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
    messageController.dispose();
    super.dispose();
  }

  // Send critical spy notice
  Future<void> _submitTipOff() async {
    // Prevent empty message submission
    if (messageController.text.trim().isEmpty ||
        selectedCategory == null ||
        selectedUrgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      // Get current user UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('SPYBOXTIPOFF').add({
        'description': messageController.text,
        'category': selectedCategory,
        'urgencylevel': selectedUrgency,
        'isAnonymous': isAnonymous,
        'timestamp': FieldValue.serverTimestamp(),
        'datestamp': DateTime.now().toIso8601String(),
        'userId': isAnonymous ? "Anonymous" : userId,
      });

      // Clear input fields after submission
      messageController.clear();
      setState(() {
        selectedCategory = null;
        selectedUrgency = null;
        isAnonymous = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tip Off Sent Successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      ),
      child: SafeArea(
        child: Column(
          children: [
            PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBar(
                elevation: 0,
                backgroundColor:
                    isDarkMode ? Colors.grey.shade800 : Colors.white,
                centerTitle: true,
                title: Text(
                  "SpyBox",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                iconTheme: IconThemeData(
                    color: isDarkMode ? Colors.white : Colors.grey.shade800),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(),
                        SizedBox(height: 24),
                        _buildMessageInput(),
                        SizedBox(height: 24),
                        _buildCategorySelector(),
                        SizedBox(height: 24),
                        _buildUrgencySelector(),
                        SizedBox(height: 24),
                        _buildAnonymitySwitch(),
                        SizedBox(height: 32),
                        _buildSubmitButton(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.red.shade800, Colors.red.shade900]
              : [Colors.red.shade600, Colors.red.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Confidential Tip-Off",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Report incidents anonymously and securely",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.security,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.message,
                      color: isDarkMode
                          ? Colors.blue.shade300
                          : Colors.blue.shade600,
                      size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  "Tip-Off Message",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: messageController,
              maxLines: 5,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: "Describe the incident or provide details...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color:
                      isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.blue.shade300
                          : Colors.blue.shade600,
                      width: 2),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade50,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.orange.shade900
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.category,
                      color: isDarkMode
                          ? Colors.orange.shade300
                          : Colors.orange.shade600,
                      size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  "Category",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              isExpanded: true,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: "Select a category",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color:
                      isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.orange.shade300
                          : Colors.orange.shade600,
                      width: 2),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade50,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        categoryIcons[category] ?? Icons.category,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUrgencySelector() {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.red.shade900 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.priority_high,
                      color: isDarkMode
                          ? Colors.red.shade300
                          : Colors.red.shade600,
                      size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  "Urgency Level",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonFormField<String>(
              value: selectedUrgency,
              isExpanded: true,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
              decoration: InputDecoration(
                hintText: "Select urgency level",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color:
                      isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.red.shade300
                          : Colors.red.shade600,
                      width: 2),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade50,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: urgencyLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: urgencyColors[level],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(level),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedUrgency = newValue;
                });
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnonymitySwitch() {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
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
              color:
                  isDarkMode ? Colors.purple.shade900 : Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.visibility_off,
                color: isDarkMode
                    ? Colors.purple.shade300
                    : Colors.purple.shade600,
                size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit Anonymously',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Your identity will be hidden',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAnonymous,
            onChanged: (val) {
              setState(() {
                isAnonymous = val;
              });
            },
            activeColor:
                isDarkMode ? Colors.purple.shade300 : Colors.purple.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitTipOff,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 20),
            SizedBox(width: 12),
            Text(
              "Submit Tip-Off",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
