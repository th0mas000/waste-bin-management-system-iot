import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class T1 extends StatefulWidget {
  const T1({Key? key}) : super(key: key);

  @override
  State<T1> createState() => _T1State();
}

class _T1State extends State<T1> {
  Completer<GoogleMapController> _controller = Completer();
  late LocationData currentLocation;
  List<Article> articles = []; // List to store fetched articles
  Set<Marker> _markers = {};
  bool isLoading = true; // Add a flag to track loading state
  bool isButtonCentered = false;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    fetchArticles(); // Fetch articles when the widget initializes
    addCustomIcon();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/icon.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

List<Marker> _sortMarkersByCapacity(List<Marker> markers, List<Article> articles) {
  // Create a list of markers and sort it based on capacity
  List<Marker> sortedMarkers = markers.toList();

  sortedMarkers.sort((a, b) {
    String capacityA = articles.firstWhere((article) => article.Idw == a.markerId.value).Capacity;
    String capacityB = articles.firstWhere((article) => article.Idw == b.markerId.value).Capacity;

    return int.parse(capacityB).compareTo(int.parse(capacityA));
  });

  return sortedMarkers;
}




  // Fetch articles from the API
  Future<void> fetchArticles() async {
    try {
      List<Article> fetchedArticles = await fetchArticle();
      setState(() {
        articles = fetchedArticles;
        isLoading = false; // Set isLoading to false when articles are fetched
      });
    } catch (e) {
      print('Error fetching articles: $e');
      setState(() {
        isLoading = false; // Set isLoading to false on error as well
      });
    }
  }

  Set<Marker> _createMarkersFromArticles(List<Article> articles) {
    Set<Marker> markers = {};
    for (Article article in articles) {
      markers.add(
        Marker(
          markerId: MarkerId(article.Idw),
          position: LatLng(
            double.parse(article.Lat),
            double.parse(article.Lng),
          ),
          infoWindow: InfoWindow(
            title: article.Name,
            snippet: article.Address,
            onTap: () {
              // When the info window is tapped, show the capacity of the marker
              _showCapacityDialog(article.Capacity);
            },
          ),
          icon: markerIcon,
        
        ),
      );
    }
   
  return markers;
  }

  void _showCapacityDialog(String capacity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Capacity"),
          content: Text("Capacity: $capacity"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Map",
          style: TextStyle(
            color: Colors.black, // Change the text color to white
          ),
        ),

        backgroundColor: Colors.greenAccent,
        
      ),
      body: isLoading // Check if loading
          ? Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: articles.isNotEmpty
                    ? LatLng(
                        double.parse(articles[0].Lat),
                        double.parse(articles[0].Lng),
                      )
                    : LatLng(
                        currentLocation.latitude!,
                        currentLocation
                            .longitude!), // Default location if articles is empty
                zoom: 16,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _createMarkersFromArticles(articles),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMe,
        label: Text('My location'),
        icon: Icon(Icons.near_me),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<LocationData> getCurrentLocation() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        // Permission denied
      }
      return null!;
    }
  }

  Future _goToMe() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();

    // Create a marker for the current location
    Marker currentLocationMarker = Marker(
      markerId: MarkerId('currentLocation'),
      position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
      infoWindow: InfoWindow(title: 'My Location'),
    );

    // Add the marker to the set of markers
    Set<Marker> updatedMarkers = Set.from(_markers);
    updatedMarkers.add(currentLocationMarker);

    // Update the state to trigger a rebuild of the map
    setState(() {
      _markers = updatedMarkers;
    });

    // Animate the camera to the current location
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          ),
          zoom: 16,
        ),
      ),
    );
  }

  Future _goToSuwannabhumiAirport() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller
        .animateCamera(CameraUpdate.newLatLng(LatLng(16.2449875, 103.2458206)));
  }

  Future _zoomOutToBangkok() async {
    final GoogleMapController controller = await _controller.future;
    currentLocation = await getCurrentLocation();
    controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(13.6846021, 100.5883304), 10));
  }
}

Future<List<Article>> fetchArticle() async {
  final response = await http
      .get(Uri.parse('https://proesp32.000webhostapp.com/getLatestData.php'));
  if (response.statusCode == 200) {
    return compute(parseArticles, response.body);
  } else {
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
