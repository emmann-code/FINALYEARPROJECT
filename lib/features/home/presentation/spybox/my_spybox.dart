import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';

class Spyboxpage extends StatefulWidget {
  const Spyboxpage({super.key});

  @override
  State<Spyboxpage> createState() => _SpyboxpageState();
}

class _SpyboxpageState extends State<Spyboxpage> {
  final TextEditingController messageController = TextEditingController();
  bool isAnonymous = false;
  String? selectedCategory;
  String? selectedUrgency;

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

  // Send critical spy notice
  Future<void> _submitTipOff() async {
    // Prevent empty message submission
    if (messageController.text.trim().isEmpty || selectedCategory == null || selectedUrgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    try {
      // Get current user UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('SPYBOXTIPOFF').add({
        'Messagedescription': messageController.text,
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
        const SnackBar(content: Text('Tip Off Sent Successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),    
    appBar: AppBar(
        title:  Text("SpyBox", style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
        backgroundColor: const Color.fromARGB(255, 30, 30, 40),
        centerTitle: true,
      ),
    drawer: MyDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMessageInput(),
            const SizedBox(height: 30),
            _buildCategorySelector(),
            const SizedBox(height: 30),
            _buildUrgencySelector(),
            const SizedBox(height: 30),
            _buildAnonymitySwitch(),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: messageController,
      maxLines: 5,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black45,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        hintText: "Enter your tip-off message...",
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      dropdownColor: Colors.black54,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black45,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        labelText: "Select Category",
        labelStyle: const TextStyle(color: Colors.white),
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
    );
  }

  Widget _buildUrgencySelector() {
    return DropdownButtonFormField<String>(
      value: selectedUrgency,
      dropdownColor: Colors.black54,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black45,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        labelText: "Select Urgency Level",
        labelStyle: const TextStyle(color: Colors.white),
      ),
      items: urgencyLevels.map((String level) {
        return DropdownMenuItem<String>(
          value: level,
          child: Text(level),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedUrgency = newValue;
        });
      },
    );
  }

  Widget _buildAnonymitySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Send Anonymously", style: TextStyle(color: Colors.white)),
        Switch(
          value: isAnonymous,
          onChanged: (val) {
            setState(() {
              isAnonymous = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitTipOff,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
      ),
      child: const Text("Submit Tip", style: TextStyle(color: Colors.white)),
    );
  }
}
