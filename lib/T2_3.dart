import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class T2_3 extends StatefulWidget {
  const T2_3({Key? key}) : super(key: key);

  @override
  State<T2_3> createState() => _T2_3State();
}

class _T2_3State extends State<T2_3> {
  late Future<Map<int, List<Article>>> articles;
  int? selectedIdw;
  Map<int, Color> idwColors = {};
  DateTime selectedDate = DateTime.now();
  Map<DateTime, double> averageCapacityMap = {};
  int? lastSelectedIdw;

  @override
  void initState() {
    print("initState"); // For testing purposes
    super.initState();
    lastSelectedIdw = selectedIdw; // Initialize lastSelectedIdw
    articles = fetchArticle(selectedDate);
    selectedIdw = 1;
  }

  Future<void> _showYearPickerDialog() async {
    int? selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Year'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              itemCount: DateTime.now().year - 2000,
              itemBuilder: (context, index) {
                final year = DateTime.now().year - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    Navigator.of(context).pop(year);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null && selectedYear != selectedDate.year) {
      setState(() {
        selectedDate = DateTime(selectedYear);
        selectedIdw = lastSelectedIdw; // Restore the last selected Idw
        articles = fetchArticle(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yearly',
          style: TextStyle(
            color: Colors.black, // Change the text color to white
          ),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          FutureBuilder<Map<int, List<Article>>>(
            future: articles,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final idwMap = snapshot.data!;
          

                final dropdownItems = <DropdownMenuItem<int>>[];
final sortedIdwValues = idwMap.keys.toList()..sort(); // Sort the idw values

for (final idw in sortedIdwValues) {
  dropdownItems.add(
    DropdownMenuItem(
      value: idw,
      child: Text('Select Id Wastebin: $idw'),
    ),
  );

  if (!idwColors.containsKey(idw)) {
    idwColors[idw] =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
  }
}

                

                // Check if the selectedIdw is not in the new data and update it
                if (!idwMap.keys.contains(selectedIdw)) {
                  selectedIdw = idwMap.keys.first;
                }

                return Center(
                  child: DropdownButton<int>(
                    value: selectedIdw, // Set the selected IDW
                    items: dropdownItems,
                    onChanged: (value) async {
                      setState(() {
                        lastSelectedIdw = value; // Update the lastSelectedIdw
                        selectedIdw = value;
                        _showYearPickerDialog();
                      });
                      final newArticles = await fetchArticle(selectedDate);
                      setState(() {
                        articles = Future.value(newArticles);
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
                          calculateAverageCapacity(idwMap, selectedIdw!);
                      final averageCapacity = data.isNotEmpty
                          ? data
                                  .map((article) => article.Capacity)
                                  .reduce((a, b) => a + b) /
                              data.length
                          : 0.0;

                      final averageData = averageCapacityMap.entries
                          .map((entry) => Article(
                              Idw:
                                  0, // Setting a placeholder Idw value for average data
                              Capacity: entry.value.toInt(),
                              Date_Time: entry.key))
                          .toList();
                      String yearString = selectedDate.year.toString();

                      return Column(
                        children: [
                          SfCartesianChart(
                            title: ChartTitle(text: 'Capacity vs Time'),
                            legend: Legend(
                              isVisible: true,
                              title: LegendTitle(text: 'Capacity'),
                              position: LegendPosition.bottom,
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries>[
                              StackedLineSeries<Article, DateTime>(
                                name: 'Capacity',
                                dataSource: averageData
                                    .where((article) =>
                                        article.Date_Time.year ==
                                        selectedDate.year)
                                    .toList(),
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
                              title: AxisTitle(text: yearString),
                              minimum: DateTime(selectedDate.year, 1,
                                  1), // set minimum time to the beginning of the year
                              maximum: DateTime(selectedDate.year, 12,
                                  31), // set maximum time to the end of the year
                              intervalType: DateTimeIntervalType.months,
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

Future<Map<int, List<Article>>> fetchArticle(DateTime selectedDate) async {
  final firstDayOfYear = DateTime(selectedDate.year, 1, 1);
  final lastDayOfYear = DateTime(selectedDate.year, 12, 31);
  final formattedStartDate = DateFormat('MM/dd/yyyy').format(firstDayOfYear);
  final formattedEndDate = DateFormat('MM/dd/yyyy').format(lastDayOfYear);

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

      // Filter data by the selected year
      if (article.Date_Time.year == selectedDate.year) {
        idwMap[idw]!.add(article);
      }
    });
    return idwMap;
  } else {
    throw Exception('Failed to load article');
  }
}


// Add a function to calculate average capacity for each day
Map<DateTime, double> calculateAverageCapacity(
    Map<int, List<Article>> idwMap, int selectedIdw) {
  final averageCapacityMap = <DateTime, double>{};

  final articles = idwMap[selectedIdw] ?? [];

  final monthlyCapacityMap = <DateTime, List<int>>{};

  articles.forEach((article) {
    final date = DateTime(article.Date_Time.year, article.Date_Time.month);
    if (!monthlyCapacityMap.containsKey(date)) {
      monthlyCapacityMap[date] = [];
    }
    monthlyCapacityMap[date]!.add(article.Capacity);
  });

  monthlyCapacityMap.forEach((date, capacities) {
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
