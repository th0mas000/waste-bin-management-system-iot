import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:test2/AllDataScreen.dart';
import 'package:test2/DetailScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  static const routeName = '/Home';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Article>> articles;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    initializeNotifications();
    articles = fetchArticle();
  }

  void _goToAllDataScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllDataScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build"); // สำหรับทดสอบ
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.black, // Change the text color to white
          ),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: FutureBuilder<List<Article>>(
          // ชนิดของข้อมูล
          future: articles, // ข้อมูล Future
          builder: (context, snapshot) {
            int targetIdw = 3; // The Idw value you want to find
            String? capacityOfIdw3;
            print("builder"); // สำหรับทดสอบ
            print(snapshot.connectionState); // สำหรับทดสอบ
            if (snapshot.hasData) {
              // กรณีมีข้อมูล
              final articles = snapshot.data!;

              return Column(
                children: [
                  Container(
                    // สร้างส่วน header ของลิสรายการ
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(100),
                    ),
                    child: Row(
                      children: [
                        Text('Total ${snapshot.data!.length} items'),

                        // แสดงจำนวนรายการ
                      ],
                    ),
                  ),
                  Expanded(
                    // ส่วนของลิสรายการ
                    child: snapshot.data!.length > 0
                        ? ListView.separated(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              String capacityString =
                                  snapshot.data![index].Capacity;

                              // Parse the Capacity string as an integer
                              int capacity = int.tryParse(capacityString) ?? 0;

                              Color iconColor;
                              String T = '';
                              if (capacityString == 'Sensor Error') {
                                iconColor = Colors.black;
                                T = 'Sensor Error';
                              } else if (capacity <= 50) {
                                iconColor = Colors.green;
                                T = '$capacityString %';
                              } else if (capacity <= 70) {
                                iconColor = Colors.orange;
                                T = '$capacityString %';
                              } else {
                                iconColor = Colors.red;
                                T = '$capacityString %';
                              }
                              Color tileBackgroundColor =
                                  Color.fromARGB(198, 228, 228, 228);

                              return Card(
                                elevation: 5,
                                margin: EdgeInsets.all(10),
                                child: Container(
                                  color: tileBackgroundColor,
                                  child: ListTile(
                                    leading: Icon(Icons.delete,
                                        size: 50, color: iconColor),
                                    title: Text(snapshot.data![index].Name),
                                    subtitle: Text('$T'),
                                    onTap: () {
                                      if (snapshot.data![index].Capacity !=
                                          'Sensor Error') {
                                        // Only navigate if Capacity is not 'Sensor Error'
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailScreen(
                                                article: snapshot.data![index]),
                                          ),
                                        );
                                      } else {
                                        // Show a toast message when Capacity is 'Sensor Error'
                                        Fluttertoast.showToast(
                                          msg: 'Sensor Error',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : const Center(
                            child: Text('No items')), // กรณีไม่มีรายการ
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              // กรณี error
              return Text('${snapshot.error}');
            }
            // กรณีสถานะเป็น waiting ยังไม่มีข้อมูล แสดงตัว loading
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

Future<List<Article>> fetchArticle() async {
  // ทำการดึงข้อมูลจาก server ตาม url ที่กำหนด
  final response = await http
      .get(Uri.parse('https://proesp32.000webhostapp.com/getLatestData.php'));
  // เมื่อมีข้อมูลกลับมา
  if (response.statusCode == 200) {
    // ส่งข้อมูลที่เป็น JSON String data ไปทำการแปลง เป็นข้อมูล List<Article
    // โดยใช้คำสั่ง compute ทำงานเบื้องหลัง เรียกใช้ฟังก์ชั่นชื่อ parseArticles
    // ส่งข้อมูล JSON String data ผ่านตัวแปร response.body
    return compute(parseArticles, response.body);
  } else {
    // กรณี error
    throw Exception('Failed to load article');
  }
}

List<Article> parseArticles(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Article>((json) => Article.fromJson(json)).toList();
}

class Article {
  final String Id;
  final String Idw;
  final String Name;
  final String Capacity;
  final String Lat;
  final String Lng;
  final String Address;
  final String Air_Quality;
  final String PPM;
  final String Methane;
  final String Humidity;
  final String Date_Time;

  Article({
    required this.Id,
    required this.Idw,
    required this.Name,
    required this.Capacity,
    required this.Lat,
    required this.Lng,
    required this.Address,
    required this.Air_Quality,
    required this.PPM,
    required this.Methane,
    required this.Humidity,
    required this.Date_Time,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      Id: json['Id'] as String,
      Idw: json['Idw'] as String,
      Name: json['Name'] as String,
      Capacity: json['Capacity'] as String,
      Lat: json['Lat'] as String,
      Lng: json['Lng'] as String,
      Address: json['Address'] as String,
      Air_Quality: json['Air_Quality'] as String,
      PPM: json['PPM'] as String,
      Methane: json['Methane'] as String,
      Humidity: json['Humidity'] as String,
      Date_Time: json['Date_Time'] as String,
    );
  }
}
