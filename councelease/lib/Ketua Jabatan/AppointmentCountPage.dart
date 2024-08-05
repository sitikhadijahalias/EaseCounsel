import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AppointmentCountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Bilangan Sesi'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          // Process appointments to get count per month
          Map<String, int> monthlyAppointmentCount = {};

          snapshot.data!.docs.forEach((appointment) {
            Timestamp appointmentDate =
                appointment['appointmentTimestamp'] as Timestamp;
            DateTime dateTime = appointmentDate.toDate();
            String monthYear = '${dateTime.month}-${dateTime.year}';

            if (monthlyAppointmentCount.containsKey(monthYear)) {
              monthlyAppointmentCount[monthYear] =
                  monthlyAppointmentCount[monthYear]! + 1;
            } else {
              monthlyAppointmentCount[monthYear] = 1;
            }
          });

          // Prepare data for chart
          List<AppointmentData> appointmentDataList = monthlyAppointmentCount
              .entries
              .map((entry) => AppointmentData(
                  monthYear: entry.key, appointmentCount: entry.value))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bilangan Sesi Temujanji Setiap Bulan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SfCartesianChart(
                    // Change to BarSeries
                    series: <ChartSeries>[
                      BarSeries<AppointmentData, String>(
                        dataSource: appointmentDataList,
                        xValueMapper: (AppointmentData data, _) =>
                            data.monthYear,
                        yValueMapper: (AppointmentData data, _) =>
                            data.appointmentCount,
                        name: 'Sesi',
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Bulan'),
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AppointmentData {
  final String monthYear;
  final int appointmentCount;

  AppointmentData({required this.monthYear, required this.appointmentCount});
}

void main() {
  runApp(MaterialApp(
    home: AppointmentCountPage(),
  ));
}
