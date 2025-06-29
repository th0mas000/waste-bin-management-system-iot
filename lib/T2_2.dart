import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class T2_2 extends StatefulWidget {
  const T2_2 ({Key? key}) : super(key: key);

  @override
  State<T2_2> createState() => _T2_2State();
}
class _T2_2State extends State<T2_2>{
  late Future<Map<int, List<Article>>> articles;
  int? selectedIdw;
  Map<int, Color> idwColors = {};
  DateTime selectedDate = DateTime.now();
  

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    articles = fetchArticle(selectedDate);
    selectedIdw = 1;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily',style: TextStyle(
      color: Colors.black, // Change the text color to white
    ),),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView( // Wrap your content in a SingleChildScrollView
        child: Column(
          children: [
          FutureBuilder<Map<int, List<Article>>>(
            future: articles,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final idwMap = snapshot.data!;
                final dropdownItems = <DropdownMenuItem<int>>[];

                idwMap.forEach((idw, articles) {
                  dropdownItems.add(
                    DropdownMenuItem(value: idw, child: Text('Select Id Wastebin: $idw')),
                  );
                  if (!idwColors.containsKey(idw)) {
                    idwColors[idw] = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
                  }
                });
                return Center(child: DropdownButton<int>(
                  value: selectedIdw,
                  items: dropdownItems,
                  onChanged: (value) async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != selectedDate) {
                      final newArticles = await fetchArticle(picked);
                      setState(() {
                        selectedIdw = value;
                        selectedDate = picked;
                        articles = Future.value(newArticles);
                      });
                    } else {
                      setState(() {
                        selectedIdw = value;
                      });
                    }
                  },
                ),);
              
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<Map<int, List<Article>>>(
              future: articles,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final idwMap = snapshot.data!;
                  final data = selectedIdw != null ? idwMap[selectedIdw!] ?? [] : idwMap.values.expand((articles) => articles).toList();
                  data.sort((a, b) => a.Date_Time.compareTo(b.Date_Time));
                  final averageCapacity = data.isNotEmpty
                      ? data.map((article) => article.Capacity).reduce((a, b) => a + b) / data.length
                      : 0.0;
                  return Column(
                    children: [
                      SfCartesianChart(
                        title: ChartTitle(text: 'Capacity And Times'),
                        legend: Legend(
                          isVisible: true,
                          title: LegendTitle(text: 'Capacity'),
                          position: LegendPosition.bottom,
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries>[
                          StackedLineSeries<Article, DateTime>(
                            name: 'Capacity',
                            dataSource: data,
                            color: idwColors[selectedIdw] ?? Colors.black,
                            xValueMapper: (Article article, _) => article.Date_Time,
                            yValueMapper: (Article article, _) => article.Capacity,
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                          ),
                        ],
                        primaryXAxis: DateTimeAxis(
                          title: AxisTitle(text: 'Time'),
                          minimum: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0), // set minimum time to 6 am
                          maximum: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23,59),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(text: 'Capacity'), // Add title for y-axis
                        ),
                      ),
                      Text('Average capacity: ${averageCapacity.toStringAsFixed(2)}'),
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



Future<Map<int, List<Article>>> fetchArticle(DateTime selectedDate) async {
  final formattedDate = DateFormat('MM/dd/yyyy').format(selectedDate);
  final response = await http.get(Uri.parse('https://proesp32.000webhostapp.com/getDataByDate.php?date='
      '$formattedDate'));
  if (response.statusCode == 200) {
    final articles = parseArticles(response.body);
    final idwMap = <int, List<Article>>{};
    articles.forEach((article) {
      final idw = article.Idw;
      if (!idwMap.containsKey(idw)) {
        idwMap[idw] = [];
      }
      if (article.Date_Time.month == selectedDate.month && article.Date_Time.day == selectedDate.day
          && article.Date_Time.year == selectedDate.year) {
        idwMap[idw]!.add(article);
      }
    });
    return idwMap;
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
      Date_Time: DateFormat('MM/dd/yyyy hh:mm:ss').parse(json['Date_Time']),
    );
  }
}