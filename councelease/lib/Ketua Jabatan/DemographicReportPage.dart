import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DemographicReportPage extends StatefulWidget {
  @override
  _DemographicReportPageState createState() => _DemographicReportPageState();
}

class _DemographicReportPageState extends State<DemographicReportPage> {
  List<Map<String, dynamic>> _clientData = [];
  String _selectedCategory = 'Jantina'; // Default selection

  @override
  void initState() {
    super.initState();
    _fetchClientData();
  }

  void _fetchClientData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot querySnapshot = await firestore.collection('clients').get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _clientData = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        print('No clients found in Firestore');
      }
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Demografik Klien'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: <String>['Jantina', 'Agama', 'Kaum']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  if (_selectedCategory == 'Jantina')
                    PieChartWidget(
                      data: _clientData,
                      fieldName: 'gender',
                      title: 'Jantina',
                    ),
                  if (_selectedCategory == 'Agama')
                    PieChartWidget(
                      data: _clientData,
                      fieldName: 'religion',
                      title: 'Agama',
                    ),
                  if (_selectedCategory == 'Kaum')
                    PieChartWidget(
                      data: _clientData,
                      fieldName: 'race',
                      title: 'Kaum',
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

class PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String fieldName;
  final String title;

  PieChartWidget(
      {required this.data, required this.fieldName, required this.title});

  @override
  Widget build(BuildContext context) {
    List<_ChartData> chartData = _processData();

    return Container(
      height: 300,
      child: SfCircularChart(
        title: ChartTitle(text: title, textStyle: TextStyle(fontSize: 16)),
        legend: Legend(isVisible: true),
        series: <CircularSeries>[
          PieSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            dataLabelSettings: DataLabelSettings(isVisible: true),
          )
        ],
      ),
    );
  }

  List<_ChartData> _processData() {
    Map<String, int> dataMap = {};

    // Calculate counts
    for (var entry in data) {
      String fieldValue = entry[fieldName].toString();
      dataMap[fieldValue] = (dataMap[fieldValue] ?? 0) + 1;
    }

    // Convert to chart data format
    List<_ChartData> chartData = [];
    dataMap.forEach((key, value) {
      chartData.add(_ChartData(category: key, value: value.toDouble()));
    });

    return chartData;
  }
}

class _ChartData {
  final String category;
  final double value;

  _ChartData({required this.category, required this.value});
}
