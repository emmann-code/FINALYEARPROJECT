// ignore_for_file: unused_local_variable, sized_box_for_whitespace, curly_braces_in_flow_control_structures, unused_import, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  // Variables to store the count of complaints
  int academicAdvisoryComplaintsCount = 0;
  int cafeteriaComplaintsCount = 0;
  int chapelComplaintsCount = 0;
  int collegeComplaintsCount = 0;
  int departmentComplaintsCount = 0;
  int financeComplaintsCount = 0;
  int healthcareComplaintsCount = 0;
  int hostelComplaintsCount = 0;
  int itSupportComplaintsCount = 0;
  int libraryComplaintsCount = 0;
  int studentAffairsComplaintsCount = 0;
  int technicalComplaintsCount = 0;

  int totalComplaintsCount = 0;
  String selectedStatus = "All";
  bool isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Map<String, Color> categoryColors = {
    "AcademicAdvisoryComplaints": Color(0xFF2196F3),
    "CaferteriaComplaints": Color(0xFFFF9800),
    "ChapelComplaints": Color(0xFF9C27B0),
    "CollegeComplaints": Color(0xFF4CAF50),
    "DepartmentComplaints": Color(0xFFF44336),
    "FinianceComplaints": Color(0xFF009688),
    "HealthCareComplaints": Color(0xFFE91E63),
    "HostelComplaints": Color(0xFF795548),
    "ITSupportComplaints": Color(0xFF3F51B5),
    "LibraryComplaints": Color(0xFFFFEB3B),
    "StudentAffairsComplaints": Color(0xFF00BCD4),
    "TechnicalComplaints": Color(0xFF673AB7),
  };

  static const Map<String, IconData> categoryIcons = {
    "AcademicAdvisoryComplaints": Icons.school,
    "CaferteriaComplaints": Icons.restaurant,
    "ChapelComplaints": Icons.church,
    "CollegeComplaints": Icons.business,
    "DepartmentComplaints": Icons.account_balance,
    "FinianceComplaints": Icons.account_balance_wallet,
    "HealthCareComplaints": Icons.local_hospital,
    "HostelComplaints": Icons.home,
    "ITSupportComplaints": Icons.computer,
    "LibraryComplaints": Icons.library_books,
    "StudentAffairsComplaints": Icons.people,
    "TechnicalComplaints": Icons.build,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    loadCachedComplaintCounts();
    fetchComplaintCounts();
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

  // Fetch the number of complaints from multiple collections
  Future<void> loadCachedComplaintCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    academicAdvisoryComplaintsCount =
        prefs.getInt('AcademicAdvisoryComplaints') ?? 0;
    cafeteriaComplaintsCount = prefs.getInt('CaferteriaComplaints') ?? 0;
    chapelComplaintsCount = prefs.getInt('ChapelComplaints') ?? 0;
    collegeComplaintsCount = prefs.getInt('CollegeComplaints') ?? 0;
    departmentComplaintsCount = prefs.getInt('DepartmentComplaints') ?? 0;
    financeComplaintsCount = prefs.getInt('FinianceComplaints') ?? 0;
    healthcareComplaintsCount = prefs.getInt('HealthCareComplaints') ?? 0;
    hostelComplaintsCount = prefs.getInt('HostelComplaints') ?? 0;
    itSupportComplaintsCount = prefs.getInt('ITSupportComplaints') ?? 0;
    libraryComplaintsCount = prefs.getInt('LibraryComplaints') ?? 0;
    studentAffairsComplaintsCount =
        prefs.getInt('StudentAffairsComplaints') ?? 0;
    technicalComplaintsCount = prefs.getInt('TechnicalComplaints') ?? 0;

    totalComplaintsCount = academicAdvisoryComplaintsCount +
        cafeteriaComplaintsCount +
        chapelComplaintsCount +
        collegeComplaintsCount +
        departmentComplaintsCount +
        financeComplaintsCount +
        healthcareComplaintsCount +
        hostelComplaintsCount +
        itSupportComplaintsCount +
        libraryComplaintsCount +
        studentAffairsComplaintsCount +
        technicalComplaintsCount;

    setState(() {}); // Update the UI
  }

// Fetch the number of complaints from multiple collections
  Future<void> fetchComplaintCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      academicAdvisoryComplaintsCount =
          await _getComplaintCount('AcademicAdvisoryComplaints');
      cafeteriaComplaintsCount =
          await _getComplaintCount('CaferteriaComplaints');
      chapelComplaintsCount = await _getComplaintCount('ChapelComplaints');
      collegeComplaintsCount = await _getComplaintCount('CollegeComplaints');
      departmentComplaintsCount =
          await _getComplaintCount('DepartmentComplaints');
      financeComplaintsCount = await _getComplaintCount('FinianceComplaints');
      healthcareComplaintsCount =
          await _getComplaintCount('HealthCareComplaints');
      hostelComplaintsCount = await _getComplaintCount('HostelComplaints');
      itSupportComplaintsCount =
          await _getComplaintCount('ITSupportComplaints');
      libraryComplaintsCount = await _getComplaintCount('LibraryComplaints');
      studentAffairsComplaintsCount =
          await _getComplaintCount('StudentAffairsComplaints');
      technicalComplaintsCount =
          await _getComplaintCount('TechnicalComplaints');

      // Calculating the total number of complaints
      totalComplaintsCount = academicAdvisoryComplaintsCount +
          cafeteriaComplaintsCount +
          chapelComplaintsCount +
          collegeComplaintsCount +
          departmentComplaintsCount +
          financeComplaintsCount +
          healthcareComplaintsCount +
          hostelComplaintsCount +
          itSupportComplaintsCount +
          libraryComplaintsCount +
          studentAffairsComplaintsCount +
          technicalComplaintsCount;

      // Trigger a rebuild when the data is fetched
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to get complaint count from each collection
  Future<int> _getComplaintCount(String collectionName) async {
    try {
      Query query = FirebaseFirestore.instance.collection(collectionName);
      if (selectedStatus != "All") {
        query = query.where('status', isEqualTo: selectedStatus);
      }
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
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
              ? [Color(0xFF1A1A1A), Color(0xFF121212), Color(0xFF1A1A1A)]
              : [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
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
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                    letterSpacing: 1.0,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    SizedBox(height: 24),
                    _buildStatsCards(),
                    SizedBox(height: 24),
                    _buildComplaintOverview(),
                    SizedBox(height: 24),
                    _buildComplaintList(),
                    SizedBox(height: 20),
                  ],
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
              ? [Colors.blue.shade800, Colors.blue.shade900]
              : [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.blue.withValues(alpha: 0.3)
                : Colors.blue.withValues(alpha: 0.3),
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
                  "Welcome to MTU Connect Hub",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Complaint Management Dashboard",
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
              Icons.analytics_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final isDarkMode = ref.watch(themeProvider);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Total Complaints",
            totalComplaintsCount.toString(),
            Icons.assessment,
            Colors.blue.shade600,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            "Active Status",
            selectedStatus,
            Icons.filter_list,
            Colors.orange.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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
        border: Border.all(
            color: isDarkMode
                ? Colors.grey.shade700
                : color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Complaint Overview (Pie Chart)
  Widget _buildComplaintOverview() {
    final isDarkMode = ref.watch(themeProvider);

    int totalComplaints = academicAdvisoryComplaintsCount +
        cafeteriaComplaintsCount +
        chapelComplaintsCount +
        collegeComplaintsCount +
        departmentComplaintsCount +
        financeComplaintsCount +
        healthcareComplaintsCount +
        hostelComplaintsCount +
        itSupportComplaintsCount +
        libraryComplaintsCount +
        studentAffairsComplaintsCount +
        technicalComplaintsCount;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pie_chart,
                    color: isDarkMode
                        ? Colors.blue.shade300
                        : Colors.blue.shade600,
                    size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Complaints Distribution",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isLoading)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                              ? Colors.blue.shade300
                              : Colors.blue.shade600),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Loading...",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.blue.shade300
                              : Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 20),
          if (isLoading) ...[
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                            ? Colors.blue.shade300
                            : Colors.blue.shade600),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading complaint data...",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (totalComplaints > 0) ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    _buildPieChartSection("AcademicAdvisoryComplaints",
                        academicAdvisoryComplaintsCount, totalComplaints),
                    _buildPieChartSection("CaferteriaComplaints",
                        cafeteriaComplaintsCount, totalComplaints),
                    _buildPieChartSection("ChapelComplaints",
                        chapelComplaintsCount, totalComplaints),
                    _buildPieChartSection("CollegeComplaints",
                        collegeComplaintsCount, totalComplaints),
                    _buildPieChartSection("DepartmentComplaints",
                        departmentComplaintsCount, totalComplaints),
                    _buildPieChartSection("FinianceComplaints",
                        financeComplaintsCount, totalComplaints),
                    _buildPieChartSection("HealthCareComplaints",
                        healthcareComplaintsCount, totalComplaints),
                    _buildPieChartSection("HostelComplaints",
                        hostelComplaintsCount, totalComplaints),
                    _buildPieChartSection("ITSupportComplaints",
                        itSupportComplaintsCount, totalComplaints),
                    _buildPieChartSection("LibraryComplaints",
                        libraryComplaintsCount, totalComplaints),
                    _buildPieChartSection("StudentAffairsComplaints",
                        studentAffairsComplaintsCount, totalComplaints),
                    _buildPieChartSection("TechnicalComplaints",
                        technicalComplaintsCount, totalComplaints),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildLegend(),
          ] else ...[
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: isDarkMode
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No complaints data available",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Pull down to refresh",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final isDarkMode = ref.watch(themeProvider);

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryColors.entries.map((entry) {
        String officeName = entry.key.replaceAll("Complaints", "");
        int count = _getCountForCategory(entry.key);

        if (count == 0) return SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: entry.value.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: entry.value.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.value,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "$officeName ($count)",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _getCountForCategory(String category) {
    switch (category) {
      case "AcademicAdvisoryComplaints":
        return academicAdvisoryComplaintsCount;
      case "CaferteriaComplaints":
        return cafeteriaComplaintsCount;
      case "ChapelComplaints":
        return chapelComplaintsCount;
      case "CollegeComplaints":
        return collegeComplaintsCount;
      case "DepartmentComplaints":
        return departmentComplaintsCount;
      case "FinianceComplaints":
        return financeComplaintsCount;
      case "HealthCareComplaints":
        return healthcareComplaintsCount;
      case "HostelComplaints":
        return hostelComplaintsCount;
      case "ITSupportComplaints":
        return itSupportComplaintsCount;
      case "LibraryComplaints":
        return libraryComplaintsCount;
      case "StudentAffairsComplaints":
        return studentAffairsComplaintsCount;
      case "TechnicalComplaints":
        return technicalComplaintsCount;
      default:
        return 0;
    }
  }

  PieChartSectionData _buildPieChartSection(
      String title, int count, int totalComplaints) {
    if (count == 0)
      return PieChartSectionData(value: 0, color: Colors.transparent);

    double percentage =
        totalComplaints > 0 ? (count / totalComplaints) * 100 : 0;
    String officeName = title.replaceAll("Complaints", "");
    Color sectionColor = categoryColors[title] ?? Colors.grey;

    return PieChartSectionData(
      value: count.toDouble(),
      color: sectionColor,
      title: "${percentage.toStringAsFixed(1)}%",
      radius: 60,
      titleStyle: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      showTitle: true,
    );
  }

  // Complaint List
  Widget _buildComplaintList() {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.list_alt,
                      color: isDarkMode
                          ? Colors.blue.shade300
                          : Colors.blue.shade600,
                      size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Complaints by Category",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.blue.shade900
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                                ? Colors.blue.shade300
                                : Colors.blue.shade600),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Updating...",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.blue.shade300
                                : Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading) ...[
            ...List.generate(6, (index) => _buildLoadingCard()),
          ] else ...[
            ..._buildComplaintCards(),
          ],
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        title: Container(
          height: 16,
          width: 120,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Container(
          height: 12,
          width: 80,
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        trailing: Container(
          width: 40,
          height: 24,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildComplaintCards() {
    List<Map<String, dynamic>> complaintData = [
      {
        'title': 'Academic Advisory',
        'count': academicAdvisoryComplaintsCount,
        'category': 'AcademicAdvisoryComplaints'
      },
      {
        'title': 'Cafeteria',
        'count': cafeteriaComplaintsCount,
        'category': 'CaferteriaComplaints'
      },
      {
        'title': 'Chapel',
        'count': chapelComplaintsCount,
        'category': 'ChapelComplaints'
      },
      {
        'title': 'College',
        'count': collegeComplaintsCount,
        'category': 'CollegeComplaints'
      },
      {
        'title': 'Department',
        'count': departmentComplaintsCount,
        'category': 'DepartmentComplaints'
      },
      {
        'title': 'Finance',
        'count': financeComplaintsCount,
        'category': 'FinianceComplaints'
      },
      {
        'title': 'Healthcare',
        'count': healthcareComplaintsCount,
        'category': 'HealthCareComplaints'
      },
      {
        'title': 'Hostel',
        'count': hostelComplaintsCount,
        'category': 'HostelComplaints'
      },
      {
        'title': 'IT Support',
        'count': itSupportComplaintsCount,
        'category': 'ITSupportComplaints'
      },
      {
        'title': 'Library',
        'count': libraryComplaintsCount,
        'category': 'LibraryComplaints'
      },
      {
        'title': 'Student Affairs',
        'count': studentAffairsComplaintsCount,
        'category': 'StudentAffairsComplaints'
      },
      {
        'title': 'Technical',
        'count': technicalComplaintsCount,
        'category': 'TechnicalComplaints'
      },
    ];

    return complaintData.map((data) {
      return _buildComplaintCard(
        title: data['title'],
        count: data['count'],
        category: data['category'],
      );
    }).toList();
  }

  Widget _buildComplaintCard(
      {required String title, required int count, required String category}) {
    final isDarkMode = ref.watch(themeProvider);

    Color color = categoryColors[category] ?? Colors.grey;
    IconData icon = categoryIcons[category] ?? Icons.category;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          "$count complaints",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
