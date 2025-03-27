import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class virtualhubpage extends StatefulWidget {
  const virtualhubpage({super.key});

  @override
  _virtualhubpageState createState() => _virtualhubpageState();
}

class _virtualhubpageState extends State<virtualhubpage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isTyping = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          _isTyping = _searchController.text.isNotEmpty;
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text("Virtual Hub"),
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What can I help with?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Image.asset('assets/ai_robot.png', height: 100),
                ],
              ),
            ),
          ),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (text) {
                setState(() => _isTyping = text.isNotEmpty);
              },
              decoration: InputDecoration(
                hintText: "Ask anything",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: _isListening ? Colors.red : Colors.black),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          IconButton(
            icon: Icon(Icons.send, color: _isTyping ? Colors.green : Colors.grey),
            onPressed: _isTyping ? () {} : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green[800]),
            child: Text("Virtual Hub Menu", style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text("Previous Chats"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text("New Chat"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
