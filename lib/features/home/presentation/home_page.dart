import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/home/data/my_complaint.dart';
import 'package:mtu_connect_hub/features/home/presentation/user_virtual_admin/virtual_hub.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isMainAdmin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 44, 53),
      drawer: MyDrawer(),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 30, 40),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton("Main Admins", isMainAdmin, () {
                    setState(() {
                      isMainAdmin = true;
                    });
                  }),
                  const SizedBox(width: 13,),
                  _buildToggleButton("Virtual Admin", !isMainAdmin, () {
                    setState(() {
                      isMainAdmin = false;
                    });
                  }),
                ],
              ),
            ),
            Expanded(
              child: isMainAdmin ? _buildMainAdminGrid() : _buildVirtualAdminUI(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ?  Color.fromARGB(255, 101, 88, 182) : Colors.black ,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          text,
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
    );
  }

  Widget _buildMainAdminGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: mainAdminOffices.length,
      itemBuilder: (context, index) {
        return _buildOfficeCard(mainAdminOffices[index]);
      },
    );
  }

  Widget _buildVirtualAdminUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(child: Padding(
               padding: const EdgeInsets.only(bottom: 10),
               child:virtualhub(),
             )),
            _buildAdminCard(),
            const SizedBox(height: 20),
            Center(child: _buildRulesBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text("Description", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
          SizedBox(height: 10),
          Text("Manage your virtual administrative tasks with ease. Virtual Admin provides an accessible, user-friendly, and secure platform for students to submit complaints and voice their concerns. By using the VIRTUAL Complaint Box, students can contribute to the ongoing improvement of MTU's academic and non-academic environment, ensuring a positive and productive learning experience for all.", style: TextStyle(color: Colors.grey,fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRulesBox() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("Rules to follow" 
            , style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Text("1. Be professional, specific and detailed\n2. Use respectful language\n3. Provide evidence or examples\n4. Avoid submitting duplicate complaints", style: TextStyle(color: Colors.grey,fontSize: 12)),
        ],
      ),
    );
  }

  // Widget _buildOfficeCard(String office) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade900,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         CircleAvatar(
  //           radius: 30,
  //           backgroundColor: Colors.grey.shade700,
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           office,
  //           style: const TextStyle(color: Colors.white, fontSize: 16),
  //         ),
  //         const SizedBox(height: 5),
  //         IconButton( 
  //           onPressed: (){
  //           Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => Addcomplaintspage()),
  //               );
  //         }, color: Colors.white, icon: const Icon(Icons.chevron_right_outlined),),
  //       ],
  //     ),
  //   );
  // }





  Widget _buildOfficeCard(String office) {
  // Map office names to asset image paths
  final Map<String, String> officeImages = {
    "Department Office": "assets/department.png",
    "College Office": "assets/college.png",
    "Hostel Office": "assets/hostemain.png",
    "Chapel Office": "assets/chapel.png",
    "Health Care Office": "assets/healthcare.png",
    "Cafeteria Office": "assets/caferteria.png",
    "IT Support": "assets/ICT.png",
    "Library Help": "assets/library.png",
    "Student Affairs": "assets/studentaffairs.png",
    "Finance Assistance": "assets/finiance.png",
    "Academic Advisory": "assets/academicadvise.png",
    "Technical Support": "assets/technicalsupport.png",
  };

  // Use default image if no specific image is found
  String imagePath = officeImages[office] ?? "assets/studentaffairs.png";

  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade900,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade300,
          backgroundImage: AssetImage(imagePath), // Use image as avatar background
        ),
        const SizedBox(height: 10),
        Text(
          office,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 5),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Addcomplaintspage()),
            );
          },
          color: Colors.white,
          icon: const Icon(Icons.chevron_right_outlined),
        ),
      ],
    ),
  );
}






  Widget virtualhub(){
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ImageIcon(
            AssetImage('assets/complaints_box.png'), 
            size: 100.0,
            color: Colors.blueAccent,
          ),
          const Text(
            'Virtual Hub',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          IconButton( 
            onPressed: (){
            Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => virtualhubpage()),
                );
          }, color: Colors.white, icon: const Icon(Icons.chevron_right_outlined),),
        ],
      ),
    );
  }
}

const List<String> mainAdminOffices = [
  "Department Office",
  "College Office",
  "Hostel Office",
  "Chapel Office",
  "Health Care Office",
  "Cafeteria Office",
  "IT Support",
  "Library Help",
  "Student Affairs",
  "Finance Assistance",
  "Academic Advisory",
  "Technical Support"
];
