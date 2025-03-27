import 'package:flutter/material.dart';

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
    "Other",
  ];

  final List<String> urgencyLevels = [
    "Normal",
    "High",
    "Critical",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      appBar: AppBar(
        title: const Text("SpyBox", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 30, 30, 40),
        centerTitle: true,
      ),
      drawer: _buildSpyBoxDrawer(),
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

  Widget _buildSpyBoxDrawer() {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 30, 30, 40),
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
            child: Text("SpyBox Navigation", style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.white),
            title: const Text("Report Issue", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.white),
            title: const Text("Privacy Policy", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.white),
            title: const Text("Safety Guidelines", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Exit", style: TextStyle(color: Colors.redAccent)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: messageController,
      maxLines: 4,
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
      onPressed: _submitTip,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
      ),
      child: const Text("Submit Tip", style: TextStyle(color: Colors.white)),
    );
  }

  void _submitTip() {
    print("Tip Submitted:");
    print("Message: ${messageController.text}");
    print("Category: $selectedCategory");
    print("Urgency: $selectedUrgency");
    print("Anonymity: $isAnonymous");

    // Clear fields after submission
    messageController.clear();
    setState(() {
      selectedCategory = null;
      selectedUrgency = null;
      isAnonymous = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tip sent successfully!")),
    );
  }
}
