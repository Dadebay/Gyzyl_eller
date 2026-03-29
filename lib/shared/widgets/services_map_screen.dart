import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:gyzyleller/core/models/location_model.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/widgets/custom_flutter_map.dart';

class ServicesMapScreen extends StatefulWidget {
  final Location location;
  final String placeName;
  final String catName;

  const ServicesMapScreen({
    super.key,
    required this.location,
    required this.placeName,
    required this.catName,
  });

  @override
  State<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends State<ServicesMapScreen> {
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  bool _isLoadingGPS = false;
  LatLng? _currentUserLocation;
  bool _showUserLocation = false;

  final loc.Location _location = loc.Location();

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingGPS = true;
    });
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) return;
      }

      final locationData = await _location.getLocation();
      if (mounted) {
        setState(() {
          _currentUserLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
        });
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGPS = false;
        });
      }
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentUserLocation == null) return;

    double destLat = widget.location.latitude ?? 37.95;
    double destLng = widget.location.longitude ?? 58.38;
    if (destLat > 48 && destLng < 48) {
      final temp = destLat;
      destLat = destLng;
      destLng = temp;
    }
    final destination = LatLng(destLat, destLng);
    final start = _currentUserLocation!;

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final dio = Dio();
      final url =
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final List<dynamic> coords = route['geometry']['coordinates'];

          setState(() {
            _routePoints = coords
                .map(
                    (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('❌ [ServicesMap] Error fetching route: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double destLat = widget.location.latitude ?? 37.95;
    double destLng = widget.location.longitude ?? 58.38;
    if (destLat > 48 && destLng < 48) {
      final temp = destLat;
      destLat = destLng;
      destLng = temp;
    }
    final destination = LatLng(destLat, destLng);

    List<LatLng> locations = [destination];
    List<IconData> markerIcons = [Icons.location_on];
    List<Color> markerColors = [Colors.red];

    if (_showUserLocation && _currentUserLocation != null) {
      locations.add(_currentUserLocation!);
      markerIcons.add(Icons.person_pin_circle);
      markerColors.add(Colors.blue);
    }

    final bottomInsets = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: ColorConstants.kPrimaryColor2,
      appBar: AppBar(
        backgroundColor: ColorConstants.kPrimaryColor2,
        elevation: 4,
        toolbarHeight: 65,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 22),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.placeName,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              widget.catName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.fromLTRB(15, 15, 15, max(15, bottomInsets - 10)),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.kPrimaryColor2,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (!_showUserLocation) {
                setState(() {
                  _showUserLocation = true;
                });
              }

              if (_currentUserLocation == null) {
                await _getCurrentLocation();
              }

              if (_currentUserLocation != null && _routePoints.isEmpty) {
                await _fetchRoute();
              }
            },
            child: (_isLoadingRoute || _isLoadingGPS)
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'navigate_to_place'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomFlutterMap(
            center: destination,
            markerSize: 35,
            zoom: 14.0,
            locations: locations,
            markerIcons: markerIcons,
            markerColors: markerColors,
            polylines: _routePoints.isNotEmpty ? _routePoints : null,
            polylineColor: const Color(0xFF2563EB),
          ),
          if (_isLoadingGPS)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

