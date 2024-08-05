import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:intl/intl.dart';

class CounselorPerformancePage extends StatefulWidget {
  @override
  _CounselorPerformancePageState createState() =>
      _CounselorPerformancePageState();
}

class _CounselorPerformancePageState extends State<CounselorPerformancePage> {
  String _selectedGraph = 'Bilangan Sesi';
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Prestasi Kaunselor'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? picked = await showMonthPicker(
                        context: context,
                        initialDate: _selectedMonth,
                        locale: Locale("en"),
                      );
                      if (picked != null && picked != _selectedMonth) {
                        setState(() {
                          _selectedMonth = picked;
                        });
                      }
                    },
                    child: Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('session_evaluations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var sessions = snapshot.data!.docs.where((doc) {
                  Timestamp timestamp = doc['sessionDate'] as Timestamp;
                  DateTime date = timestamp.toDate();
                  return date.year == _selectedMonth.year &&
                      date.month == _selectedMonth.month;
                }).toList();

                Map<String, int> counselorSessionCount = {};
                Map<String, List<double>> counselorRatings = {};
                Map<int, List<double>> questionRatings = {
                  0: [],
                  1: [],
                  2: [],
                  3: [],
                  4: [],
                  5: [],
                };

                sessions.forEach((session) {
                  String counselor = session['counselorName'];
                  List<dynamic>? feedbackRatingsDynamic =
                      session['feedbackRatings'];

                  if (feedbackRatingsDynamic != null) {
                    List<double> feedbackRatings = feedbackRatingsDynamic
                        .map((e) => (e as num).toDouble())
                        .toList();

                    if (counselorSessionCount.containsKey(counselor)) {
                      counselorSessionCount[counselor] =
                          counselorSessionCount[counselor]! + 1;
                      counselorRatings[counselor]!.addAll(feedbackRatings);
                    } else {
                      counselorSessionCount[counselor] = 1;
                      counselorRatings[counselor] = feedbackRatings;
                    }

                    questionRatings.forEach((index, ratings) {
                      if (feedbackRatings.length > index) {
                        questionRatings[index]!.add(feedbackRatings[index]);
                      }
                    });
                  }
                });

                Map<String, double> averageRatings = {};
                counselorRatings.forEach((counselor, ratings) {
                  averageRatings[counselor] =
                      ratings.reduce((a, b) => a + b) / ratings.length;
                });

                Map<int, double> averageQuestionRatings = {};
                questionRatings.forEach((index, ratings) {
                  if (ratings.isNotEmpty) {
                    averageQuestionRatings[index] =
                        ratings.reduce((a, b) => a + b) / ratings.length;
                  }
                });

                List<CounselorData> sessionData = counselorSessionCount.entries
                    .map((entry) => CounselorData(
                        entry.key, entry.value, averageRatings[entry.key] ?? 0))
                    .toList();
                List<QuestionData> questionData = averageQuestionRatings.entries
                    .map((entry) => QuestionData(entry.key, entry.value))
                    .toList();

                Map<int, String> questionLabels = {
                  0: "Saya rasa lebih lega sekarang",
                  1: "Saya boleh mendengar isi hati saya",
                  2: "Saya yakin saya tidak keseorangan lagi",
                  3: "Saya dapat mengawal emosi saya",
                  4: "Saya tahu apa yang saya hadapi",
                  5: "Saya dapati sesi kaunseling ini dapat membantu saya",
                };

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<String>(
                        value: _selectedGraph,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGraph = newValue!;
                          });
                        },
                        items: <String>[
                          'Bilangan Sesi',
                          'Penilaian Purata bagi setiap Kaunselor',
                          'Penilaian Purata setiap Soalan'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      if (_selectedGraph == 'Bilangan Sesi')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Bilangan Sesi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 300,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                title: ChartTitle(
                                    text:
                                        'Bilangan Sesi bagi setiap Kaunselor'),
                                legend: Legend(isVisible: true),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <ChartSeries>[
                                  BarSeries<CounselorData, String>(
                                    dataSource: sessionData,
                                    xValueMapper: (CounselorData data, _) =>
                                        data.counselor,
                                    yValueMapper: (CounselorData data, _) =>
                                        data.sessionCount,
                                    name: 'Bilangan Sesi',
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (_selectedGraph ==
                          'Penilaian Purata bagi setiap Kaunselor')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Penilaian Purata bagi setiap Kaunselor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 300,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                title: ChartTitle(
                                    text:
                                        'Penilaian Purata bagi setiap Kaunselor'),
                                legend: Legend(isVisible: true),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <ChartSeries>[
                                  BarSeries<CounselorData, String>(
                                    dataSource: sessionData,
                                    xValueMapper: (CounselorData data, _) =>
                                        data.counselor,
                                    yValueMapper: (CounselorData data, _) =>
                                        data.averageRating,
                                    name: 'Penilaian Purata',
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (_selectedGraph == 'Penilaian Purata setiap Soalan')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Penilaian Purata setiap Soalan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 300,
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                title: ChartTitle(
                                    text: 'Penilaian Purata setiap Soalan'),
                                legend: Legend(isVisible: true),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <ChartSeries>[
                                  BarSeries<QuestionData, int>(
                                    dataSource: questionData,
                                    xValueMapper: (QuestionData data, _) =>
                                        data.question,
                                    yValueMapper: (QuestionData data, _) =>
                                        data.averageRating,
                                    name: 'Penilaian Purata',
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0; i < 6; i++)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Soalan ${i + 1}:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          // Add Expanded here to wrap the Text widget
                                          child: Text(questionLabels[i]!),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final font = await rootBundle.load("assets/fonts/Lato-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    var sessions = await FirebaseFirestore.instance
        .collection('session_evaluations')
        .get();
    var filteredSessions = sessions.docs.where((doc) {
      Timestamp timestamp = doc['sessionDate'] as Timestamp;
      DateTime date = timestamp.toDate();
      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).toList();

    Map<String, int> counselorSessionCount = {};
    Map<String, List<double>> counselorRatings = {};
    Map<int, List<double>> questionRatings = {
      0: [],
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
    };

    filteredSessions.forEach((session) {
      String counselor = session['counselorName'];
      List<dynamic>? feedbackRatingsDynamic = session['feedbackRatings'];

      if (feedbackRatingsDynamic != null) {
        List<double> feedbackRatings =
            feedbackRatingsDynamic.map((e) => (e as num).toDouble()).toList();

        if (counselorSessionCount.containsKey(counselor)) {
          counselorSessionCount[counselor] =
              counselorSessionCount[counselor]! + 1;
          counselorRatings[counselor]!.addAll(feedbackRatings);
        } else {
          counselorSessionCount[counselor] = 1;
          counselorRatings[counselor] = feedbackRatings;
        }

        questionRatings.forEach((index, ratings) {
          if (feedbackRatings.length > index) {
            questionRatings[index]!.add(feedbackRatings[index]);
          }
        });
      }
    });

    Map<String, double> averageRatings = {};
    counselorRatings.forEach((counselor, ratings) {
      averageRatings[counselor] =
          ratings.reduce((a, b) => a + b) / ratings.length;
    });

    Map<int, double> averageQuestionRatings = {};
    questionRatings.forEach((index, ratings) {
      if (ratings.isNotEmpty) {
        averageQuestionRatings[index] =
            ratings.reduce((a, b) => a + b) / ratings.length;
      }
    });

    List<CounselorData> sessionData = counselorSessionCount.entries
        .map((entry) => CounselorData(
            entry.key, entry.value, averageRatings[entry.key] ?? 0))
        .toList();
    List<QuestionData> questionData = averageQuestionRatings.entries
        .map((entry) => QuestionData(entry.key, entry.value))
        .toList();

    Map<int, String> questionLabels = {
      0: "Saya rasa lebih lega sekarang",
      1: "Saya boleh mendengar isi hati saya",
      2: "Saya yakin saya tidak keseorangan lagi",
      3: "Saya dapat mengawal emosi saya",
      4: "Saya tahu apa yang saya hadapi",
      5: "Saya dapati sesi kaunseling ini dapat membantu saya",
    };

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            'Laporan Prestasi Kaunselor',
            style: pw.TextStyle(font: ttf, fontSize: 40),
          ),
        ),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Bilangan Sesi',
              style: pw.TextStyle(font: ttf, fontSize: 18)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Kaunselor', 'Bilangan Sesi'],
              ...sessionData.map(
                  (data) => [data.counselor, data.sessionCount.toString()]),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Penilaian Purata bagi setiap Kaunselor',
              style: pw.TextStyle(font: ttf, fontSize: 18)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Kaunselor', 'Penilaian Purata'],
              ...sessionData.map((data) =>
                  [data.counselor, data.averageRating.toStringAsFixed(2)]),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Penilaian Purata setiap Soalan',
              style: pw.TextStyle(font: ttf, fontSize: 18)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Soalan', 'Penilaian Purata'],
              ...questionData.map((data) => [
                    questionLabels[data.question] ??
                        'Soalan ${data.question + 1}',
                    data.averageRating.toStringAsFixed(2),
                  ]),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  showMonthPicker(
      {required BuildContext context,
      required DateTime initialDate,
      required Locale locale}) {}
}

class CounselorData {
  final String counselor;
  final int sessionCount;
  final double averageRating;

  CounselorData(this.counselor, this.sessionCount, this.averageRating);
}

class QuestionData {
  final int question;
  final double averageRating;

  QuestionData(this.question, this.averageRating);
}
