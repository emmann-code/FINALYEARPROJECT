import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class ChapelComplaintsPage extends StatefulWidget {
  const ChapelComplaintsPage({super.key});

  @override
  State<ChapelComplaintsPage> createState() => _ChapelComplaintsPageState();
}

class _ChapelComplaintsPageState extends State<ChapelComplaintsPage> {
  final TextEditingController nameController = TextEditingController();
    final TextEditingController matricController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategory;
  bool isAnonymous = false;
  XFile? imageFile; // For holding the selected image


  final List<String> categories = [
    "Worship Services",
     "Spiritual Counseling",
    "Community Outreach",
     "Volunteer Opportunities",
    "Bible Study",
   "Missionary Work", 
    "Religious Holidays", 
    "Event Organizing", 
    "Counseling Sessions",
    "Spiritual Retreats"
    "Other",
  ];

  final List<Map<String, String>> faqs = [
    {'question': 'How can I track my complaint?', 'answer': 'You can track it in the profile section.'},
    {'question': 'Can I submit a complaint anonymously?', 'answer': 'Yes, toggle the anonymity switch.'},
    {'question': 'What categories can I complain about?', 'answer': 'There are various categories including service, product, and others.'},
    {'question': 'How long does it take to process?', 'answer': 'Processing time varies based on severity.'},
    {'question': 'Can I attach an image?', 'answer': 'Yes, tap the camera icon to add an image.'},
    {'question': 'Will I receive updates on my complaint?', 'answer': 'Yes, you will be notified via email.'},
    {"question": "What are the chapel service times?", "answer": "Chapel services are held on Sundays at 10:00 am and Wednesdays at 4:30 pm plus daily Morning devotions."},
  {"question": "How can I volunteer for chapel services?", "answer": "Contact the Chapel Office to sign up for volunteering opportunities during services."},
  {"question": "Is there a chapel choir?", "answer": "Yes, the chapel has a choir. Interested students can join by contacting the Chapel Office."},
  {"question": "How can I schedule a meeting with the chaplain?", "answer": "Appointments can be made by contacting the Chapel Office directly."},
  {"question": "Are there any Bible study groups?", "answer": "Yes, the Chapel Office organizes Bible study groups. Inquire at the office for meeting times."},
  {"question": "Can I host a religious event in the chapel?", "answer": "To host an event, request approval from the Chapel Office, providing necessary details."},
  {"question": "What events are organized by the chapel?", "answer": "The chapel organizes regular prayer meetings, religious conferences, and fellowship gatherings."},
  {"question": "How do I donate to the chapel?", "answer": "Donations can be made directly at the Chapel Office or via the university's online donation portal."},
  {"question": "Are there any prayer rooms on campus?", "answer": "The Chapel Office provides information on available prayer rooms on campus."},
  {"question": "What is the chapel's role in student life?", "answer": "The chapel supports spiritual growth through services, counseling, and community activities."}
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  Future<String> _uploadImageToFirebase() async {
  if (imageFile == null) return '';

  final storageRef = FirebaseStorage.instance.ref().child('complaint_images/${DateTime.now().millisecondsSinceEpoch}');
  final uploadTask = storageRef.putFile(File(imageFile!.path));  // Use File(imageFile!.path) directly

  final snapshot = await uploadTask.whenComplete(() {});
  final imageUrl = await snapshot.ref.getDownloadURL();
  return imageUrl;
}

  Future<void> _submitComplaint() async {
    // Upload image to Firebase Storage
    String imageUrl = await _uploadImageToFirebase();

    
     // Get current user UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Send complaint data to Firestore
    await FirebaseFirestore.instance.collection('ChapelComplaints').add({
      'name': nameController.text,
      'matric':matricController.text,
      'title': titleController.text,
      'description': descriptionController.text,
      'category': selectedCategory,
      'isAnonymous': isAnonymous ? "Anonymous" : userId,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'datestamp':DateTime.now(),
    });

    // Optionally clear fields after submission
    nameController.clear();
    matricController.clear();
    titleController.clear();
    descriptionController.clear();
    setState(() {
      selectedCategory = null;
      isAnonymous = false;
      imageFile = null; // Reset the image after submission
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 44, 53),
        title: const Text('Add Complaint', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildComplaintForm(),
              const SizedBox(height: 10),
              _buildFAQSection(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                ),
                child: const Text('Submit Your Complaint', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintForm() {
    return Card(
      color: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Name", nameController),
            _buildTextField("Matric",matricController),
            _buildTextField("Title", titleController),
            _buildTextField("Description", descriptionController, maxLines: 3),
            _buildCategorySelector(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Additional Information', style: TextStyle(color: Colors.white)),
                const Icon(Icons.camera_alt, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Anonymity', style: TextStyle(color: Colors.white)),
                Switch(
                  value: isAnonymous,
                  onChanged: (val) {
                    setState(() {
                      isAnonymous = val;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            hintText: "Enter $label",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Category", style: TextStyle(color: Colors.white)),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          dropdownColor: Colors.black54,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black45,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue;
            });
          },
          hint: const Text("Select a category", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Card(
      color: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: faqs.map((faq) {
          return ExpansionTile(
            collapsedBackgroundColor: Colors.black54,
            backgroundColor: Colors.black87,
            title: Text(faq['question']!, style: const TextStyle(color: Colors.white)),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(faq['answer']!, style: const TextStyle(color: Colors.grey)),
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}