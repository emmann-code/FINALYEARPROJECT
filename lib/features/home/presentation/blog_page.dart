import 'package:flutter/material.dart';

class BlogPostCard extends StatelessWidget {
  final String title;
  final String date;
  final String content;

  const BlogPostCard({
    super.key,
    required this.title,
    required this.date,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(date,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          BlogPostCard(
            title: 'Water Supply Restored in Hostel Block A',
            date: '2025-05-14',
            content:
                'After several complaints about irregular water supply in Hostel Block A, the maintenance team responded swiftly. Within 48 hours, faulty pipes were replaced and water supply was fully restored. Students expressed appreciation for the quick resolution.'
          ),
          SizedBox(height: 16),
          BlogPostCard(
            title: 'Library Wi-Fi Connectivity Improved',
            date: '2025-04-28',
            content:
                'Students raised concerns about poor Wi-Fi in the library. The IT department upgraded the routers and added more access points. Now, students enjoy seamless internet access for research and assignments.'
          ),
          SizedBox(height: 16),
          BlogPostCard(
            title: 'Leaking Lecture Hall Roof Fixed',
            date: '2025-03-10',
            content:
                'A leaking roof in Lecture Hall 3 was reported during the rainy season. The facilities team inspected and repaired the roof, ensuring a dry and comfortable learning environment for all.'
          ),
        ],
      ),
    );
  }
}
