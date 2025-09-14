// ignore_for_file: deprecated_member_use, unused_local_variable, prefer_final_fields, use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _search = '';
  String _statusFilter = 'All';
  String _roleFilter = 'All';
  String _sortBy = 'Name';
  bool _sortAsc = true;
  Set<String> _selectedUsers = {};
  int _page = 0;
  static const int _pageSize = 20;

  // --- Helper: Build Firestore Query ---
  Query _buildQuery() {
    Query q = FirebaseFirestore.instance.collection('users');
    if (_statusFilter != 'All') {
      q = q.where('disabled', isEqualTo: _statusFilter == 'Disabled');
    }
    if (_roleFilter != 'All') {
      q = q.where('role', isEqualTo: _roleFilter);
    }
    return q;
  }

  // --- Export Users as CSV ---
  Future<void> _exportCsv(List<QueryDocumentSnapshot> users) async {
    final rows = <List<String>>[
      ['Name', 'Email', 'Matric', 'Role', 'Status', 'Created At', 'Last Login']
    ];
    for (final user in users) {
      final data = user.data() as Map<String, dynamic>;
      rows.add([
        data['name'] ?? '',
        data['email'] ?? '',
        data['matric'] ?? '',
        data['role'] ?? '',
        (data['disabled'] == true) ? 'Disabled' : 'Active',
        data['createdAt']?.toDate().toString() ?? '',
        data['lastLogin']?.toDate().toString() ?? '',
      ]);
    }
    final csvData = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final file =
        await File('${tempDir.path}/users_export.csv').writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)], text: 'Exported users list');
  }

  // --- Bulk Actions ---
  Future<void> _bulkUpdate({required bool disable}) async {
    for (final userId in _selectedUsers) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'disabled': disable});
    }
    setState(() => _selectedUsers.clear());
  }

  Future<void> _bulkDelete() async {
    for (final userId in _selectedUsers) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    }
    setState(() => _selectedUsers.clear());
  }

  // --- Pagination ---
  void _nextPage(int total) {
    if ((_page + 1) * _pageSize < total) setState(() => _page++);
  }

  void _prevPage() {
    if (_page > 0) setState(() => _page--);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF232526) : Colors.white;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 1,
        title: Text('User Management',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () async {
              final snap = await _buildQuery().get();
              _exportCsv(snap.docs);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search & Filter Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, matric...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 12),
                        ),
                        onChanged: (val) => setState(() => _search = val),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(
                            value: 'All', child: Text('All Statuses')),
                        DropdownMenuItem(
                            value: 'Active', child: Text('Active')),
                        DropdownMenuItem(
                            value: 'Disabled', child: Text('Disabled')),
                      ],
                      onChanged: (val) =>
                          setState(() => _statusFilter = val ?? 'All'),
                      underline: const SizedBox(),
                    ),
                    DropdownButton<String>(
                      value: _roleFilter,
                      items: const [
                        DropdownMenuItem(
                            value: 'All', child: Text('All Roles')),
                        DropdownMenuItem(value: 'User', child: Text('User')),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(
                            value: 'SuperAdmin', child: Text('Super Admin')),
                      ],
                      onChanged: (val) =>
                          setState(() => _roleFilter = val ?? 'All'),
                      underline: const SizedBox(),
                    ),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(value: 'Name', child: Text('Name')),
                        DropdownMenuItem(
                            value: 'Created', child: Text('Created')),
                        DropdownMenuItem(
                            value: 'Status', child: Text('Status')),
                      ],
                      onChanged: (val) =>
                          setState(() => _sortBy = val ?? 'Name'),
                      underline: const SizedBox(),
                    ),
                    IconButton(
                      icon: Icon(
                          _sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
                      tooltip: 'Sort Order',
                      onPressed: () => setState(() => _sortAsc = !_sortAsc),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- Bulk Actions Bar ---
          if (_selectedUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Card(
                color: Colors.blueGrey.shade50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${_selectedUsers.length} selected',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock, size: 16),
                        label: const Text('Disable'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onPressed: () => _bulkUpdate(disable: true),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock_open, size: 16),
                        label: const Text('Enable'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onPressed: () => _bulkUpdate(disable: false),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onPressed: _bulkDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // --- User List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }
                // --- Filtering, Sorting, Pagination ---
                List<QueryDocumentSnapshot> users = snapshot.data!.docs;
                // Search
                if (_search.isNotEmpty) {
                  users = users.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final s = _search.toLowerCase();
                    return (data['name'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(s) ||
                        (data['email'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(s) ||
                        (data['matric'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(s);
                  }).toList();
                }
                // Sort
                users.sort((a, b) {
                  final da = a.data() as Map<String, dynamic>;
                  final db = b.data() as Map<String, dynamic>;
                  int cmp = 0;
                  switch (_sortBy) {
                    case 'Name':
                      cmp = (da['name'] ?? '')
                          .toString()
                          .compareTo((db['name'] ?? '').toString());
                      break;
                    case 'Created':
                      cmp = (da['createdAt'] ?? Timestamp(0, 0))
                          .compareTo(db['createdAt'] ?? Timestamp(0, 0));
                      break;
                    case 'Status':
                      cmp = ((da['disabled'] == true) ? 1 : 0)
                          .compareTo((db['disabled'] == true) ? 1 : 0);
                      break;
                  }
                  return _sortAsc ? cmp : -cmp;
                });
                // Pagination
                final total = users.length;
                final start = _page * _pageSize;
                final end =
                    ((start + _pageSize) > total) ? total : (start + _pageSize);
                final pageUsers = users.sublist(start, end);
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        itemCount: pageUsers.length,
                        itemBuilder: (context, index) {
                          final user = pageUsers[index];
                          final data = user.data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'No Name';
                          final email = data['email'] ?? '';
                          final matric = data['matric'];
                          final role = data['role'] ?? 'User';
                          final isDisabled = data['disabled'] == true;
                          final createdAt = data['createdAt']?.toDate();
                          final lastLogin = data['lastLogin']?.toDate();
                          final isSelected = _selectedUsers.contains(user.id);
                          return _UserCard(
                            data: data,
                            isSelected: isSelected,
                            isDark: isDark,
                            cardBg: cardBg,
                            onSelect: () => setState(() {
                              if (isSelected) {
                                _selectedUsers.remove(user.id);
                              } else {
                                _selectedUsers.add(user.id);
                              }
                            }),
                            onRoleChanged: (val) async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.id)
                                  .update({'role': val});
                              setState(() {});
                            },
                            onToggleStatus: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.id)
                                  .update({'disabled': !isDisabled});
                              setState(() {});
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete User'),
                                  content: const Text(
                                      'Are you sure you want to delete this user? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.id)
                                    .delete();
                              }
                              setState(() {});
                            },
                            onViewComplaints: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserComplaintsScreen(
                                      userId: user.id, userName: name),
                                ),
                              );
                            },
                            onShowDetails: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    _UserDetailsDialog(data: data),
                              );
                            },
                            onShowAuditLog: () {
                              showDialog(
                                context: context,
                                builder: (context) => const _AuditLogDialog(),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // --- Pagination Controls ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _page > 0 ? _prevPage : null,
                        ),
                        Text(
                            'Page ${_page + 1} of ${(total / _pageSize).ceil()}'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: ((_page + 1) * _pageSize < total)
                              ? () => _nextPage(total)
                              : null,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- User Details Dialog ---
class _UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  const _UserDetailsDialog({required this.data});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('User Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${data['name'] ?? ''}'),
            Text('Email: ${data['email'] ?? ''}'),
            Text('Matric: ${data['matric'] ?? ''}'),
            Text('Role: ${data['role'] ?? 'User'}'),
            Text(
                'Status: ${(data['disabled'] == true) ? 'Disabled' : 'Active'}'),
            if (data['createdAt'] != null)
              Text('Created: ${data['createdAt'].toDate().toString()}'),
            if (data['lastLogin'] != null)
              Text('Last Login: ${data['lastLogin'].toDate().toString()}'),
            // Add more fields as needed
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}

// --- Audit Log Dialog (Placeholder) ---
class _AuditLogDialog extends StatelessWidget {
  const _AuditLogDialog();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Audit Log'),
      content: const Text('Audit log feature coming soon.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}

class UserComplaintsScreen extends StatelessWidget {
  final String userId;
  final String userName;
  const UserComplaintsScreen(
      {super.key, required this.userId, required this.userName});

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
    "SPYBOXTIPOFF": Color(0xFFE57373),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF232526) : Colors.white;
    // List of all complaint collections
    final List<String> collections = [
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
      "SPYBOXTIPOFF",
    ];
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 1,
        title: Text('Complaints of $userName',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserComplaints(userId, collections),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No complaints found for this user.'));
          }
          final complaints = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final data = complaints[index];
              final category = data['category'] as String?;
              final status = (data['status'] ?? 'pending').toString();
              final timestamp = data['timestamp'] as DateTime?;
              final color = categoryColors[category] ?? Colors.grey;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 5,
                color: cardBg,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(Icons.folder, color: color, size: 22),
                  ),
                  title: Text(data['title'] ?? 'No Title',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: $category',
                          style:
                              GoogleFonts.poppins(fontSize: 13, color: color)),
                      Text(
                          'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: status == 'replied'
                                  ? Colors.green
                                  : Colors.orange)),
                      if (timestamp != null)
                        Text(
                            'Date: ${timestamp.toLocal().toString().split('.')[0]}',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchUserComplaints(
      String userId, List<String> collections) async {
    List<Map<String, dynamic>> complaints = [];
    for (final col in collections) {
      final snapshot = await FirebaseFirestore.instance
          .collection(col)
          .where('user.userId', isEqualTo: userId)
          .get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['category'] = col;
        complaints.add(data);
      }
    }
    return complaints;
  }
}

// 1. Add a user avatar fallback
Widget _buildUserAvatar(String? name) {
  return CircleAvatar(
    radius: 22,
    backgroundColor: Colors.blueGrey.shade100,
    child: Text(
      (name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?',
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
    ),
  );
}

// 2. Refactor user card into a separate widget
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSelected;
  final bool isDark;
  final Color cardBg;
  final VoidCallback? onSelect;
  final ValueChanged<String?>? onRoleChanged;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onViewComplaints;
  final VoidCallback? onShowDetails;
  final VoidCallback? onShowAuditLog;

  const _UserCard({
    required this.data,
    required this.isSelected,
    required this.isDark,
    required this.cardBg,
    this.onSelect,
    this.onRoleChanged,
    this.onToggleStatus,
    this.onDelete,
    this.onViewComplaints,
    this.onShowDetails,
    this.onShowAuditLog,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'No Name';
    final email = data['email'] ?? '';
    final matric = data['matric'];
    final role = data['role'] ?? 'User';
    final isDisabled = data['disabled'] == true;
    final createdAt = data['createdAt']?.toDate();
    final lastLogin = data['lastLogin']?.toDate();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox and Avatar
                Column(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelect?.call(),
                    ),
                    _buildUserAvatar(name),
                  ],
                ),
                const SizedBox(width: 12),
                // User Info and Chips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Chip(
                            label: Text(isDisabled ? 'Disabled' : 'Active'),
                            backgroundColor: isDisabled
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            labelStyle: TextStyle(
                              color: isDisabled ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Chip(
                            label: Text(role),
                            backgroundColor: role == 'Admin'
                                ? Colors.blue.shade100
                                : (role == 'SuperAdmin'
                                    ? Colors.purple.shade100
                                    : Colors.grey.shade200),
                            labelStyle: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          DropdownButton<String>(
                            value: role,
                            items: const [
                              DropdownMenuItem(
                                  value: 'User', child: Text('User')),
                              DropdownMenuItem(
                                  value: 'Admin', child: Text('Admin')),
                              DropdownMenuItem(
                                  value: 'SuperAdmin',
                                  child: Text('Super Admin')),
                            ],
                            onChanged: onRoleChanged,
                            underline: const SizedBox(),
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      if (matric != null)
                        Row(
                          children: [
                            const Icon(Icons.badge,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Matric: $matric',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      if (createdAt != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Created: ${createdAt.toLocal().toString().split(".")[0]}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      if (lastLogin != null)
                        Row(
                          children: [
                            const Icon(Icons.login,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Last Login: ${lastLogin.toLocal().toString().split(".")[0]}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 18, thickness: 1, color: Colors.grey, endIndent: 0),
            // Actions Row
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                IconButton(
                  icon: Icon(isDisabled ? Icons.lock_open : Icons.lock,
                      color: isDisabled ? Colors.green : Colors.red),
                  tooltip: isDisabled ? 'Enable User' : 'Disable User',
                  onPressed: onToggleStatus,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete User',
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                  tooltip: 'User Details',
                  onPressed: onShowDetails,
                ),
                IconButton(
                  icon: const Icon(Icons.list_alt, color: Colors.orange),
                  tooltip: 'Audit Log',
                  onPressed: onShowAuditLog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
