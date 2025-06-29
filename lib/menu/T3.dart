import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/notification.dart';

int count = 0;

class T3 extends StatefulWidget {
  const T3({Key? key}) : super(key: key);
  @override
  State<T3> createState() => _T3State();
}

class _T3State extends State<T3> {
  @override
  late Future<List<Article>> _futureArticles;
  late SharedPreferences _prefs;

  late ValueNotifier<bool> capacityNotificationEnabled;
  late ValueNotifier<bool> airNotificationEnabled;
  late ValueNotifier<bool> methaneNotificationEnabled;
  late ValueNotifier<bool> humidityNotificationEnabled;
  late int selectedCapacity = 100;
  bool showSettings = false;
  bool hasShownNotification = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _futureArticles = fetchArticle();
    fetchArticle();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Call a function to get the updated notification count
      _initPreferences();
    });
  }

void _initPreferences() async {
  _prefs = await SharedPreferences.getInstance();
  setState(() {
    capacityNotificationEnabled = ValueNotifier<bool>(
        _prefs.getBool('capacityNotificationEnabled') ?? true);
    methaneNotificationEnabled = ValueNotifier<bool>(
        _prefs.getBool('methaneNotificationEnabled') ?? true);
    airNotificationEnabled =
        ValueNotifier<bool>(_prefs.getBool('airNotificationEnabled') ?? true);
    humidityNotificationEnabled = ValueNotifier<bool>(
        _prefs.getBool('humidityNotificationEnabled') ?? true);
    selectedCapacity = _prefs.getInt('selectedCapacity') ?? 100;

    hasShownNotification = _prefs.getBool('hasShownNotification') ?? false;
    if (capacityNotificationEnabled.value) {
      _showCapacityNotificationOnce();
    }
  });
}


  void _saveSettings() {
    _saveSwitchState(
        'capacityNotificationEnabled', capacityNotificationEnabled.value);
    _saveSwitchState(
        'methaneNotificationEnabled', methaneNotificationEnabled.value);
    _saveSwitchState(
        'humidityNotificationEnabled', humidityNotificationEnabled.value);
    _saveSwitchState('airNotificationEnabled', airNotificationEnabled.value);
    _prefs.setInt('selectedCapacity', selectedCapacity);
  }

  void _saveSwitchState(String key, bool value) {
    setState(() {
      _prefs.setBool(key, value);
    });
  }

  bool isSettingsDialogOpen = false;

  void _showSettingsDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Settings',
              style: TextStyle(
                color: Colors.black, // Change the text color to white
              ),
            ),
            content: SingleChildScrollView( // Wrap the content with a SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select Capacity',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  DropdownButton<int>(
                    value: selectedCapacity,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedCapacity = newValue!;
                        _prefs.setInt('selectedCapacity', selectedCapacity);
                      });
                    },
                    items: <int>[100, 90, 80, 70, 60, 50]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                  buildNotificationOption(
                    'Capacity Notification',
                    capacityNotificationEnabled,
                    (value) {
                      setState(() {
                        _saveSwitchState('capacityNotificationEnabled', value);
                        capacityNotificationEnabled.value = value;

                        if (!value) {
                          // Cancel the notification here
                          // Example: NotificationService().cancelCapacityNotification();
                        }
                      });
                    },
                  ),
                  buildNotificationOption(
                    'Air Notification',
                    airNotificationEnabled,
                    (value) {
                      setState(() {
                        _saveSwitchState('airNotificationEnabled', value);
                        airNotificationEnabled.value = value;
                        if (!value) {
                          // Cancel the notification here
                          // Example: NotificationService().cancelCapacityNotification();
                        }
                      });
                    },
                  ),
                  buildNotificationOption(
                    'Methane Notification',
                    methaneNotificationEnabled,
                    (value) {
                      setState(() {
                        _saveSwitchState('methaneNotificationEnabled', value);
                        methaneNotificationEnabled.value = value;
                        if (!value) {
                          // Cancel the notification here
                          // Example: NotificationService().cancelCapacityNotification();
                        }
                      });
                    },
                  ),
                  buildNotificationOption(
                    'Humidity Notification',
                    humidityNotificationEnabled,
                    (value) {
                      setState(() {
                        _saveSwitchState('humidityNotificationEnabled', value);
                        humidityNotificationEnabled.value = value;

                        if (!value) {
                          // Cancel the notification here
                          // Example: NotificationService().cancelCapacityNotification();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}


int count = 0;

int calculateNotificationCount(
  bool capacityEnabled,
  bool airEnabled,
  bool methaneEnabled,
  bool humidityEnabled,
  List<Article> articles,
) {
  count = 0;

  if (capacityEnabled) {
    count += articles.where((a) => a.Capacity >= selectedCapacity).length;

  }

  if (airEnabled) {
    count += articles.where((a) => a.Air_Quality == 'Bad').length;
    
  }

  if (methaneEnabled) {
    count += articles.where((a) => a.Methane == 'Methane High').length;
  
  }

  if (humidityEnabled) {
    count += articles.where((a) => a.Humidity == '95').length;
    
  }

  count += articles.where((a) => a.Capacity == 'Sensor Error').length;
  count += articles.where((a) => a.Air_Quality == 'Sensor Error').length;
  count += articles.where((a) => a.Methane == 'Sensor Error').length;
  count += articles.where((a) => a.Humidity == 'Sensor Error').length;

  return count;
}


  int notificationCount = 0;
  void SavedToPreferences(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('IntValue', value);
  }

  void _showCapacityNotificationOnce() {
    bool hasShownCapacityNotification =
        _prefs.getBool('hasShownCapacityNotification') ?? false;

    if (!hasShownCapacityNotification) {
      NotificationService().CapacityNotification();
      _prefs.setBool('hasShownCapacityNotification', true);
    }
  }

  void pollDataPeriodically() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      // Fetch new data and update the UI
      setState(() {
        _futureArticles = fetchArticle(); // Update the data
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (
    //     capacityNotificationEnabled == null ||
    //     airNotificationEnabled == null ||
    //     methaneNotificationEnabled == null ||
    //     humidityNotificationEnabled == null) {
    //   return CircularProgressIndicator(); // You can replace this with a loading widget.
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification',
          style: TextStyle(
            color: Colors.black, // Change the text color to white
          ),
        ),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showSettingsDialog();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Article>>(
          future: _futureArticles,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final articles = snapshot.data!;
              final fullAir_QualityArticles =
                  articles.where((a) => a.Air_Quality == 'Bad').toList();
              final fullMethaneArticles =
                  articles.where((a) => a.Methane == 'Methane').toList();
              final fullHumidityArticles =
                  articles.where((a) => a.Humidity == '100').toList();

              return ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final article1 = fullAir_QualityArticles.firstWhere(
                      (a) => a.Name == article.Name,
                      orElse: () => Article(
                          Id: '',
                          Idw: '',
                          Name: '',
                          Capacity: 0,
                          Lat: '',
                          Lng: '',
                          Address: '',
                          Air_Quality: '',
                          PPM: '',
                          Methane: '',
                          Humidity: '',
                          Date_Time: ''));
                  final article2 = fullMethaneArticles.firstWhere(
                      (a) => a.Name == article.Name,
                      orElse: () => Article(
                          Id: '',
                          Idw: '',
                          Name: '',
                          Capacity: 0,
                          Lat: '',
                          Lng: '',
                          Address: '',
                          Air_Quality: '',
                          PPM: '',
                          Methane: '',
                          Humidity: '',
                          Date_Time: ''));
                  final article3 = fullHumidityArticles.firstWhere(
                      (a) => a.Name == article.Name,
                      orElse: () => Article(
                          Id: '',
                          Idw: '',
                          Name: '',
                          Capacity: 0,
                          Lat: '',
                          Lng: '',
                          Address: '',
                          Air_Quality: '',
                          PPM: '',
                          Methane: '',
                          Humidity: '',
                          Date_Time: ''));

                  notificationCount = calculateNotificationCount(
                    capacityNotificationEnabled.value,
                    airNotificationEnabled.value,
                    methaneNotificationEnabled.value,
                    humidityNotificationEnabled.value,
                    articles, // Assuming you have access to the list of articles
                  );
                  SavedToPreferences(notificationCount);
                  print('Test1: $notificationCount');

                  //   if (capacityNotificationEnabled.value && article.Capacity >= selectedCapacity) {

                  //   } else {
                  //     NotificationService().CapacityError();
                  //   }

                  //   if (airNotificationEnabled.value && article1.Air_Quality == 'Bad') {

                  //   } else if (article.Air_Quality == 'Sensor Error') {
                  //     NotificationService().AirError();
                  //   } else {
                  //     NotificationService().cancelAirNotification();
                  //   }

                  //   if (methaneNotificationEnabled.value && article2.Methane == 'Methane High') {

                  //   } else if (article.Methane == 'Sensor Error') {

                  //   } else {
                  //     NotificationService().cancelMethaneNotification();
                  //   }

                  //   if (humidityNotificationEnabled.value && article3.Humidity == '95') {

                  //   } else if (article.Humidity == 'Sensor Error') {
                  //     NotificationService().HumidityError();
                  //   } else {
                  //     NotificationService().cancelHumidityNotification();
                  //   }
                  // }

                  Color tileBackgroundColor =
                      Color.fromARGB(198, 228, 228, 228);

                  return Card(
                    child: Column(
                      children: [
                        if (capacityNotificationEnabled.value &&
                            article.Capacity >= selectedCapacity)
                          Container(
                            color:
                                tileBackgroundColor, // Set the background color here
                            child: ListTile(
                              title: Text(article.Name),
                              subtitle: Text('Capacity: ${article.Capacity}'),
                              trailing: Icon(Icons.notification_important),
                            ),
                          ),
                        if (airNotificationEnabled.value &&
                            article1.Air_Quality ==
                                'Bad') // Check if Air_Quality is bad
                          Container(
                            color:
                                tileBackgroundColor, // Set the background color here
                            child: ListTile(
                              title: Text('Air Quality Notification'),
                              subtitle: Text(
                                  'Air Quality is bad at ${article1.Name}'),
                              trailing: Icon(Icons.notification_important),
                            ),
                          ),
                        if (methaneNotificationEnabled.value &&
                            article2.Methane ==
                                'Methane High') // Check if Methane is detected
                          Container(
                            color:
                                tileBackgroundColor, // Set the background color here
                            child: ListTile(
                              title: Text('Methane Notification'),
                              subtitle: Text(
                                  'Methane is detected at ${article2.Name}'),
                              trailing: Icon(Icons.notification_important),
                            ),
                          ),
                        if (humidityNotificationEnabled.value &&
                            article3.Humidity ==
                                '95') // Check if Humidity is detected
                          Container(
                            color:
                                tileBackgroundColor, // Set the background color here
                            child: ListTile(
                              title: Text('Humidity Notification'),
                              subtitle: Text(
                                  'Humidity is detected at ${article3.Name}'),
                              trailing: Icon(Icons.notification_important),
                            ),
                          ),
                        if (article.Capacity == 'Sensor Error')
                          Container(
                            color: tileBackgroundColor,
                            child: ListTile(
                              title: Text('Capacity Error'),
                              subtitle: Text('Sensor error at ${article.Name}'),
                              trailing: Icon(Icons.error),
                            ),
                          ),
                        if (article.Air_Quality == 'Sensor Error')
                          Container(
                            color: tileBackgroundColor,
                            child: ListTile(
                              title: Text('Air Quality Error'),
                              subtitle: Text('Sensor error at ${article.Name}'),
                              trailing: Icon(Icons.error),
                            ),
                          ),
                        if (article.Methane == 'Sensor Error')
                          Container(
                            color: tileBackgroundColor,
                            child: ListTile(
                              title: Text('Methane Error'),
                              subtitle: Text('Sensor error at ${article.Name}'),
                              trailing: Icon(Icons.error),
                            ),
                          ),
                        if (article.Humidity == 'Sensor Error')
                          Container(
                            color: tileBackgroundColor,
                            child: ListTile(
                              title: Text('Humidity Error'),
                              subtitle: Text('Sensor error at ${article.Name}'),
                              trailing: Icon(Icons.error),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

Widget buildNotificationOption(
  String title,
  ValueNotifier<bool> isEnabled,
  ValueChanged<bool> onChanged,
) {
  return ValueListenableBuilder(
    valueListenable: isEnabled,
    builder: (context, value, child) {
      return ListTile(
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      );
    },
  );
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
  final int Capacity;
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
    int capacity;
    try {
      capacity = int.parse(json['Capacity']);
    } catch (e) {
      // Handle the case where 'Capacity' is not a valid integer
      // You can set a default value or handle the error as needed
      capacity = 0; // Set a default value, or any other suitable value
    }
    return Article(
      Id: json['Id'] as String,
      Idw: json['Idw'] as String,
      Name: json['Name'] as String,
      Capacity: capacity,
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
