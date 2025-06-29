import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('app_icon');

    DarwinInitializationSettings initializationIos =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationIos);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  void cancelSimpleNotification() {
    notificationsPlugin.cancel(0); // Assuming 0 is the ID of the Simple Notification
  }

  // Add this method to cancel the Capacity Notification
  void cancelCapacityNotification() {
    notificationsPlugin.cancel(1); // Assuming 1 is the ID of the Capacity Notification
  }

  // Add this method to cancel the Air Quality Notification
  void cancelAirNotification() {
    notificationsPlugin.cancel(2); // Assuming 2 is the ID of the Air Quality Notification
  }

  // Add this method to cancel the Methane Notification
  void cancelMethaneNotification() {
    notificationsPlugin.cancel(3); // Assuming 3 is the ID of the Methane Notification
  }

  // Add this method to cancel the Humidity Notification
  void cancelHumidityNotification() {
    notificationsPlugin.cancel(4); // Assuming 4 is the ID of the Humidity Notification
  }


Future<void> simpleNotificationShow() async {
  // Check if the notification has already been shown
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool notificationShown = prefs.getBool('simpleNotificationShown') ?? false;

  if (!notificationShown) {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'Channel_id',
      'Channel_title',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'app_icon',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    try {
      await notificationsPlugin.show(0, 'Simple Notification', 'New User send message', notificationDetails);

      // Mark the notification as shown
      prefs.setBool('simpleNotificationShown', true);
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}


    Future<void> CapacityNotification() async {
SharedPreferences prefs = await SharedPreferences.getInstance();
  bool notificationShown = prefs.getBool('CapacityeNotificationShown') ?? false;

if(!notificationShown){
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));
        

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        1, 'Capacity Notification', 'Capacity Is Full', notificationDetails);
}
  }

    Future<void> AirNotification() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
  bool notificationShown = prefs.getBool('AireNotificationShown') ?? false;
  if(!notificationShown){
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));
        

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        2, 'Air Quality Notification', 'Air Quality Is Bad', notificationDetails);
  }
  }

    Future<void> MethaneNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));
      

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        3, 'Methane Notification', 'Methane Is Detected', notificationDetails);
  }

    Future<void> HumidityNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));
    

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        4, 'Humidity Notification', 'Humidity Is Detected', notificationDetails);
  }

      Future<void> CapacityError() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));
  



    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        5, 'Capacity Sensor Error Notification', 'ERROR', notificationDetails);
  }

  Future<void> AirError() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        6, 'Air Sensor Error Notification', 'ERROR', notificationDetails);
  }

  Future<void> MethaneError() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        7, 'Methane Sensor Error Notification', 'ERROR', notificationDetails);
  }

  Future<void> HumidityError() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        icon: 'app_icon',
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        8, 'Humidity Sensor Error Notification', 'ERROR', notificationDetails);
  }


  Future<void> bigPictureNotificationShow() async {
    BigPictureStyleInformation bigPictureStyleInformation =
    const BigPictureStyleInformation(
        DrawableResourceAndroidBitmap('app_icon'),
        contentTitle: 'Code Compilee',
        largeIcon: DrawableResourceAndroidBitmap('app_icon'));

    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('big_picture_id', 'big_picture_title',
        priority: Priority.high,
        importance: Importance.max,
        styleInformation: bigPictureStyleInformation);

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        1, 'Big Picture Notification', 'New Message', notificationDetails);
  }

  Future<void> multipleNotificationShow() async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails('Channel_id', 'Channel_title',
        priority: Priority.high,
        importance: Importance.max,
        groupKey: 'commonMessage');

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    notificationsPlugin.show(
        0, 'New Notification', 'User 1 send message', notificationDetails);

    Future.delayed(
      const Duration(milliseconds: 1000),
          () {
        notificationsPlugin.show(
            1, 'New Notification', 'User 2 send message', notificationDetails);
      },
    );

    Future.delayed(
      const Duration(milliseconds: 1500),
          () {
        notificationsPlugin.show(
            2, 'New Notification', 'User 3 send message', notificationDetails);
      },
    );

    List<String> lines = ['user1', 'user2', 'user3'];

    InboxStyleInformation inboxStyleInformation =
    InboxStyleInformation(lines, contentTitle: '${lines.length} messages',summaryText: 'Code Compilee');

    AndroidNotificationDetails androidNotificationSpesific=AndroidNotificationDetails(
        'groupChennelId',
        'groupChennelTitle',
        styleInformation: inboxStyleInformation,
        groupKey: 'commonMessage',
        setAsGroupSummary: true
    );
    NotificationDetails platformChannelSpe=NotificationDetails(android: androidNotificationSpesific);
    await notificationsPlugin.show(3, 'Attention', '${lines.length} messages', platformChannelSpe);
  }



  
}