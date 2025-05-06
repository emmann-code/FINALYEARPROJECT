// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';

// class HistoryScreen extends StatefulWidget {
//   HistoryScreen({Key? key}) : super(key: key);

//   @override
//   _HistoryScreenState createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   List<Map<String, dynamic>> _complaints = [];
//   bool _isLoading = true;

//   // List of all collection names to fetch complaints from
//   final List<String> collectionNames = [
//     "AcademicAdvisoryComplaints",
//     "CaferteriaComplaints",
//     "ChapelComplaints",
//     "CollegeComplaints",
//     "DepartmentComplaints",
//     "FinianceComplaints",
//     "HealthCareComplaints",
//     "HostelComplaints",
//     "ITSupportComplaints",
//     "LibraryComplaints",
//     "StudentAffairsComplaints",
//     "TechnicalComplaints",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadCachedComplaints().then((_) {
//       // Always fetch in the background even if cache is available.
//       _fetchAllComplaints();
//     });
//   }

//   // Load cached complaints from SharedPreferences if available
//   Future<void> _loadCachedComplaints() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? cachedData = prefs.getString('cachedComplaints');
//     if (cachedData != null) {
//       List<dynamic> decoded = json.decode(cachedData);
//       setState(() {
//         _complaints = decoded.cast<Map<String, dynamic>>();
//         _isLoading = false;
//       });
//     }
//   }

//   // Fetch complaints from all collections, combine them, cache, and update the UI.
//   // If cached data is already present, do not show a loading spinner.
//   Future<void> _fetchAllComplaints() async {
//     bool initialLoad = _complaints.isEmpty;
//     if (initialLoad) {
//       setState(() {
//         _isLoading = true;
//       });
//     }
//     List<Map<String, dynamic>> fetchedComplaints = [];
//     try {
//       // Loop through each collection and fetch its documents.
//       for (String collection in collectionNames) {
//         QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
//         for (var doc in snapshot.docs) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           fetchedComplaints.add({
//             'id': doc.id,
//             'title': data['title'] ?? 'No Title',
//             'image': data['image'] ?? 'assets/tst.png',
//             'collection': collection,
//             'timestamp': data['timestamp'] ?? 0, // Assumes a timestamp field exists
//           });
//         }
//       }

//       // Optional: sort the complaints by timestamp (latest first)
//       fetchedComplaints.sort((a, b) {
//         // If timestamp is a Firestore Timestamp, compare accordingly
//         if (a['timestamp'] is Timestamp && b['timestamp'] is Timestamp) {
//           return (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp);
//         } else if (a['timestamp'] is int && b['timestamp'] is int) {
//           return (b['timestamp'] as int).compareTo(a['timestamp'] as int);
//         } else {
//           return 0;
//         }
//       });

//       setState(() {
//         _complaints = fetchedComplaints;
//         _isLoading = false;
//       });

//       // Cache the fetched complaints as JSON
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('cachedComplaints', json.encode(fetchedComplaints));
//     } catch (e) {
//       print('Error fetching complaints: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Refresh complaints manually (e.g., via pull-to-refresh)
//   Future<void> _refreshComplaints() async {
//     await _fetchAllComplaints();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 46, 44, 53),
//       drawer: MyDrawer(),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 30, 30, 40),
//         elevation: 0,
//         title: Padding(
//           padding: const EdgeInsets.only(top: 10),
//           child: Text(
//             "List of Complaints",
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               shadows: [
//                 const Shadow(blurRadius: 10, color: Colors.black87, offset: Offset(2, 2))
//               ],
//             ),
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: _isLoading && _complaints.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: _refreshComplaints,
//               child: _complaints.isNotEmpty
//                   ? ListView.builder(
//                       padding: const EdgeInsets.all(16.0),
//                       itemCount: _complaints.length,
//                       itemBuilder: (context, index) {
//                         var complaint = _complaints[index];
//                         String dateString = '';
//                         if (complaint['timestamp'] != null && complaint['timestamp'] != 0) {
//                           DateTime dt;
//                           var ts = complaint['timestamp'];
//                           if (ts is Timestamp) {
//                             dt = ts.toDate();
//                           } else if (ts is int) {
//                             dt = DateTime.fromMillisecondsSinceEpoch(ts);
//                           } else {
//                             dt = DateTime.now();
//                           }
//                           dateString = DateFormat('yyyy-MM-dd – HH:mm').format(dt);
//                         }
//                         return ComplaintCard(
//                           id: complaint['id'] ?? 'N/A',
//                           title: complaint['title'] ?? '',
//                           imagePath: complaint['image'] ?? 'assets/tst.png',
//                           date: dateString,
//                         );
//                       },
//                     )
//                   : Center(child: Text('No complaints found.', style: TextStyle(color: Colors.white))),
//             ),
//     );
//   }
// }

// class ComplaintCard extends StatelessWidget {
//   final String id;
//   final String title;
//   final String date;
//   final String imagePath;

//   const ComplaintCard({
//     Key? key,
//     required this.id,
//     required this.title,
//     required this.imagePath,
//     required this.date,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.black87,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         trailing: Image.asset(imagePath, width: 80, height: 60, fit: BoxFit.cover),
//         title: Text(
//           "Complaint $id",
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Submitted: $date', style: const TextStyle(fontSize: 14, color: Colors.grey)),
//             const SizedBox(height: 4),
//             Text("Title: $title", style: const TextStyle(fontSize: 14, color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;

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
    _loadCachedComplaints().then((_) {
      // Always fetch in the background even if cache is available.
      _fetchAllComplaints();
    });
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
        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
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
          return (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp);
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
      print('Error fetching complaints: $e');
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
        title: Text('Delete Complaint'),
        content: Text('Are you sure you want to delete this complaint?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Delete')),
        ],
      ),
    );
    if (confirmed) {
      try {
        String collection = complaint['collection'];
        String id = complaint['id'];
        await FirebaseFirestore.instance.collection(collection).doc(id).delete();
        setState(() {
          _complaints.removeWhere((c) => c['id'] == id && c['collection'] == collection);
        });
        // Optionally, update the cache
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('cachedComplaints', json.encode(_complaints));
      } catch (e) {
        print('Error deleting complaint: $e');
      }
    }
  }

  // Refresh complaints manually (e.g., via pull-to-refresh)
  Future<void> _refreshComplaints() async {
    await _fetchAllComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 30, 40),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "List of Complaints",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                const Shadow(blurRadius: 10, color: Colors.black87, offset: Offset(2, 2))
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading && _complaints.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshComplaints,
              child: _complaints.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _complaints.length,
                      itemBuilder: (context, index) {
                        var complaint = _complaints[index];
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
                          dateString = DateFormat('yyyy-MM-dd – HH:mm').format(dt);
                        }
                        return ModernComplaintTile(
                          complaint: complaint,
                          date: dateString,
                          onDelete: () => _deleteComplaint(complaint),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComplaintDetailScreen(complaint: complaint, date: dateString),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Center(child: Text('No complaints found.', style: TextStyle(color: Colors.white))),
            ),
    );
  }
}

/// A modern styled complaint tile with delete functionality.
class ModernComplaintTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Optionally, add a leading avatar/image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(complaint['image'] ?? 'assets/tst.png', width: 70, height: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Complaint ${complaint['id']}",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint['title'] ?? 'No Title',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDelete,
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Detail screen for a complaint, styled like a chat or feedback space.
class ComplaintDetailScreen extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final String date;

  const ComplaintDetailScreen({
    Key? key,
    required this.complaint,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the submission date/time using the provided date string.
    // Admin reply is fetched from complaint['adminReply'] if exists.
    String adminReply = complaint['adminReply'] ?? "Pending - Your complaint will be addressed soon.";
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint Details", style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 30, 30, 40),
      ),
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint Basic Information
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( "Complaint ${complaint['id'].toString().length > 6 ? complaint['id'].toString().substring(0, 6) : complaint['id']}", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.grey),),
                    const SizedBox(height: 8),
                    Text("Title: ${complaint['title']}", style: GoogleFonts.poppins(fontSize: 14,color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text("Description: ${complaint['description']}", style: GoogleFonts.poppins(fontSize: 14,color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text("Category: ${complaint['category']}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey), ),
                    const SizedBox(height: 8),
                    Text("Submitted: $date", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    // Additional fields as needed
                    if (complaint['isAnonymous'] != null)
                      Text("Submitted by: ${complaint['isAnonymous']}", style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chat style admin reply section
            Text("Admin Reply", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
              ),
              child: Text(adminReply, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}
