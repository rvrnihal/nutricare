import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyGymsMapScreen extends StatefulWidget {
  const NearbyGymsMapScreen({super.key});

  @override
  State<NearbyGymsMapScreen> createState() => _NearbyGymsMapScreenState();
}

class _NearbyGymsMapScreenState extends State<NearbyGymsMapScreen> {
  late GoogleMapController mapController;
  Position? _userPosition;
  bool _isLoading = true;
  String? _errorMessage;
  final Set<Marker> _markers = {};

  // Sample nearby gyms (In production, would fetch from API)
  final List<_GymData> _nearbyGyms = [
    _GymData(
      name: 'FitZone Gym',
      lat: 40.7127837,
      lng: -74.0059413,
      distance: '0.5 km',
      rating: 4.5,
      address: 'Times Square, New York',
    ),
    _GymData(
      name: 'PowerFit Studio',
      lat: 40.7589,
      lng: -73.9851,
      distance: '1.2 km',
      rating: 4.7,
      address: 'Central Park South, New York',
    ),
    _GymData(
      name: 'Muscle House',
      lat: 40.7505,
      lng: -73.9972,
      distance: '0.8 km',
      rating: 4.3,
      address: 'Midtown, New York',
    ),
    _GymData(
      name: 'CrossFit Elite',
      lat: 40.7614,
      lng: -73.9776,
      distance: '1.5 km',
      rating: 4.6,
      address: 'Upper East Side, New York',
    ),
    _GymData(
      name: 'Urban Fitness',
      lat: 40.7489,
      lng: -73.9680,
      distance: '0.3 km',
      rating: 4.4,
      address: 'Grand Central, New York',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocationAndLoadMap();
  }

  Future<void> _getUserLocationAndLoadMap() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permission permanently denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get user's current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _userPosition = position;
      });

      // Add user location marker
      _addUserMarker(position);

      // Add nearby gyms markers
      _addNearbyGymsMarkers();

      setState(() {
        _isLoading = false;
      });

      // Animate camera to user location
      if (mounted) {
        mapController.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _addUserMarker(Position position) {
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    );
  }

  void _addNearbyGymsMarkers() {
    for (int i = 0; i < _nearbyGyms.length; i++) {
      final gym = _nearbyGyms[i];
      _markers.add(
        Marker(
          markerId: MarkerId('gym_$i'),
          position: LatLng(gym.lat, gym.lng),
          infoWindow: InfoWindow(
            title: gym.name,
            snippet: '${gym.distance} away • ${gym.rating} ⭐',
            onTap: () => _showGymDetails(gym),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }
  }

  void _showGymDetails(_GymData gym) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gym.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    gym.address,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    gym.distance,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⭐ ${gym.rating}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openGymInMaps(gym),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGymInMaps(_GymData gym) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(gym.name)}&center=${gym.lat},${gym.lng}';
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open maps right now.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Gyms'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Getting your location...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _getUserLocationAndLoadMap,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: _userPosition != null
                          ? CameraPosition(
                              target: LatLng(
                                _userPosition!.latitude,
                                _userPosition!.longitude,
                              ),
                              zoom: 14,
                            )
                          : const CameraPosition(
                              target: LatLng(40.7128, -74.0060),
                              zoom: 12,
                            ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _nearbyGyms.length,
                          itemBuilder: (context, index) {
                            final gym = _nearbyGyms[index];
                            return _buildGymCard(gym, index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildGymCard(_GymData gym, int index) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showGymDetails(gym),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  gym.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  gym.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        gym.distance,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      labelStyle: const TextStyle(color: Colors.blue),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⭐ ${gym.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GymData {
  final String name;
  final double lat;
  final double lng;
  final String distance;
  final double rating;
  final String address;

  _GymData({
    required this.name,
    required this.lat,
    required this.lng,
    required this.distance,
    required this.rating,
    required this.address,
  });
}
