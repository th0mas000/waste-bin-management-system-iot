import 'package:flutter/material.dart';
import 'package:test2/menu/Home.dart';

class DetailScreen extends StatelessWidget {
  final Article article;

  const DetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.Name,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200, // Set an appropriate height
              color: Colors.white,
              child: Icon(
                Icons.delete,
                size: 100,
                color: _getColorForCapacity(article.Capacity),
              ),
            ),
            _buildDetailTile("ID", article.Idw, Icons.info_outline),
            _buildDetailTile("Capacity", "${article.Capacity}%", Icons.delete),
            _buildDetailTile("Air Quality", article.Air_Quality, Icons.air),
            _buildDetailTile("PPM", article.PPM, Icons.pie_chart),
            _buildDetailTile("Methane", article.Methane, Icons.grass),
            _buildDetailTile("Humidity", article.Humidity, Icons.invert_colors),
            _buildDetailTile("Date/Time", article.Date_Time, Icons.calendar_today),
            _buildDetailTile("Lat", article.Lat, Icons.location_on),
            _buildDetailTile("Lng", article.Lng, Icons.location_on),
          ],
        ),
      ),
    );
  }

  Color _getColorForCapacity(String capacity) {
    if (int.parse(capacity) <= 50) {
      return Colors.green;
    } else if (int.parse(capacity) <= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildDetailTile(String label, String value, IconData iconData) {
    return ListTile(
      leading: Icon(
        iconData,
        size: 24,
        color: Colors.blue,
      ),
      title: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}

