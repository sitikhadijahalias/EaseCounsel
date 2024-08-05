import 'package:councelease/Kaunselor/Report/AnalysisReportPage.dart';
import 'package:flutter/material.dart';
import 'CounselorPerformancePage.dart';
import 'SessionsPage.dart';
import 'kaunselor.dart';
import 'AppointmentCountPage.dart';
import 'DemographicReportPage.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC80),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Aplikasi Pengurusan Perkhidmatan Kaunseling",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  DashboardCard(
                    title: 'Kaunselor',
                    icon: Icons.people,
                    backgroundColor: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KaunselorsPage(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Sesi Kaunseling',
                    icon: Icons.event_note,
                    backgroundColor: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionsPage(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Laporan Penilaian Sesi',
                    icon: Icons.assessment,
                    backgroundColor: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CounselorPerformancePage(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Laporan Bilangan Sesi',
                    icon: Icons.insert_chart_outlined,
                    backgroundColor: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentCountPage(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Laporan Klien Demografik',
                    icon: Icons.pie_chart,
                    backgroundColor: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DemographicReportPage(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Laporan Perkhidmatan',
                    icon: Icons.pie_chart,
                    backgroundColor: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnalysisReportPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Function onTap;

  DashboardCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Add elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: backgroundColor, // Set card background color
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.white.withOpacity(0.5), // Adjust splash color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white, // Adjust circle avatar color
              radius: 30,
              child: Icon(
                icon,
                color:
                    backgroundColor, // Adjust icon color to match card background
                size: 30,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Adjust text color
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
