import 'package:flutter/material.dart';

class Addcomplaintspage extends StatefulWidget {
  const Addcomplaintspage({super.key});

  @override
  State<Addcomplaintspage> createState() => _AddcomplaintspageState();
}

class _AddcomplaintspageState extends State<Addcomplaintspage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategory;
  bool isAnonymous = false;

  final List<String> categories = [
    "Service",
    "Product",
    "Other",
  ];

  final List<Map<String, String>> faqs = [
    {'question': 'How can I track my complaint?', 'answer': 'You can track it in the profile section.'},
    {'question': 'Can I submit a complaint anonymously?', 'answer': 'Yes, toggle the anonymity switch.'},
    {'question': 'What categories can I complain about?', 'answer': 'There are various categories including service, product, and others.'},
    {'question': 'How long does it take to process?', 'answer': 'Processing time varies based on severity.'},
    {'question': 'Can I attach an image?', 'answer': 'Yes, tap the camera icon to add an image.'},
    {'question': 'Will I receive updates on my complaint?', 'answer': 'Yes, you will be notified via email.'},
  ];

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

  void _submitComplaint() {
    // Here, you can integrate with Firebase or your backend to submit the complaint
    print("Complaint Submitted:");
    print("Name: ${nameController.text}");
    print("Title: ${titleController.text}");
    print("Description: ${descriptionController.text}");
    print("Category: $selectedCategory");
    print("Anonymity: $isAnonymous");

    // Optionally clear fields after submission
    nameController.clear();
    titleController.clear();
    descriptionController.clear();
    setState(() {
      selectedCategory = null;
      isAnonymous = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted successfully!')),
    );
  }
}
