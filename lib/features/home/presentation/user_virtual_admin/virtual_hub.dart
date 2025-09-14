// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_virtual_admin/messages.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dialog_flowtter/dialog_flowtter.dart';

class VirtualHubPage extends ConsumerStatefulWidget {
  const VirtualHubPage({super.key});

  @override
  ConsumerState<VirtualHubPage> createState() => VirtualHubPageState();
}

class VirtualHubPageState extends ConsumerState<VirtualHubPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  DialogFlowtter? dialogFlowtter;
  List<Map<String, dynamic>> messages = [];
  bool _isBotTyping = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initDialogFlowtter();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _initDialogFlowtter() {
    try {
      dialogFlowtter = DialogFlowtter();
      print("DialogFlowtter initialized successfully");
      setState(() {});
    } catch (e) {
      print("DialogFlowtter initialization failed: $e");
      // Keep dialogFlowtter as null to use fallback responses
    setState(() {});
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          _isTyping = _searchController.text.isNotEmpty;
        });
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        localeId: "en_US",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Speech recognition not available"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _sendMessage() async {
    if (_searchController.text.isEmpty) return;

    final input = _searchController.text.trim();

    setState(() {
      messages.add({
        "message": DialogText(text: [input]),
        "isUserMessage": true,
      });
      _isTyping = false;
      _searchController.clear();
      _isBotTyping = true;
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Fallback response when DialogFlowtter is not available
    if (dialogFlowtter == null) {
      await Future.delayed(Duration(seconds: 1)); // Simulate processing time
      setState(() {
        messages.add({
          "message": DialogText(text: [
            "Hello! I'm the MTU Connect-Hub AI assistant. I'm currently in maintenance mode. Please contact your department directly for immediate assistance or use the office-specific pages for detailed help."
          ]),
          "isUserMessage": false,
        });
      });
      setState(() => _isBotTyping = false);
      return;
    }

    try {
    final response = await dialogFlowtter!.detectIntent(
      queryInput: QueryInput(text: TextInput(text: input)),
    );

    if (response.message != null) {
      setState(() {
        messages.add({
          "message": response.message!,
          "isUserMessage": false,
        });
      });
    } else {
      setState(() {
        messages.add({
            "message": DialogText(text: [
              "Sorry, I didn't understand that. Could you please rephrase your question?"
            ]),
            "isUserMessage": false,
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "message": DialogText(text: [
            "Sorry, I'm having trouble connecting right now. Please try again later or contact your department directly for immediate assistance."
          ]),
          "isUserMessage": false,
        });
      });
    }

    setState(() => _isBotTyping = false);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFF8F9FA),
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.blue.shade600,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
          'Virtual Hub',
                  style: GoogleFonts.poppins(
            fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                Text(
                  'MTU CONNECT HUB',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.grey.shade800,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Welcome Header
              if (messages.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
        children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.smart_toy,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "How can I help you today?",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Ask me anything about MTU services, departments, or general inquiries",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // Messages Area
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Color(0xFF2D2D2D)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode
                                        ? Colors.black.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 48,
                                    color: isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Start a conversation",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                        Text(
                                    "Type your message below or use voice input",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: MessagesScreen(messages: messages),
                      ),
              ),

              // Bot Typing Indicator
              if (_isBotTyping)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF2D2D2D) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade200,
                    ),
                  ),
              child: Row(
                children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.smart_toy,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                      ),
                  SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MTU CONNECT HUB",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue.shade600,
                                    ),
                                  ),
                                ),
                  SizedBox(width: 8),
                                Text(
                                  "Typing...",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
                    ],
                  ),
                ),

              // Input Area
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
                        onChanged: (text) =>
                            setState(() => _isTyping = text.isNotEmpty),
                        onSubmitted: (_) => _sendMessage(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color:
                              isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
              decoration: InputDecoration(
                          hintText: "Type your message...",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          filled: false,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Row(
                        children: [
                          // Voice Button
                          Container(
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? Colors.red.shade100
                                  : isDarkMode
                                      ? Color(0xFF3D3D3D)
                                      : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? Colors.red.shade600
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: _isListening
                                  ? _stopListening
                                  : _startListening,
                              tooltip: _isListening
                                  ? "Stop listening"
                                  : "Start voice input",
                            ),
                          ),
                          SizedBox(width: 8),
                          // Send Button
                          Container(
                            decoration: BoxDecoration(
                              color: _isTyping
                                  ? Colors.blue.shade600
                                  : isDarkMode
                                      ? Color(0xFF3D3D3D)
                                      : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.send,
                                color: _isTyping
                                    ? Colors.white
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: _isTyping ? _sendMessage : null,
                              tooltip: "Send message",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
