import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late SharedPreferences _prefs;
  late ValueNotifier<bool> simpleNotificationEnabled;
  late ValueNotifier<bool> capacityNotificationEnabled;
  late ValueNotifier<bool> airNotificationEnabled;
  late ValueNotifier<bool> methaneNotificationEnabled;
  late ValueNotifier<bool> humidityNotificationEnabled;

  

  @override
  void initState() {
    super.initState();
    // Initialize SharedPreferences
    _initPreferences();
  }

  

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      simpleNotificationEnabled = ValueNotifier<bool>(
          _prefs.getBool('simpleNotificationEnabled') ?? true);
      capacityNotificationEnabled = ValueNotifier<bool>(
          _prefs.getBool('capacityNotificationEnabled') ?? true);
      methaneNotificationEnabled = ValueNotifier<bool>(
          _prefs.getBool('methaneNotificationEnabled') ?? true);
      airNotificationEnabled =
          ValueNotifier<bool>(_prefs.getBool('airNotificationEnabled') ?? true);
      humidityNotificationEnabled = ValueNotifier<bool>(
          _prefs.getBool('humidityNotificationEnabled') ?? true);
    });
    
  }
  void _saveSettings() {
  _saveSwitchState('simpleNotificationEnabled', simpleNotificationEnabled.value);
  _saveSwitchState('capacityNotificationEnabled', capacityNotificationEnabled.value);
  _saveSwitchState('methaneNotificationEnabled', methaneNotificationEnabled.value);
  _saveSwitchState('humidityNotificationEnabled', humidityNotificationEnabled.value);
  _saveSwitchState('airNotificationEnabled', airNotificationEnabled.value);
}

  void _saveSwitchState(String key, bool value) {
    setState(() {
      _prefs.setBool(key, value);
    });
  }


  @override
  Widget build(BuildContext context) {
    if (simpleNotificationEnabled == null ||
        capacityNotificationEnabled == null ||
        airNotificationEnabled == null ||
        methaneNotificationEnabled == null ||
        humidityNotificationEnabled == null) {
      return CircularProgressIndicator(); // You can replace this with a loading widget.
    }
  


    bool isSimpleNotificationEnabled = simpleNotificationEnabled.value;
    print('Simple Notification Enabled: $isSimpleNotificationEnabled');

    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        
      ),
      body: ListView(
        children: <Widget>[
          buildNotificationOption(
            'Simple Notification',
            simpleNotificationEnabled,
            (value) {
              _saveSwitchState('simpleNotificationEnabled', value);
              simpleNotificationEnabled.value = value; // Update ValueNotifier
            },
          ),
          buildNotificationOption(
            'Capacity Notification',
            capacityNotificationEnabled,
            (value) {
              _saveSwitchState('capacityNotificationEnabled', value);
              capacityNotificationEnabled.value = value; // Update ValueNotifier
            },
          ),
          buildNotificationOption(
            'Air Notification',
            airNotificationEnabled,
            (value) {
              _saveSwitchState('airNotificationEnabled', value);
              airNotificationEnabled.value = value; // Update ValueNotifier
            },
          ),
          buildNotificationOption(
            'Methane Notification',
            methaneNotificationEnabled,
            (value) {
              _saveSwitchState('methaneNotificationEnabled', value);
              methaneNotificationEnabled.value = value; // Update ValueNotifier
            },
          ),
          buildNotificationOption(
            'humidity Notification',
            humidityNotificationEnabled,
            (value) {
              _saveSwitchState('humidityNotificationEnabled', value);
              humidityNotificationEnabled.value = value; // Update ValueNotifier
            },
          ),
          IconButton(
  icon: const Icon(Icons.settings),
  onPressed: () {
    _saveSettings(); // Save the settings

  },
),
        ],
      ),
      
    );
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
  
}


