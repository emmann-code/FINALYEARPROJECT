// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';

String getMessageText(dynamic data) {
  if (data == null) return "[Debug] Message data is null";

  // Case 1: The data is a `Message` object from dialog_flowtter
  if (data is Message) {
    if (data.text != null &&
        data.text!.text != null &&
        data.text!.text!.isNotEmpty) {
      return data.text!.text!.first;
    }
    }
  // Case 2: The data is a `DialogText` object (likely from user input)
  else if (data is DialogText) {
    if (data.text != null && data.text!.isNotEmpty) {
      return data.text!.first;
      }
    }

  // Fallback for any other type, or if text is empty
  return "Sorry, I encountered an issue. Please try again.";
}

class MessagesScreen extends ConsumerStatefulWidget {
  final List messages;
  const MessagesScreen({super.key, required this.messages});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    // Auto-scroll to bottom when new messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          itemCount: widget.messages.length,
          separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
            final isUser = widget.messages[index]['isUserMessage'];
            final text = getMessageText(widget.messages[index]['message']);
            final timestamp = DateTime.now();

            return _buildMessageBubble(
              text: text,
              isUser: isUser,
              isDarkMode: isDarkMode,
              timestamp: timestamp,
              index: index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
    required bool isDarkMode,
    required DateTime timestamp,
    required int index,
  }) {
        return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
            children: [
          // Avatar for bot messages
          if (!isUser) ...[
              Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
                decoration: BoxDecoration(
                color: isUser
                    ? (isDarkMode ? Colors.blue.shade600 : Colors.blue.shade500)
                    : (isDarkMode ? Color(0xFF2D2D2D) : Colors.grey.shade50),
                  borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : (isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade200),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message header
                  if (!isUser)
                    Container(
                      padding: EdgeInsets.only(
                          left: 16, top: 12, right: 16, bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            "AI Assistant",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                            ),
                  ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                              "Online",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message content
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      isUser ? 12 : 0,
                      16,
                      12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                  text,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isUser
                                ? Colors.white
                                : (isDarkMode
                                    ? Colors.white
                                    : Colors.grey.shade800),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatTimestamp(timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isUser
                                ? Colors.white.withValues(alpha: 0.7)
                                : (isDarkMode
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar for user messages
          if (isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
                ),
              ),
          ],
            ],
          ),
        );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}
