import 'package:flutter/material.dart';
import 'package:trashhdetection/screens/user/detection_screen.dart';
import 'package:trashhdetection/screens/user/history_screen.dart';
import 'package:trashhdetection/screens/user/profile_screen.dart';
import 'package:trashhdetection/screens/user/camera_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class UserHome extends StatefulWidget {
  final String username;
  final String email;

  UserHome({required this.username, required this.email});

  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final List<Map<String, dynamic>> _detectionHistory = [];
  String _currentLocation = "Fetching location...";
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _currentLocation = "Location services disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          setState(() => _currentLocation = "Location permission denied");
          return;
        }
      }

      // ignore: deprecated_member_use
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentLocation = "${place.subLocality}, ${place.locality}, ${place.country}";
        });
      } else {
        setState(() => _currentLocation = "Location not found");
      }
    } catch (e) {
      setState(() => _currentLocation = "Error fetching location");
    }
  }

  void _openGoogleMaps() async {
    if (_latitude != null && _longitude != null) {
      final url = "https://www.google.com/maps?q=$_latitude,$_longitude";
      // ignore: deprecated_member_use
      if (await canLaunch(url)) {
        // ignore: deprecated_member_use
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open Google Maps")),
        );
      }
    }
  }

  void _onImageCaptured(List<Map<String, dynamic>> history) {
    setState(() {
      _detectionHistory.clear();
      _detectionHistory.addAll(history);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Trash Detection'),
        backgroundColor: Colors.blue.shade800,
        elevation: 10,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: _openGoogleMaps,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue.shade800),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentLocation,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                shrinkWrap: true,
                children: [
                  _buildGridItem('Camera', Icons.camera_alt, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          onImageCaptured: _onImageCaptured,
                          username: widget.username,
                        ),
                      ),
                    );
                  }),
                  _buildGridItem('Detection', Icons.analytics, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetectionScreen()));
                  }),
                  _buildGridItem('History', Icons.history, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryScreen(detectionHistory: _detectionHistory),
                      ),
                    );
                  }),
                  _buildGridItem('Profile', Icons.person, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          username: widget.username,
                          email: widget.email,
                          profilePicUrl: '',
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.blue.shade300,
          highlightColor: Colors.blue.shade200,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.blue.shade800),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
