import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class T2_1 extends StatefulWidget {
  const T2_1({Key? key}) : super(key: key);

  @override
  State<T2_1> createState() => _T2_1State();
}

class _T2_1State extends State<T2_1> {
  late Future<Map<int, List<Article>>> articles;
  int? selectedIdw;
  Map<int, Color> idwColors = {};
  DateTime selectedDate = DateTime.now();
  Map<DateTime, double> averageCapacityMap = {};
  List<Article>? selectedIdwData;
  List<DropdownMenuItem<int>> dropdownItems = [];

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    articles = fetchArticle(selectedDate);
    selectedIdw = 1;
  }



  Future<void> _showMonthPickerDialog() async {
    DateTime? selectedMonth = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedMonth != null && selectedMonth != selectedDate) {
      setState(() {
        selectedDate = selectedMonth;
        articles = fetchArticle(selectedDate);
    
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monthly',
          style: TextStyle(
            color: Colors.black, // Change the text color to white
          ),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: ListView(
        children: [
          FutureBuilder<Map<int, List<Article>>>(
            future: articles,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final idwMap = snapshot.data!;
                final dropdownItems = <DropdownMenuItem<int>>[];
              final allIdws = idwMap.keys.toList();
                print('ss $allIdws');
// Populate dropdownItems with all available Id Wastebins
                for (final idw in allIdws) {
        dropdownItems.add(
          DropdownMenuItem(
            value: idw,
            child: Text('Select Id Wastebin: $idw'),
          ),
        );
        
        if (!idwColors.containsKey(idw)) {
          idwColors[idw] = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
              .withOpacity(1.0);
        }
      }
                return Center(
                  child: DropdownButton<int>(
                    
                    value: selectedIdw,
                    items: List.generate(3, (index) {
            // Replace '10' with the number of Id Wastebins you want to display
            final idw = index+1;
            return DropdownMenuItem(
              value: idw,
              child: Text('Select Id Wastebin: $idw'),
            );
          }),
                    onChanged: (value) async {
                      setState(() {
                        selectedIdw = value;
                        _showMonthPickerDialog();
                      });
                      final newArticles = fetchArticle(selectedDate);
                      setState(() {
                        articles = newArticles;
                      });
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<Map<int, List<Article>>>(
                  future: articles,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final idwMap = snapshot.data!;
                      final data = selectedIdw != null
                          ? idwMap[selectedIdw!] ?? []
                          : idwMap.values
                              .expand((articles) => articles)
                              .toList();
                      data.sort((a, b) => a.Date_Time.compareTo(b.Date_Time));

                      final averageCapacityMap =
                          calculateDailyAverageCapacity(idwMap, selectedIdw!);
                      final averageData = averageCapacityMap.entries
                          .map((entry) => Article(
                              Idw:
                                  0, // Setting a placeholder Idw value for average data
                              Capacity: entry.value.toInt(),
                              Date_Time: entry.key))
                          .toList();

                      double calculateAverageCapacity(
                          List<Article> averageData) {
                        if (averageData.isEmpty) {
                          return 0.0;
                        }

                        double totalCapacity = 0.0;
                        for (final article in averageData) {
                          totalCapacity += article.Capacity;
                        }

                        return totalCapacity / averageData.length;
                      }

                      final averageCapacity =
                          calculateAverageCapacity(averageData);
                      return Column(
                        children: [
                          SfCartesianChart(
                            title: ChartTitle(text: 'Capacity And MOnth'),
                            legend: Legend(
                              isVisible: true,
                              title: LegendTitle(text: 'Capacity'),
                              position: LegendPosition.bottom,
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: false,
                              // Customize the tooltip format to display only capacity
                            ),
                            series: <ChartSeries>[
                              StackedLineSeries<Article, DateTime>(
                                name: 'Capacity ',
                                dataSource: averageData,
                                color: idwColors[selectedIdw] ?? Colors.black,
                                xValueMapper: (Article article, _) =>
                                    article.Date_Time,
                                yValueMapper: (Article article, _) =>
                                    article.Capacity,
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true),
                              ),
                            ],
                            primaryXAxis: DateTimeAxis(
                              title: AxisTitle(text: 'Month'),
                              minimum: DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  1,
                                  selectedDate.day,
                                  0), // set minimum time to 6 am
                              maximum: DateTime(
                                  selectedDate.year,
                                  selectedDate.month + 1,
                                  selectedDate.day,
                                  23,
                                  59),
                            ),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(
                                  text: 'Capacity'), // Add title for y-axis
                            ),
                          ),
                          Text(
                              'Average capacity: ${averageCapacity.toStringAsFixed(2)}'),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 16.0),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Add a function to calculate daily average capacity for each day
Map<DateTime, double> calculateDailyAverageCapacity(
    Map<int, List<Article>> idwMap, int selectedIdw) {
  final averageCapacityMap = <DateTime, double>{};

  final articles = idwMap[selectedIdw] ?? [];

  articles.forEach((article) {
    final date = DateTime(
        article.Date_Time.year, article.Date_Time.month, article.Date_Time.day);
    if (!averageCapacityMap.containsKey(date)) {
      averageCapacityMap[date] = 0;
    }
    averageCapacityMap[date] =
        (averageCapacityMap[date]! + article.Capacity) / 2;
  });

  return averageCapacityMap;
}

Future<Map<int, List<Article>>> fetchArticle(DateTime selectedDate) async {
  final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
  final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
  final formattedStartDate = DateFormat('MM/dd/yyyy').format(firstDayOfMonth);
  final formattedEndDate = DateFormat('MM/dd/yyyy').format(lastDayOfMonth);

  final response = await http.get(Uri.parse(
      'https://proesp32.000webhostapp.com/getDataByDateRange.php?start_date='
      '$formattedStartDate&end_date=$formattedEndDate'));

  if (response.statusCode == 200) {
    final articles = parseArticles(response.body);
    final idwMap = <int, List<Article>>{};
    articles.forEach((article) {
      final idw = article.Idw;
      if (!idwMap.containsKey(idw)) {
        idwMap[idw] = [];
      }
      if (article.Date_Time.isAfter(firstDayOfMonth) &&
          article.Date_Time.isBefore(lastDayOfMonth)) {
        idwMap[idw]!.add(article);
      }
    });
    return idwMap;
  } else {
    throw Exception('Failed to load article');
  }
}

// Add a function to calculate average capacity for each day
Map<DateTime, double> calculateAverageCapacityForIdw(Map<int, List<Article>> idwMap, int selectedIdw) {
  final averageCapacityMap = <DateTime, double>{};
final articles = idwMap[selectedIdw] ?? [];
  final dailyCapacityMap = <DateTime, List<int>>{};

  articles.forEach((article) {
    final date = DateTime(
        article.Date_Time.year, article.Date_Time.month, article.Date_Time.day);
    if (!dailyCapacityMap.containsKey(date)) {
      dailyCapacityMap[date] = [];
    }
    dailyCapacityMap[date]!.add(article.Capacity);
  });

  dailyCapacityMap.forEach((date, capacities) {
    final averageCapacity = capacities.isNotEmpty
        ? capacities.reduce((a, b) => a + b) / capacities.length
        : 0.0;
    averageCapacityMap[date] = averageCapacity;
  });

  return averageCapacityMap;
}

List<Article> parseArticles(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Article>((json) {
    if (!json.containsKey('Capacity') || !json.containsKey('Date_Time')) {
      throw FormatException('Invalid JSON data');
    }

    try {
      return Article.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid JSON data: $e');
    }
  }).toList();
}

class Article {
  final int Idw;
  final int Capacity;
  final DateTime Date_Time;

  Article({
    required this.Idw,
    required this.Capacity,
    required this.Date_Time,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      Idw: int.parse(json['Idw']),
      Capacity: int.parse(json['Capacity']),
      Date_Time: DateFormat('MM/dd/yyyy hh:mm:ss').parse(json['Date_Time']),
    );
  }
}
