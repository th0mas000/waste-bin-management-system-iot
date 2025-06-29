import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/LoginPage.dart';
import 'package:test2/menu/Home.dart';
import 'package:test2/menu/T1.dart';
import 'package:test2/menu/T2.dart';
import 'package:test2/menu/T3.dart';
import 'package:test2/sizes_helper.dart';

import '../notification.dart';
void main() async {
  debugPaintSizeEnabled = true;
  NotificationService().initNotification();
  WidgetsFlutterBinding.ensureInitialized();
  final notifications = FlutterLocalNotificationsPlugin();
  final initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('app_icon'),
    
  );
  await notifications.initialize(initializationSettings);
  
  runApp(new MaterialApp(
    home: new LoginPage(),
    
  
    routes: <String, WidgetBuilder>{
      '/HomePage': (BuildContext context) => new MyHomePage(),
      '/t3': (context) => T3(),
  
      
    },
    debugShowCheckedModeBanner: false,
    
  ));
}

  late Timer _timer;




class MyApp extends StatelessWidget {

final int notificationCount;
  const MyApp({Key? key, required this.notificationCount}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      showSemanticsDebugger: false,
      title: 'Wastebin',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  
  
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();


}
class _MyHomePageState extends State<MyHomePage>{
  int _currentIndex = 0;

  final tabs = [
    Home(),
    T1(),
    T2(),
    T3(),
  ];
  
  @override
  void initState() {
    super.initState();

    // Start a timer that updates the state every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Call a function to get the updated notification count
      getNotificationCountFromSharedPreferences();
    });
  }

  
int notificationCount = 0;

  getNotificationCountFromSharedPreferences() async {
      final prefs = await SharedPreferences.getInstance();
      notificationCount = prefs.getInt('IntValue') ?? 0;

      // Now you can use the notificationCount in this page
      print('Notification Count on NewPage: $notificationCount');
    }




  @override
  Widget build(BuildContext context){
    double w=displayWidth(context) * 0.09;
    double h=displayHeight(context)-
    MediaQuery.of(context).padding.top-
    kToolbarHeight;

    

    // getNotificationCountFromSharedPreferences() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   notificationCount = prefs.getInt('intValue') ?? 0;

    //   // Now you can use the notificationCount in this page
    //   print('Notification Count on NewPage: $notificationCount');
    // }
    getNotificationCountFromSharedPreferences();

  
    return Scaffold(
  body: tabs[_currentIndex],
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _currentIndex,
    type: BottomNavigationBarType.shifting,
    iconSize: h * 0.05, // Adjust the icon size based on screen height
  selectedItemColor: Colors.black, // Set the selected label color
  unselectedItemColor: Colors.white, // Set the unselected label color
  selectedLabelStyle: TextStyle(
    color: Colors.green, // Selected label text color
  ),
  unselectedLabelStyle: TextStyle(
    color: Colors.grey, // Unselected label text color
  ),
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
        backgroundColor: Colors.greenAccent,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.location_pin),
        label: 'My Map',
        backgroundColor: Colors.greenAccent,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_chart),
        label: 'Charts',
        backgroundColor: Colors.greenAccent,
      ),
      BottomNavigationBarItem(
        icon: Stack(
          children: <Widget>[
            Icon(Icons.notification_important),
            Positioned(
              right: 0,
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  '$notificationCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        label: 'Notifications',
        backgroundColor: Colors.greenAccent,
      ),
      
    ],
    onTap: (index) {
      setState(() {
        _currentIndex = index;
      });
    },
  ),
);
  }
  }

