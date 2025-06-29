import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AllDataScreen extends StatefulWidget {
  const AllDataScreen({Key? key}) : super(key: key);

  @override
  State<AllDataScreen> createState() => _AllDataScreenState();
}

class _AllDataScreenState extends State<AllDataScreen> {
  late Future<List<Article>> articles;
  Map<int, Color> idwColors = {};
  int selectDays = 30; // Default value

  @override
  void initState() {
    super.initState();
    articles = fetchArticle();
    idwColors = {
      1: Colors.red,
      2: Colors.blue,
      3: Colors.green,
      4: Colors.orange,
      5: Colors.black,
    };
  }

  double calculateMovingAverage(List<Article> data, int windowSize) {
    if (data.length < windowSize) return 0.0;

    double sum = 0.0;
    for (int i = data.length - windowSize; i < data.length; i++) {
      sum += data[i].Capacity;
    }

    return sum / windowSize;
  }

  double calculateExponentialMovingAverage(
      List<Article> data, double alpha, int days) {
    if (data.isEmpty) return 0.0;

    double ema = data[0].Capacity.toDouble();
    for (int i = 1; i < data.length; i++) {
      ema = alpha * data[i].Capacity + (1 - alpha) * ema;
      if (i == days - 1)
        break; // Stop after calculating the EMA for the specified number of days
    }

    return ema;
  }

  List<double> calculateNextEMA(List<Article> data, double alpha) {
    final emaValues = <double>[];
    if (data.isEmpty) return emaValues;

    double ema = data[data.length - 1].Capacity.toDouble();
    for (int i = 0; i < selectDays; i++) {
      ema = alpha * data[data.length - 1 - i].Capacity + (1 - alpha) * ema;
      emaValues.add(ema);
    }

    return emaValues.reversed.toList();
  }

  List<double> calculateForecastedValuesForGroup(
      List<Article> groupData, double alpha, int days) {
    final forecastedValues = <double>[];
    if (groupData.isEmpty) return forecastedValues;

    double ema = groupData.last.Capacity.toDouble();
    for (int i = 0; i < days; i++) {
      ema = alpha * groupData.last.Capacity + (1 - alpha) * ema;
      forecastedValues.add(ema);
    }

    return forecastedValues.reversed.toList();
  }

  List<int> getAllIdwValues(List<Article> articles) {
    Set<int> idwSet = Set<int>();
    for (Article article in articles) {
      idwSet.add(article.Idw);
    }
    return idwSet.toList();
  }

  Map<int, double> calculateMovingAverageForUniqueIdwList(
      List<Article> articles, List<int> uniqueIdwList, int windowSize) {
    Map<int, double> movingAverages = {};

    for (int idw in uniqueIdwList) {
      List<Article> articlesForIdw =
          articles.where((article) => article.Idw == idw).toList();
      movingAverages[idw] = calculateMovingAverage(articlesForIdw, windowSize);
    }

    return movingAverages;
  }

  Map<int, double> calculateExponentialMovingAverageForUniqueIdwList(
      List<Article> articles, List<int> uniqueIdwList, double alpha, int days) {
    Map<int, double> emaValues = {};

    for (int idw in uniqueIdwList) {
      List<Article> articlesForIdw =
          articles.where((article) => article.Idw == idw).toList();
      emaValues[idw] =
          calculateExponentialMovingAverage(articlesForIdw, alpha, days);
    }

    return emaValues;
  }

  Map<int, List<double>> calculateNextEMAForUniqueIdwList(
      List<Article> articles,
      List<int> uniqueIdwList,
      double alpha,
      int selectDays) {
    Map<int, List<double>> nextEMAValues = {};

    for (int idw in uniqueIdwList) {
      List<Article> articlesForIdw =
          articles.where((article) => article.Idw == idw).toList();
      nextEMAValues[idw] =
          calculateNextEMA(articlesForIdw, alpha).take(selectDays).toList();
    }

    return nextEMAValues;
  }

  Map<int, List<double>> calculateForecastedCapacityForUniqueIdwList(
      List<Article> articles,
      List<int> uniqueIdwList,
      double alpha,
      int selectDays) {
    Map<int, List<double>> forecastedValues = {};

    for (int idw in uniqueIdwList) {
      List<Article> articlesForIdw =
          articles.where((article) => article.Idw == idw).toList();
      final forecastedValuesForGroup = <double>[];

      // Find the index of the current date
      int currentIndex = articlesForIdw
          .indexWhere((article) => article.Date_Time.isAfter(DateTime.now()));

      if (currentIndex != -1) {
        // Calculate the initial EMA from the current date
        double ema = calculateExponentialMovingAverage(
            articlesForIdw.sublist(currentIndex), alpha, selectDays);

        // Calculate forecasted values for the specified number of days
        for (int i = 0; i < selectDays; i++) {
          ema = alpha * articlesForIdw[currentIndex + i].Capacity +
              (1 - alpha) * ema;
          forecastedValuesForGroup.add(ema);
        }
      }

      forecastedValues[idw] = forecastedValuesForGroup;
    }

    return forecastedValues;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forecast Charts',
          style: TextStyle(
            color: Colors.black, // Change the text color to white
          ),
        ),
        
        actions: [
          DropdownButton<int>(
            value: selectDays,
            
            items: [
              DropdownMenuItem<int>(
                value: 3,
                child: Text('3 Days'),
              ),
              DropdownMenuItem<int>(
                value: 7,
                child: Text('7 Days'),
              ),
              DropdownMenuItem<int>(
                value: 30,
                child: Text('30 Days'),
              ),
            ],
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  selectDays = newValue;
                });
              }
            },
          ),
        ],
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<List<Article>>(
              future: articles,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  final articlesByGroup = groupArticlesByGroup(data);

                  // Define alpha and selectDays
                  final alpha = 0.2; // You can adjust this value
                  List<int> uniqueIdwList =
                      getAllIdwValues(data); // data is your List<Article>

                  print('test222 $uniqueIdwList');

                  // Calculate the forecasted capacity for unique IDWs
                  final forecastedCapacityForIDWs =
                      calculateForecastedCapacityForUniqueIdwList(
                          data, uniqueIdwList, alpha, selectDays);
                  print(
                      'Forecasted Capacity for IDWs: $forecastedCapacityForIDWs');

                  final chartSeries = getForecastedCapacitySeries(
                      forecastedCapacityForIDWs, idwColors);

                  return Column(
                    children: [
                      SfCartesianChart(
                        title:
                            ChartTitle(text: 'Forecasted Capacity Of All Data'),
                        legend: Legend(
                          isVisible: true,
                          title: LegendTitle(text: 'EMA'),
                          position: LegendPosition.bottom,
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: chartSeries,
                        primaryXAxis: DateTimeCategoryAxis(
                          intervalType: DateTimeIntervalType.days,
                          dateFormat: DateFormat.d(),
                          minimum:
                              DateTime.now(), // Set the minimum value to today
                          maximum:
                              DateTime.now().add(Duration(days: selectDays)),
                          title: AxisTitle(text: 'Date'),
                        ),
                        primaryYAxis: NumericAxis(
                          title:
                              AxisTitle(text: 'Capacity'), // Set Y-axis title
                        ),
                      ),
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
    ),
  );
}
  }

  List<ChartSeries<Article, DateTime>> getForecastedCapacitySeries(
      Map<int, List<double>> forecastedCapacityForIDWs,
      Map<int, Color> idwColors) {
    final forecastedCapacitySeries = <ChartSeries<Article, DateTime>>[];
    // Get the current date
    final currentDate = DateTime.now();

    forecastedCapacityForIDWs.forEach((idw, forecastedValues) {
      final forecastedSeries = LineSeries<Article, DateTime>(
        name: 'Waste Bin $idw',
        dataSource: forecastedValues.asMap().entries.map((entry) {
          final day = entry.key + 1;
          final date = currentDate.add(Duration(days: day));
          return Article(
              Idw: idw, Capacity: entry.value.toInt(), Date_Time: date);
        }).toList(),
        xValueMapper: (Article article, _) => article.Date_Time,
        yValueMapper: (Article article, _) => article.Capacity,
        color:
            idwColors[idw] ?? Colors.grey, // Use the color based on IDW group
        dataLabelSettings: DataLabelSettings(isVisible: false),
        dataLabelMapper: (Article article, _) =>
            '${article.Capacity}', // Show data labels
      );
      forecastedCapacitySeries.add(forecastedSeries);
    });

    return forecastedCapacitySeries;
  }


Map<int, List<Article>> groupArticlesByGroup(List<Article> articles) {
  final map = Map<int, List<Article>>();
  for (final article in articles) {
    if (!map.containsKey(article.Idw)) {
      map[article.Idw] = [];
    }
    map[article.Idw]!.add(article);
  }
  return map;
}

Future<List<Article>> fetchArticle() async {
  final response = await http
      .get(Uri.parse('https://proesp32.000webhostapp.com/getDate30day.php'));

  if (response.statusCode == 200) {
    final articles = parseArticles(response.body);
    return articles;
  } else {
    throw Exception('Failed to load article');
  }
}

List<Article> parseArticles(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  final articles = <Article>[];

  for (final json in parsed) {
    if (json.containsKey('Capacity') && json['Capacity'] is String && json['Capacity'] == 'Sensor Error') {
      // Skip data with 'Sensor Error' in Capacity.
      continue;
    }

    try {
      final article = Article.fromJson(json);
      articles.add(article);
    } catch (e) {
      // Handle any other potential errors while parsing.
      print('Error parsing JSON data: $e');
    }
  }

  return articles;
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
      Date_Time: DateFormat('dd/MM/yyyy hh:mm:ss').parse(json['Date_Time']),
    );
  }
}
