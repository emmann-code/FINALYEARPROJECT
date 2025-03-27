import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mtu_connect_hub/features/widgets/components/my_drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 46, 44, 53),
      drawer: MyDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: Text("Complaint Dashboard",
        style: GoogleFonts.aboreto(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(blurRadius: 10, color:  Color.fromARGB(221, 75, 50, 50), offset: Offset(2, 2))
                  ],
                ),
              ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 30, 30, 40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComplaintOverview(),
            const SizedBox(height: 20),
            const Expanded(child: ComplaintList()),
          ],
        ),
      ),
    );
  }
}

class ComplaintOverview extends StatelessWidget {
  const ComplaintOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Total Complaints: 234",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 50, color: Colors.red, title: "Pending"),
                  PieChartSectionData(value: 30, color: Colors.green, title: "Resolved"),
                  PieChartSectionData(value: 20, color: Colors.orange, title: "In Progress"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintList extends StatelessWidget {
  const ComplaintList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ComplaintCard("Chapel Office", 114, 90, Colors.redAccent),
        ComplaintCard("Department Office", 56, 50, Colors.purpleAccent),
        ComplaintCard("Hostel Office", 64, 23, Colors.greenAccent),
      ],
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final String department;
  final int total;
  final int solved;
  final Color color;

  const ComplaintCard(this.department, this.total, this.solved, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.business, color: color),
        title: Text(department, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${total - solved} left to solve"),
        trailing: Text("$total", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

