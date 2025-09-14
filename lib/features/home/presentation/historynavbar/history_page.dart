// ignore_for_file: prefer_const_constructors_in_immutables, use_super_parameters, use_build_context_synchronously, unused_import, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// Global constants for category colors and icons
const Map<String, Color> categoryColors = {
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

const Map<String, IconData> categoryIcons = {
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

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  String _selectedFilter = "All";

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // List of all collection names to fetch complaints from
  final List<String> collectionNames = [
    "AcademicAdvisoryComplaints",
    "CaferteriaComplaints",
    "ChapelComplaints",
    "CollegeComplaints",
    "DepartmentComplaints",
    "FinianceComplaints",
    "HealthCareComplaints",
    "HostelComplaints",
    "ITSupportComplaints",
    "LibraryComplaints",
    "StudentAffairsComplaints",
    "TechnicalComplaints",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCachedComplaints().then((_) {
      // Always fetch in the background even if cache is available.
      _fetchAllComplaints();
    });
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

  // Load cached complaints from SharedPreferences if available
  Future<void> _loadCachedComplaints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cachedComplaints');
    if (cachedData != null) {
      List<dynamic> decoded = json.decode(cachedData);
      setState(() {
        _complaints = decoded.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    }
  }

  // Fetch complaints from all collections, combine them, cache, and update the UI.
  Future<void> _fetchAllComplaints() async {
    bool initialLoad = _complaints.isEmpty;
    if (initialLoad) {
      setState(() {
        _isLoading = true;
      });
    }
    List<Map<String, dynamic>> fetchedComplaints = [];
    try {
      // Loop through each collection and fetch its documents.
      for (String collection in collectionNames) {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection(collection).get();
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          fetchedComplaints.add({
            'id': doc.id,
            'title': data['title'] ?? 'No Title',
            'description': data['description'] ?? '',
            'name': data['name'] ?? '',
            'matric': data['matric'] ?? '',
            'category': data['category'] ?? '',
            'isAnonymous': data['isAnonymous'] ?? '',
            'image': data['image'] ?? 'assets/tst.png',
            'adminReply': data['adminReply'], // admin reply if exists
            'collection': collection,
            'timestamp': data['timestamp'] ?? 0,
          });
        }
      }

      // Sort the complaints by timestamp (latest first)
      fetchedComplaints.sort((a, b) {
        if (a['timestamp'] is Timestamp && b['timestamp'] is Timestamp) {
          return (b['timestamp'] as Timestamp)
              .compareTo(a['timestamp'] as Timestamp);
        } else if (a['timestamp'] is int && b['timestamp'] is int) {
          return (b['timestamp'] as int).compareTo(a['timestamp'] as int);
        } else {
          return 0;
        }
      });

      setState(() {
        _complaints = fetchedComplaints;
        _isLoading = false;
      });

      // Cache the fetched complaints as JSON
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedComplaints', json.encode(fetchedComplaints));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete a complaint from Firestore and update local list.
  Future<void> _deleteComplaint(Map<String, dynamic> complaint) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Complaint',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this complaint?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed) {
      try {
        String collection = complaint['collection'];
        String id = complaint['id'];
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(id)
            .delete();
        setState(() {
          _complaints.removeWhere(
              (c) => c['id'] == id && c['collection'] == collection);
        });
        // Optionally, update the cache
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('cachedComplaints', json.encode(_complaints));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint deleted successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting complaint'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Refresh complaints manually (e.g., via pull-to-refresh)
  Future<void> _refreshComplaints() async {
    await _fetchAllComplaints();
  }

  List<Map<String, dynamic>> get _filteredComplaints {
    if (_selectedFilter == "All") {
      return _complaints;
    }
    return _complaints
        .where((complaint) => complaint['collection'] == _selectedFilter)
        .toList();
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
                  'History',
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
              child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isLoading && _complaints.isEmpty
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: _refreshComplaints,
                  color: Colors.blue.shade600,
                  child: _filteredComplaints.isNotEmpty
                      ? _buildComplaintsList()
                      : _buildEmptyState(),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final isDarkMode = ref.watch(themeProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
            child: Column(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                        ? Colors.blue.shade300
                        : Colors.blue.shade600),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Loading complaints...",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Please wait while we fetch your complaint history",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = ref.watch(themeProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(20),
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
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.history,
                    size: 48,
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "No complaints found",
            style: GoogleFonts.poppins(
              fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.grey.shade200
                        : Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _selectedFilter == "All"
                      ? "You haven't submitted any complaints yet"
                      : "No complaints found in ${_selectedFilter.replaceAll("Complaints", "")} category",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Pull down to refresh",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDarkMode
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _filteredComplaints.length,
      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
        var complaint = _filteredComplaints[index];
                        String dateString = '';
                        if (complaint['timestamp'] != null && complaint['timestamp'] != 0) {
                          DateTime dt;
                          var ts = complaint['timestamp'];
                          if (ts is Timestamp) {
                            dt = ts.toDate();
                          } else if (ts is int) {
                            dt = DateTime.fromMillisecondsSinceEpoch(ts);
                          } else {
                            dt = DateTime.now();
                          }
          dateString = DateFormat('MMM dd, yyyy • HH:mm').format(dt);
                        }
                        return ModernComplaintTile(
                          complaint: complaint,
                          date: dateString,
                          onDelete: () => _deleteComplaint(complaint),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                builder: (context) => ComplaintDetailScreen(
                    complaint: complaint, date: dateString),
                              ),
                            );
                          },
                        );
                      },
    );
  }
}

/// A modern styled complaint tile with delete functionality.
class ModernComplaintTile extends ConsumerWidget {
  final Map<String, dynamic> complaint;
  final String date;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ModernComplaintTile({
    Key? key,
    required this.complaint,
    required this.date,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    Color categoryColor =
        categoryColors[complaint['collection']] ?? Colors.grey;
    IconData categoryIcon =
        categoryIcons[complaint['collection']] ?? Icons.category;
    String categoryName = complaint['collection'].replaceAll("Complaints", "");

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            complaint['title'] ?? 'No Title',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            categoryName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      complaint['description'] ?? 'No description',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                        ),
                        SizedBox(width: 4),
                    Text(
                      date,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                        Spacer(),
                        if (complaint['adminReply'] != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Replied',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete,
                            color: Colors.red.shade600, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style:
                              GoogleFonts.poppins(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail screen for a complaint, styled like a chat or feedback space.
class ComplaintDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> complaint;
  final String date;

  const ComplaintDetailScreen({
    Key? key,
    required this.complaint,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    String adminReply = complaint['adminReply'] ??
        "Pending - Your complaint will be addressed soon.";
    Color categoryColor =
        categoryColors[complaint['collection']] ?? Colors.grey;
    IconData categoryIcon =
        categoryIcons[complaint['collection']] ?? Icons.category;
    String categoryName = complaint['collection'].replaceAll("Complaints", "");

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
        centerTitle: true,
        title: Text(
          "Complaint Details",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey.shade800,
          ),
        ),
        iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.grey.shade800),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Text(
                          categoryName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                        Text(
                          "Complaint #${complaint['id'].toString().length > 8 ? complaint['id'].toString().substring(0, 8) : complaint['id']}",
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
                ],
              ),
            ),
            SizedBox(height: 24),

            // Complaint Information
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Complaint Details",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                      "Title", complaint['title'] ?? 'No Title', isDarkMode),
                  _buildDetailRow("Description",
                      complaint['description'] ?? 'No description', isDarkMode),
                  _buildDetailRow("Category",
                      complaint['category'] ?? 'Not specified', isDarkMode),
                  _buildDetailRow("Submitted", date, isDarkMode),
                  if (complaint['isAnonymous'] != null)
                    _buildDetailRow(
                        "Submitted by", complaint['isAnonymous'], isDarkMode),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Admin Reply Section
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings,
                          color: Colors.blue.shade600, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Admin Response",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      Spacer(),
                      if (complaint['adminReply'] != null)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Replied',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade200),
                    ),
                    child: Text(
                      adminReply,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
