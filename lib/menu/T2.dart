import 'package:flutter/material.dart';
import 'package:test2/T2_1.dart';
import 'package:test2/T2_2.dart';
import 'package:test2/T2_3.dart';

import '../AllDataScreen.dart';

class T2 extends StatefulWidget {
  const T2({Key? key}) : super(key: key);

  @override
  State<T2> createState() => _T2State();
}

class _T2State extends State<T2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Page',style: TextStyle(
      color: Colors.black, // Change the text color to white
    ),),
        backgroundColor: Colors.greenAccent,
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.today), // Add an icon here
              title: Text('Daily'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => T2_2()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today), // Add an icon here
              title: Text('Monthly'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => T2_1()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.today), // Add an icon here
              title: Text('Yearly'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => T2_3()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.today), // Add an icon here
              title: Text('Forecast Charts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllDataScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
