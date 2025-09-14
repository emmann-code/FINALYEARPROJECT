// ignore_for_file: unused_element, unnecessary_cast, use_super_parameters, use_build_context_synchronously, deprecated_member_use, empty_catches, unnecessary_import, avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_management.dart';
import 'package:mtu_connect_hub/features/auth/presentation/login_screen.dart';
import 'package:mtu_connect_hub/ADMIN/admin/settings_screen.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtu_connect_hub/ADMIN/admin/settings_screen.dart'
    show themeProvider;

const kPrimaryColor = Color(0xFF4B39EF);
const kAccentColor = Color(0xFF39D2C0);
const kCardBgLight = Color(0xFFF7F8FA);
const kCardBgDark = Color(0xFF232526);
const kShadow = [
  BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
];

// =====================
// 2. MAIN ADMIN DASHBOARD WIDGET
// =====================

/// The main admin dashboard screen, showing analytics and management tools.
class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with TickerProviderStateMixin {
  // --- State ---
  int totalComplaints = 0;
  int pendingComplaints = 0;
  int repliedComplaints = 0;
  Map<String, int> categoryCounts = {};
  int pendingCount = 0;
  int repliedCount = 0;
  bool _refreshing = false;
  Map<String, Map<String, int>> statusCounts = <String, Map<String, int>>{};

  // --- Category Info ---
  final List<_CategoryInfo> categories = [
    _CategoryInfo('Academic Advisory', 'AcademicAdvisoryComplaints',
        Icons.school, Colors.blue),
    _CategoryInfo(
        'Cafeteria', 'CaferteriaComplaints', Icons.restaurant, Colors.orange),
    _CategoryInfo(
        'Chapel', 'ChapelComplaints', Icons.church, Colors.deepPurple),
    _CategoryInfo(
        'College', 'CollegeComplaints', Icons.account_balance, Colors.indigo),
    _CategoryInfo(
        'Department', 'DepartmentComplaints', Icons.apartment, Colors.teal),
    _CategoryInfo(
        'Finance', 'FinianceComplaints', Icons.attach_money, Colors.green),
    _CategoryInfo('Healthcare', 'HealthCareComplaints', Icons.local_hospital,
        Colors.redAccent),
    _CategoryInfo('Hostel', 'HostelComplaints', Icons.hotel, Colors.brown),
    _CategoryInfo(
        'IT Support', 'ITSupportComplaints', Icons.computer, Colors.blueGrey),
    _CategoryInfo(
        'Library', 'LibraryComplaints', Icons.library_books, Colors.purple),
    _CategoryInfo('Student Affairs', 'StudentAffairsComplaints', Icons.people,
        Colors.cyan),
    _CategoryInfo(
        'Technical', 'TechnicalComplaints', Icons.build, Colors.amber),
    _CategoryInfo(
        'Spybox Tipoff', 'SPYBOXTIPOFF', Icons.visibility, Colors.pink),
  ];

  // --- Animation ---
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    _initAnimations();
  }

  void _initAnimations() {
    if (!mounted) return; // Check if widget is still mounted

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));
    _animationsInitialized = true;

    // Add defensive checks before starting animations
    if (mounted) {
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _slideController.forward();
      });
    }
  }

  @override
  void dispose() {
    if (_animationsInitialized) {
      _fadeController.dispose();
      _slideController.dispose();
    }
    super.dispose();
  }

  // =====================
  // 3. DATA FETCH & LOGIC
  // =====================

  Future<void> _fetchSummary() async {
    final adminInfo = ref.read(adminInfoProvider);
    final isSuperAdmin = adminInfo?.role == 'SuperAdmin';
    final userOffice = adminInfo?.office;
    int total = 0;
    int pending = 0;
    int replied = 0;
    Map<String, int> catCounts = {};
    int pend = 0;
    int rep = 0;
    statusCounts = {}; // Reset

    // Defensive check - if no admin info, return early
    if (adminInfo == null) {
      setState(() {
        totalComplaints = 0;
        pendingComplaints = 0;
        repliedComplaints = 0;
        categoryCounts = {};
        pendingCount = 0;
        repliedCount = 0;
      });
      return;
    }

    final catsToFetch = isSuperAdmin
        ? categories
        : categories.where((cat) => cat.title == userOffice).toList();

    for (final cat in catsToFetch) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(cat.collectionName)
            .get();
        catCounts[cat.title] = snapshot.docs.length;
        total += snapshot.docs.length;
        int catPending = 0;
        int catReplied = 0;
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if ((data['status'] ?? '').toString().toLowerCase() == 'replied') {
            replied++;
            rep++;
            catReplied++;
          } else {
            pending++;
            pend++;
            catPending++;
          }
        }
        statusCounts[cat.title] = {
          'pending': catPending,
          'replied': catReplied,
        };
      } catch (e) {
        // Handle any Firestore errors gracefully
        print('Error fetching data for ${cat.title}: $e');
        catCounts[cat.title] = 0;
        statusCounts[cat.title] = {
          'pending': 0,
          'replied': 0,
        };
      }
    }
    setState(() {
      totalComplaints = total;
      pendingComplaints = pending;
      repliedComplaints = replied;
      categoryCounts = catCounts;
      pendingCount = pend;
      repliedCount = rep;
    });
  }

  Future<void> _refreshDashboard() async {
    setState(() => _refreshing = true);
    await _fetchSummary();
    setState(() => _refreshing = false);
  }

  // =====================
  // 4. UI BUILDERS
  // =====================

  @override
  Widget build(BuildContext context) {
    final adminInfo = ref.watch(adminInfoProvider);
    final isSuperAdmin = adminInfo?.role == 'SuperAdmin';
    final userOffice = adminInfo?.office;
    final isDark = ref.watch(themeProvider);
    final cardBg = isDark ? kCardBgDark : Colors.white;
    final bg = isDark ? const Color(0xFF181A20) : kCardBgLight;

    // Defensive check - if no admin info, show loading or error
    if (adminInfo == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0.5,
          title: Text(
            'Admin Dashboard',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : kPrimaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kPrimaryColor),
              SizedBox(height: 16),
              Text(
                'Loading admin information...',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filter categories for regular admins
    final visibleCategories = isSuperAdmin
        ? categories
        : categories.where((cat) => cat.title == userOffice).toList();

    // Filter categoryCounts for regular admins
    final visibleCategoryCounts = isSuperAdmin
        ? categoryCounts
        : Map.fromEntries(
            categoryCounts.entries.where((e) => e.key == userOffice));

    final visibleTotalComplaints = isSuperAdmin
        ? totalComplaints
        : (userOffice != null ? (categoryCounts[userOffice] ?? 0) : 0);
    final visiblePendingComplaints = isSuperAdmin
        ? pendingComplaints
        : (userOffice != null
            ? _countComplaintsByStatus(userOffice, 'pending')
            : 0);
    final visibleRepliedComplaints = isSuperAdmin
        ? repliedComplaints
        : (userOffice != null
            ? _countComplaintsByStatus(userOffice, 'replied')
            : 0);

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(context, isDark, cardBg),
      body: _animationsInitialized &&
              _fadeAnimation != null &&
              _slideAnimation != null
          ? FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(isDark),
                          const SizedBox(height: 24),
                          _buildStatsRow(
                              isDark,
                              visibleTotalComplaints,
                              visiblePendingComplaints,
                              visibleRepliedComplaints),
                          const SizedBox(height: 24),
                          _buildAnalyticsCards(
                              isDark,
                              cardBg,
                              visibleCategories,
                              visibleCategoryCounts,
                              visibleTotalComplaints),
                          const SizedBox(height: 24),
                          if (isSuperAdmin) _buildUserManagementButton(context),
                          if (!isSuperAdmin && userOffice != null)
                            _buildOfficeFeature(context, userOffice),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isDark, Color cardBg) {
    return AppBar(
      backgroundColor: cardBg,
      elevation: 0.5,
      title: Text(
        'Admin Dashboard',
        style: GoogleFonts.poppins(
          color: isDark ? Colors.white : kPrimaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        // Refresh button
        _refreshing
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.refresh, color: kPrimaryColor),
                tooltip: 'Refresh',
                onPressed: _refreshDashboard,
              ),
        IconButton(
          icon: const Icon(Icons.settings, color: kPrimaryColor),
          tooltip: 'Admin Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => profilesettingss()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          tooltip: 'Logout',
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();
            } catch (e) {}
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
      iconTheme: const IconThemeData(color: kPrimaryColor),
    );
  }

  Widget _buildStatsRow(bool isDark, int total, int pending, int replied) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Total Complaints', total.toString(),
              Icons.all_inbox, Colors.blue.shade600, isDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Pending', pending.toString(),
              Icons.pending_actions, Colors.orange.shade600, isDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Replied', replied.toString(),
              Icons.check_circle, Colors.green.shade600, isDark),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards(bool isDark, Color cardBg,
      List<_CategoryInfo> cats, Map<String, int> catCounts, int total) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          color: cardBg,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.blue.shade900 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.pie_chart,
                          color: isDark
                              ? Colors.blue.shade300
                              : Colors.blue.shade600,
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complaints Distribution',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                    child: _buildPieChartWithLegend(
                        isDark, cats, catCounts, total)),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          color: cardBg,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.blue.shade900 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.list_alt,
                          color: isDark
                              ? Colors.blue.shade300
                              : Colors.blue.shade600,
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complaints by Category',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCategoryList(isDark, cats, catCounts),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserManagementButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.people),
        label: Text(
          'User Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(220, 48),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          );
        },
      ),
    );
  }

  Widget _buildOfficeFeature(BuildContext context, String office) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Welcome, $office Admin! You only have access to $office features.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  // =====================
  // 5. CHARTS & CATEGORY UI
  // =====================

  Widget _buildPieChartWithLegend(bool isDark, List<_CategoryInfo> cats,
      Map<String, int> catCounts, int total) {
    if (catCounts.isEmpty || total == 0) {
      return const Center(child: Text('No data for pie chart'));
    }
    final sections = catCounts.entries.map((e) {
      final percent = (e.value / total) * 100;
      final color = cats.firstWhere((c) => c.title == e.key).color;
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: color,
        title: percent >= 8 ? '${percent.toStringAsFixed(1)}%' : '',
        radius: 60,
        titleStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        showTitle: true,
        borderSide: const BorderSide(color: Colors.white, width: 3),
        titlePositionPercentageOffset: 0.7,
      );
    }).toList();
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: catCounts.entries.where((e) => e.value > 0).map((e) {
            final color = cats.firstWhere((c) => c.title == e.key).color;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.key} (${e.value})',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryList(
      bool isDark, List<_CategoryInfo> cats, Map<String, int> catCounts) {
    return Column(
      children: cats.map((cat) {
        final count = catCounts[cat.title] ?? 0;
        return _CategoryListTile(cat: cat, count: count, isDark: isDark);
      }).toList(),
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.blue.shade800, Colors.blue.shade900]
              : [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.blue.withOpacity(0.3)
                : Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  "Welcome, Admin!",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Admin Analytics Dashboard",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
            color: isDark ? Colors.grey.shade700 : color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to count complaints by status for a specific office
  int _countComplaintsByStatus(String office, String status) {
    if (statusCounts.isEmpty || office.isEmpty || status.isEmpty) return 0;
    final officeData = statusCounts[office];
    if (officeData == null) return 0;
    return officeData[status] ?? 0;
  }
}

// =====================
// 6. CATEGORY & LIST HELPERS
// =====================

/// Tile for a category in the complaints list.
class _CategoryListTile extends StatelessWidget {
  final _CategoryInfo cat;
  final int count;
  final bool isDark;
  const _CategoryListTile(
      {required this.cat, required this.count, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: cat.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cat.color.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: cat.color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cat.color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(cat.icon, color: cat.color, size: 24),
        ),
        title: Text(
          cat.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          '$count complaints',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cat.color,
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintsListScreen(
                category: cat.title,
                collectionName: cat.collectionName,
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================
// 7. CATEGORY INFO DATA CLASS
// =====================

class _CategoryInfo {
  final String title;
  final String collectionName;
  final IconData icon;
  final Color color;
  const _CategoryInfo(this.title, this.collectionName, this.icon, this.color);
}

class ComplaintsListScreen extends StatefulWidget {
  final String category;
  final String collectionName;
  const ComplaintsListScreen(
      {Key? key, required this.category, required this.collectionName})
      : super(key: key);

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? kCardBgDark : Colors.white;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF181A20) : kCardBgLight,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        title: Text('${widget.category} Complaints',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: kPrimaryColor)),
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by title, user, description...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                  ),
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    underline: SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'Replied', child: Text('Replied')),
                    ],
                    onChanged: (val) =>
                        setState(() => _statusFilter = val ?? 'All'),
                  ),
                ),
              ],
            ),
          ),
          // Export CSV button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download, color: kPrimaryColor),
                label: const Text('Export CSV',
                    style: TextStyle(color: kPrimaryColor)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: kPrimaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _exportCsv(context),
              ),
            ),
          ),
          // Complaints list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(widget.collectionName)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No complaints found.'));
                }
                final complaints = snapshot.data!.docs;
                // Filter and search logic
                final filtered = complaints.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = (data['status'] ?? 'pending').toString();
                  final user = data['user'] ?? {};
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final description =
                      (data['description'] ?? '').toString().toLowerCase();
                  final userName = user is Map && user['name'] != null
                      ? user['name'].toString().toLowerCase()
                      : '';
                  final matchesSearch = _searchQuery.isEmpty ||
                      title.contains(_searchQuery.toLowerCase()) ||
                      description.contains(_searchQuery.toLowerCase()) ||
                      userName.contains(_searchQuery.toLowerCase());
                  final matchesStatus = _statusFilter == 'All' ||
                      status == _statusFilter.toLowerCase();
                  return matchesSearch && matchesStatus;
                }).toList();
                return RefreshIndicator(
                  onRefresh: () async {
                    print('Pull-to-refresh triggered');
                    await Future.delayed(const Duration(milliseconds: 500));
                    setState(() {});
                  },
                  child: ListView.builder(
                    key: const PageStorageKey('complaints-list'),
                    padding: const EdgeInsets.all(12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        // Add extra space at the end to ensure scrollability
                        return const SizedBox(height: 120);
                      }
                      final doc = filtered[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final status = (data['status'] ?? 'pending').toString();
                      final timestamp =
                          (data['timestamp'] as Timestamp?)?.toDate();
                      final user = data['user'] ?? {};
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 5,
                        color: cardBg,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: status == 'replied'
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                                status == 'replied'
                                    ? Icons.check
                                    : Icons.hourglass_bottom,
                                color: Colors.white),
                          ),
                          title: Text(data['title'] ?? 'No Title',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['category'] != null)
                                Text('Category: ${data['category']}',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[800])),
                              Text(
                                  'Status: ${status[0].toUpperCase() + status.substring(1)}',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[700])),
                              if (timestamp != null)
                                Text(
                                    'Date: ${timestamp.toLocal().toString().split(".")[0]}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                              if (user is Map && user['matric'] != null)
                                Text('Matric: ${user['matric']}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(data['description'] ?? '',
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios,
                                color: kPrimaryColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FeedbackScreen(
                                    complaintId: doc.id,
                                    collectionName: widget.collectionName,
                                    complaintData: data,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .orderBy('timestamp', descending: true)
          .get();
      final complaints = snapshot.docs;
      // Filter using current search and status filter
      final filtered = complaints.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = (data['status'] ?? 'pending').toString();
        final user = data['user'] ?? {};
        final title = (data['title'] ?? '').toString().toLowerCase();
        final description =
            (data['description'] ?? '').toString().toLowerCase();
        final userName = user is Map && user['name'] != null
            ? user['name'].toString().toLowerCase()
            : '';
        final matchesSearch = _searchQuery.isEmpty ||
            title.contains(_searchQuery.toLowerCase()) ||
            description.contains(_searchQuery.toLowerCase()) ||
            userName.contains(_searchQuery.toLowerCase());
        final matchesStatus =
            _statusFilter == 'All' || status == _statusFilter.toLowerCase();
        return matchesSearch && matchesStatus;
      }).toList();
      if (filtered.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No complaints to export.')),
        );
        return;
      }
      // Prepare CSV rows
      final rows = <List<String>>[
        [
          'Title',
          'Description',
          'User Name',
          'User Email',
          'User Matric',
          'Status',
          'Date',
        ]
      ];
      for (final doc in filtered) {
        final data = doc.data() as Map<String, dynamic>;
        final user = data['user'] ?? {};
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        rows.add([
          (data['title'] ?? '').toString(),
          (data['description'] ?? '').toString(),
          user is Map && user['name'] != null ? user['name'].toString() : '',
          user is Map && user['email'] != null ? user['email'].toString() : '',
          user is Map && user['matric'] != null
              ? user['matric'].toString()
              : '',
          (data['status'] ?? '').toString(),
          timestamp != null ? timestamp.toLocal().toString().split(".")[0] : '',
        ]);
      }
      final csvData = const ListToCsvConverter().convert(rows);
      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/${widget.category}_complaints.csv')
              .writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exported complaints for ${widget.category}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }
}

class FeedbackScreen extends StatefulWidget {
  final String complaintId;
  final String collectionName;
  final Map<String, dynamic> complaintData;
  const FeedbackScreen(
      {Key? key,
      required this.complaintId,
      required this.collectionName,
      required this.complaintData})
      : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.complaintData['adminFeedback'] != null) {
      _controller.text = widget.complaintData['adminFeedback'];
    }
  }

  Future<void> _sendFeedback() async {
    final feedback = _controller.text.trim();
    if (feedback.isEmpty) {
      setState(() => _error = 'Feedback cannot be empty.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.complaintId)
          .update({
        'adminFeedback': feedback,
        'adminReply': feedback,
        'status': 'replied',
        'feedbackTimestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to send feedback.');
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.complaintData;
    final user = data['user'] ?? {};
    final status = (data['status'] ?? 'pending').toString();
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final feedback = data['adminFeedback'] ?? '';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? kCardBgDark : Colors.white;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF181A20) : kCardBgLight,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        title: const Text('Complaint Details & Reply',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
        iconTheme: const IconThemeData(color: kPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 8,
          color: cardBg,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          status == 'replied' ? Colors.green : Colors.orange,
                      child: Icon(
                          status == 'replied'
                              ? Icons.check
                              : Icons.hourglass_bottom,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(data['title'] ?? 'No Title',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['category'] != null)
                      Text('Category: ${data['category']}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[800])),
                    Text(
                        'Status: ${status[0].toUpperCase() + status.substring(1)}',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[700])),
                    if (timestamp != null)
                      Text(
                          'Date: ${timestamp.toLocal().toString().split(".")[0]}',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                    if (user is Map && user['matric'] != null)
                      Text('Matric: ${user['matric']}',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                    if (user is Map && user['name'] != null)
                      Text(
                          'From: ${user['name']}${user['email'] != null ? ' (${user['email']})' : ''}',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 32),
                // Description
                Text('Description:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(data['description'] ?? '', style: GoogleFonts.poppins()),
                const SizedBox(height: 10),
                // Previous Reply
                if (feedback.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Previous Reply:',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700])),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(feedback,
                            style: GoogleFonts.poppins(color: Colors.black87)),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                // Reply input
                Text('Reply to this complaint:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Type your reply...',
                    errorText: _error,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor:
                        isDark ? kCardBgDark.withOpacity(0.9) : kCardBgLight,
                  ),
                ),
                const SizedBox(height: 18),
                _sending
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _sendFeedback,
                        icon: const Icon(Icons.send),
                        label: const Text('Send Reply'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
