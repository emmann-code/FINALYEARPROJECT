import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, String>> complaints = [
    {
      'id': '001',
      'title': 'Parking Area',
      'image': 'assets/tst.png',
    },
    {
      'id': '002',
      'title': 'No Cleanliness in Boys Bathroom',
      'image': 'assets/tst.png',
    },
    {
      'id': '003',
      'title': 'Broken Bench',
      'image': 'assets/tst.png',
    },
    {
      'id': '004',
      'title': 'No Water in Bathroom',
      'image': 'assets/tst.png',
    },
    {
      'id': '005',
      'title': 'Ragging in Class',
      'image': 'assets/tst.png',
    },
  ];

   HistoryScreen({super.key});

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
            style: GoogleFonts.aboreto(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(blurRadius: 10, color:  Colors.black87, offset: Offset(2, 2))
                  ],
                ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            return ComplaintCard(
              id: complaints[index]['id']!,
              title: complaints[index]['title']!,
              imagePath: complaints[index]['image']!,
            );
          },
        ),
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final String id;
  final String title;
  final String imagePath;

  const ComplaintCard({super.key, 
    required this.id,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        trailing: Image.asset(imagePath, width: 80, height: 60, fit: BoxFit.cover),
        title: Text(
          "Complaint $id",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          "Title: $title",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }
}


