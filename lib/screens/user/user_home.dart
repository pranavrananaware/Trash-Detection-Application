import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trashhdetection/screens/user/detection_screen.dart';
import 'package:trashhdetection/screens/user/history_screen.dart';
import 'package:trashhdetection/screens/user/profile_screen.dart';
import 'package:trashhdetection/screens/user/camera_screen.dart';

class UserHome extends StatefulWidget {
  final String username;
  final String email;

  const UserHome({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  String location = 'Fetching location...';
  double? _latitude;
  double? _longitude;
  final List<Map<String, dynamic>> _detectionHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;
      setState(() {
        location =
            '${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
      });
    } catch (e) {
      setState(() {
        location = 'Unable to get location';
      });
    }
  }

  void _onImageCaptured(List<Map<String, dynamic>> history) {
    setState(() {
      _detectionHistory.clear();
      _detectionHistory.addAll(history);
    });
  }

  Future<void> _openInGoogleMaps() async {
    if (_latitude != null && _longitude != null) {
      final googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude';
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else {
        throw 'Could not open Google Maps';
      }
    }
  }

  Widget _buildGridItem(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FD),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.water_drop, color: Colors.blueAccent, size: 50),
            const SizedBox(height: 8),
            Text(
              'Water Trash\nDetection',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _openInGoogleMaps,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        location,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.map, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildGridItem(
                      'Camera',
                      FontAwesomeIcons.camera,
                      Colors.blueAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(
                              onImageCaptured: _onImageCaptured,
                              username: widget.username,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGridItem(
                      'Detection',
                      FontAwesomeIcons.magnifyingGlassChart,
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetectionScreen(),
                          ),
                        );
                      },
                    ),
                    _buildGridItem(
                      'History',
                      FontAwesomeIcons.clockRotateLeft,
                      Colors.orangeAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(
                              detectionHistory: _detectionHistory,
                              historyList: [],
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGridItem(
                      'Profile',
                      FontAwesomeIcons.user,
                      Colors.deepPurple,
                      () {
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
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
