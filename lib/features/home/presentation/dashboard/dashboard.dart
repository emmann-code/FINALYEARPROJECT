import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Variables to store the count of complaints
  int academicAdvisoryComplaintsCount = 0;
  int cafeteriaComplaintsCount = 0;
  int chapelComplaintsCount = 0;
  int collegeComplaintsCount = 0;
  int departmentComplaintsCount = 0;
  int financeComplaintsCount = 0;
  int healthcareComplaintsCount = 0;
  int hostelComplaintsCount = 0;
  int itSupportComplaintsCount = 0;
  int libraryComplaintsCount = 0;
  int studentAffairsComplaintsCount = 0;
  int technicalComplaintsCount = 0;

  int totalComplaintsCount = 0;
  String selectedStatus = "All";

  static const Map<String, Color> categoryColors = {
    "AcademicAdvisoryComplaints": Colors.blue,
    "CaferteriaComplaints": Colors.orange,
    "ChapelComplaints": Colors.purple,
    "CollegeComplaints": Colors.green,
    "DepartmentComplaints": Colors.red,
    "FinianceComplaints": Colors.teal,
    "HealthCareComplaints": Colors.pink,
    "HostelComplaints": Colors.brown,
    "ITSupportComplaints": Colors.indigo,
    "LibraryComplaints": Colors.yellow,
    "StudentAffairsComplaints": Colors.cyan,
    "TechnicalComplaints": Colors.deepPurple,
  };

 @override
  void initState() {
    super.initState();
    // Load cached complaint counts if available
    loadCachedComplaintCounts();
    // Fetch complaint counts when the screen is initialized
    fetchComplaintCounts();
    loadCachedComplaintCounts();

  }

  // Fetch the number of complaints from multiple collections

 Future<void> loadCachedComplaintCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    academicAdvisoryComplaintsCount = prefs.getInt('AcademicAdvisoryComplaints') ?? 0;
    cafeteriaComplaintsCount = prefs.getInt('CaferteriaComplaints') ?? 0;
    chapelComplaintsCount = prefs.getInt('ChapelComplaints') ?? 0;
    collegeComplaintsCount = prefs.getInt('CollegeComplaints') ?? 0;
    departmentComplaintsCount = prefs.getInt('DepartmentComplaints') ?? 0;
    financeComplaintsCount = prefs.getInt('FinianceComplaints') ?? 0;
    healthcareComplaintsCount = prefs.getInt('HealthCareComplaints') ?? 0;
    hostelComplaintsCount = prefs.getInt('HostelComplaints') ?? 0;
    itSupportComplaintsCount = prefs.getInt('ITSupportComplaints') ?? 0;
    libraryComplaintsCount = prefs.getInt('LibraryComplaints') ?? 0;
    studentAffairsComplaintsCount = prefs.getInt('StudentAffairsComplaints') ?? 0;
    technicalComplaintsCount = prefs.getInt('TechnicalComplaints') ?? 0;

    totalComplaintsCount = academicAdvisoryComplaintsCount +
        cafeteriaComplaintsCount +
        chapelComplaintsCount +
        collegeComplaintsCount +
        departmentComplaintsCount +
        financeComplaintsCount +
        healthcareComplaintsCount +
        hostelComplaintsCount +
        itSupportComplaintsCount +
        libraryComplaintsCount +
        studentAffairsComplaintsCount +
        technicalComplaintsCount;

    setState(() {}); // Update the UI
  }


// Fetch the number of complaints from multiple collections
  
  Future<void> fetchComplaintCounts() async {
    try {
      academicAdvisoryComplaintsCount = await _getComplaintCount('AcademicAdvisoryComplaints');
      cafeteriaComplaintsCount = await _getComplaintCount('CaferteriaComplaints');
      chapelComplaintsCount = await _getComplaintCount('ChapelComplaints');
      collegeComplaintsCount = await _getComplaintCount('CollegeComplaints');
      departmentComplaintsCount = await _getComplaintCount('DepartmentComplaints');
      financeComplaintsCount = await _getComplaintCount('FinianceComplaints');
      healthcareComplaintsCount = await _getComplaintCount('HealthCareComplaints');
      hostelComplaintsCount = await _getComplaintCount('HostelComplaints');
      itSupportComplaintsCount = await _getComplaintCount('ITSupportComplaints');
      libraryComplaintsCount = await _getComplaintCount('LibraryComplaints');
      studentAffairsComplaintsCount = await _getComplaintCount('StudentAffairsComplaints');
      technicalComplaintsCount = await _getComplaintCount('TechnicalComplaints');

      // Calculating the total number of complaints
      totalComplaintsCount = academicAdvisoryComplaintsCount +
          cafeteriaComplaintsCount +
          chapelComplaintsCount +
          collegeComplaintsCount +
          departmentComplaintsCount +
          financeComplaintsCount +
          healthcareComplaintsCount +
          hostelComplaintsCount +
          itSupportComplaintsCount +
          libraryComplaintsCount +
          studentAffairsComplaintsCount +
          technicalComplaintsCount;

      // Trigger a rebuild when the data is fetched
      setState(() {});
    } catch (e) {
      // Handle errors if fetching fails
      print("Error fetching complaints: $e");
    }
  }

  // Method to get complaint count from each collection
  Future<int> _getComplaintCount(String collectionName) async {
    try {
      Query query = FirebaseFirestore.instance.collection(collectionName);
      if (selectedStatus != "All") {
        query = query.where('status', isEqualTo: selectedStatus);
      }
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      print("Error fetching data from $collectionName: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Complaint Dashboard",
        style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
        actions: [
          DropdownButton<String>(
            value: selectedStatus,
            onChanged: (String? newValue) {
              setState(() {
                selectedStatus = newValue!;
                fetchComplaintCounts(); // Re-fetch complaint counts when status changes
              });
            },
            items: ["All", "Pending", "Resolved", "In Progress"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildComplaintOverview(),
            const SizedBox(height: 20),
            _buildComplaintList(),
            const SizedBox(height: 20),
            _buildTotalComplaintsCard(),
          ],
        ),
      ),
    );
  }

  // Complaint Overview (Pie Chart)
  Widget _buildComplaintOverview() {
    int totalComplaints = academicAdvisoryComplaintsCount +
        cafeteriaComplaintsCount +
        chapelComplaintsCount +
        collegeComplaintsCount +
        departmentComplaintsCount +
        financeComplaintsCount +
        healthcareComplaintsCount +
        hostelComplaintsCount +
        itSupportComplaintsCount +
        libraryComplaintsCount +
        studentAffairsComplaintsCount +
        technicalComplaintsCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text(
            "Total Complaints: $totalComplaints",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: [
                  _buildPieChartSection(
                      "AcademicAdvisoryComplaints", academicAdvisoryComplaintsCount, totalComplaints),
                  _buildPieChartSection("CaferteriaComplaints", cafeteriaComplaintsCount, totalComplaints),
                  _buildPieChartSection("ChapelComplaints", chapelComplaintsCount, totalComplaints),
                  _buildPieChartSection("CollegeComplaints", collegeComplaintsCount, totalComplaints),
                  _buildPieChartSection("DepartmentComplaints", departmentComplaintsCount, totalComplaints),
                  _buildPieChartSection("FinianceComplaints", financeComplaintsCount, totalComplaints),
                  _buildPieChartSection("HealthCareComplaints", healthcareComplaintsCount, totalComplaints),
                  _buildPieChartSection("HostelComplaints", hostelComplaintsCount, totalComplaints),
                  _buildPieChartSection("ITSupportComplaints", itSupportComplaintsCount, totalComplaints),
                  _buildPieChartSection("LibraryComplaints", libraryComplaintsCount, totalComplaints),
                  _buildPieChartSection("StudentAffairsComplaints", studentAffairsComplaintsCount, totalComplaints),
                  _buildPieChartSection("TechnicalComplaints", technicalComplaintsCount, totalComplaints),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(
      String title, int count, int totalComplaints) {
    double percentage = totalComplaints > 0 ? (count / totalComplaints) * 100 : 0;

    // Extract the office name from the category name (remove "Complaints")
  String officeName = title.replaceAll("Complaints", "");


    Color sectionColor = categoryColors[title] ?? Colors.grey;

    return PieChartSectionData(
      value: count.toDouble(),
      color: sectionColor,
      title: "$officeName\n${percentage.toStringAsFixed(1)}%",
      radius: 30,
     titleStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
     showTitle: true,
    );
  }


  // Complaint List
  Widget _buildComplaintList() {
    return Column(
      children: [
        _buildComplaintCard(
          title: 'Academic Advisory Complaints',
          count: academicAdvisoryComplaintsCount,
          color: categoryColors['AcademicAdvisoryComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Cafeteria Complaints',
          count: cafeteriaComplaintsCount,
          color: categoryColors['CaferteriaComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Chapel Complaints',
          count: chapelComplaintsCount,
          color: categoryColors['ChapelComplaints']!,
        ),
        _buildComplaintCard(
          title: 'College Complaints',
          count: collegeComplaintsCount,
          color: categoryColors['CollegeComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Department Complaints',
          count: departmentComplaintsCount,
          color: categoryColors['DepartmentComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Finance Complaints',
          count: financeComplaintsCount,
          color: categoryColors['FinianceComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Healthcare Complaints',
          count: healthcareComplaintsCount,
          color: categoryColors['HealthCareComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Hostel Complaints',
          count: hostelComplaintsCount,
          color: categoryColors['HostelComplaints']!,
        ),
        _buildComplaintCard(
          title: 'IT Support Complaints',
          count: itSupportComplaintsCount,
          color: categoryColors['ITSupportComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Library Complaints',
          count: libraryComplaintsCount,
          color: categoryColors['LibraryComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Student Affairs Complaints',
          count: studentAffairsComplaintsCount,
          color: categoryColors['StudentAffairsComplaints']!,
        ),
        _buildComplaintCard(
          title: 'Technical Complaints',
          count: technicalComplaintsCount,
          color: categoryColors['TechnicalComplaints']!,
        ),
      ],
    );
  }

  // Total Complaints Card
  Widget _buildTotalComplaintsCard() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          "Total Complaints",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          totalComplaintsCount.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Method to create complaint cards with color styling
  Widget _buildComplaintCard({required String title, required int count, required Color color}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        tileColor: color.withOpacity(0.1), // Set background color for ListTile
        contentPadding: EdgeInsets.all(16.0),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold,color: color),
        ),
        trailing: Text(
          count.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: color),
        ),
      ),
    );
  }
}
