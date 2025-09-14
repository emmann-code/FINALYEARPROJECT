// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_to_list_in_spreads

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mtu_connect_hub/features/profile/presentation/settings_screen.dart';

class LibraryHelpComplaintsPage extends ConsumerStatefulWidget {
  const LibraryHelpComplaintsPage({super.key});

  @override
  ConsumerState<LibraryHelpComplaintsPage> createState() =>
      _LibraryHelpComplaintsPageState();
}

class _LibraryHelpComplaintsPageState
    extends ConsumerState<LibraryHelpComplaintsPage>
    with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController matricController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedCategory;
  bool isAnonymous = false;
  XFile? imageFile;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> categories = [
    "Book Availability",
    "Research Assistance",
    "Study Space",
    "Online Resources",
        "Printing Services", 
    "Library Hours",
    "Database Access",
    "Interlibrary Loan",
    "Reference Services",
    "Library Workshops",
    "Other",
  ];

  final List<Map<String, String>> faqs = [
    {
      'question': 'How can I track my complaint?',
      'answer': 'You can track it in the profile section.'
    },
    {
      'question': 'Can I submit a complaint anonymously?',
      'answer': 'Yes, toggle the anonymity switch.'
    },
    {
      'question': 'What categories can I complain about?',
      'answer':
          'There are various categories including service, product, and others.'
    },
    {
      'question': 'How long does it take to process?',
      'answer': 'Processing time varies based on severity.'
    },
    {
      'question': 'Can I attach an image?',
      'answer': 'Yes, tap the camera icon to add an image.'
    },
    {
      'question': 'Will I receive updates on my complaint?',
      'answer': 'Yes, you will be notified via email.'
    },
    {
      "question": "How do I borrow books from the library?",
      "answer":
          "Present your student ID at the circulation desk to borrow books. You can also use the self-checkout system."
    },
    {
      "question": "What are the library hours?",
      "answer":
          "The library is open from 8:00 AM to 10:00 PM on weekdays and 9:00 AM to 6:00 PM on weekends."
    },
    {
      "question": "How do I access online databases?",
      "answer":
          "Access online databases through the library's website using your student credentials."
    },
    {
      "question": "Can I reserve study rooms?",
      "answer":
          "Yes, study rooms can be reserved online or at the library desk for group study sessions."
    },
    {
      "question": "How do I request a book that's not available?",
      "answer":
          "Use the interlibrary loan service or request the book through the library's online catalog."
    },
    {
      "question": "What printing services are available?",
      "answer":
          "The library offers printing, scanning, and photocopying services. Payment can be made with your student account."
    },
    {
      "question": "How do I get research assistance?",
      "answer":
          "Visit the reference desk or schedule an appointment with a librarian for research assistance."
    },
    {
      "question": "Are there library workshops available?",
      "answer":
          "Yes, the library regularly conducts workshops on research skills, citation, and database usage."
    },
    {
      "question": "How do I renew my borrowed books?",
      "answer":
          "Renew books online through your library account or contact the circulation desk."
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1200));
    _slideController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    nameController.dispose();
    matricController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
  
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

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('complaint_images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = storageRef.putFile(File(imageFile!.path));

  final snapshot = await uploadTask.whenComplete(() {});
  final imageUrl = await snapshot.ref.getDownloadURL();
  return imageUrl;
}

  Future<void> _submitComplaint() async {
    String imageUrl = await _uploadImageToFirebase();
      String? userId = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance.collection('LibraryHelpComplaints').add({
      'name': nameController.text,
      'matric': matricController.text,
      'title': titleController.text,
      'description': descriptionController.text,
      'category': selectedCategory,
      'isAnonymous': isAnonymous ? "Anonymous" : userId,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'datestamp': DateTime.now(),
    });

    nameController.clear();
    matricController.clear();
    titleController.clear();
    descriptionController.clear();
    setState(() {
      selectedCategory = null;
      isAnonymous = false;
      imageFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complaint submitted successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.blue.shade700),
        title: Text(
          'Library Help Office',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.blue.shade700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Color(0xFF1A1A1A),
                    Color(0xFF121212),
                    Color(0xFF1A1A1A),
                  ]
                : [
                    Colors.blue.shade50,
                    Colors.white,
                    Colors.blue.shade50,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
          child: Column(
            children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Color(0xFF2D2D2D)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.library_books,
                            size: 40,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Submit Your Complaint',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We\'re here to help resolve your library concerns',
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
                ),

                SizedBox(height: 24),

                // Form Section
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildComplaintForm(isDarkMode),
                ),

                SizedBox(height: 24),

                // FAQ Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildFAQSection(isDarkMode),
                ),

                SizedBox(height: 24),

                // Submit Button
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _submitComplaint,
                        child: Center(
                          child: Text(
                            "Submit Complaint",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintForm(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Complaint Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 20),

          _buildModernTextField(
              "Full Name", nameController, Icons.person_outlined, isDarkMode),
          SizedBox(height: 16),

          _buildModernTextField("Matric Number", matricController,
              Icons.badge_outlined, isDarkMode),
          SizedBox(height: 16),

          _buildModernTextField("Complaint Title", titleController,
              Icons.title_outlined, isDarkMode),
          SizedBox(height: 16),

          _buildModernTextField("Description", descriptionController,
              Icons.description_outlined, isDarkMode,
              maxLines: 4),
          SizedBox(height: 16),

          _buildModernCategorySelector(isDarkMode),
          SizedBox(height: 20),

          // Image Upload Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF2D2D2D) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: Colors.blue.shade600, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attach Image (Optional)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Add supporting images to your complaint',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: Icon(Icons.add_photo_alternate,
                      color: Colors.blue.shade600),
                ),
              ],
            ),
          ),

          if (imageFile != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF2D2D2D) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDarkMode
                        ? Colors.blue.shade700
                        : Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.blue.shade600, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Image selected: ${imageFile!.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.blue.shade300
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 20),

          // Anonymity Toggle
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Color(0xFF2D2D2D) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.privacy_tip_outlined,
                    color: Colors.blue.shade600, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit Anonymously',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Your identity will be hidden',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isAnonymous,
                  onChanged: (val) {
                    setState(() {
                      isAnonymous = val;
                    });
                  },
                  activeColor: Colors.blue.shade600,
                ),
              ],
            ),
            ),
          ],
      ),
    );
  }

  Widget _buildModernTextField(String label, TextEditingController controller,
      IconData icon, bool isDarkMode,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF2D2D2D) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
          ),
          child: TextField(
          controller: controller,
          maxLines: maxLines,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
              fontSize: 16,
            ),
          decoration: InputDecoration(
            hintText: "Enter $label",
              hintStyle: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: Colors.blue.shade600, size: 20),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernCategorySelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF2D2D2D) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
          value: selectedCategory,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.grey.shade800,
              fontSize: 16,
            ),
          decoration: InputDecoration(
              hintText: "Select a category",
              hintStyle: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 16,
              ),
              prefixIcon: Icon(Icons.category_outlined,
                  color: Colors.blue.shade600, size: 20),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue.shade600, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                  'Frequently Asked Questions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.blue.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...faqs.map((faq) {
          return ExpansionTile(
              collapsedBackgroundColor: Colors.transparent,
              backgroundColor:
                  isDarkMode ? Color(0xFF2D2D2D) : Colors.grey.shade50,
              title: Text(
                faq['question']!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? Colors.grey.shade200 : Colors.grey.shade800,
                ),
              ),
            children: [
              Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    faq['answer']!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
        ],
      ),
    );
  }
}
