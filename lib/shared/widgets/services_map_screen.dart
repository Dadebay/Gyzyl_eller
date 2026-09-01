import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:gyzyleller/core/models/location_model.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/shared/widgets/custom_flutter_map.dart';
import 'package:gyzyleller/core/models/metadata_models.dart' as mm;

class ServicesMapScreen extends StatefulWidget {
  final Location location;
  final String placeName;
  final String catName;
  final String? welayat;
  final String? etrap;
  final int? welayatId;
  final int? etrapId;

  const ServicesMapScreen({
    super.key,
    required this.location,
    required this.placeName,
    required this.catName,
    this.welayat,
    this.etrap,
    this.welayatId,
    this.etrapId,
  });

  @override
  State<ServicesMapScreen> createState() => _ServicesMapScreenState();
}

class _ServicesMapScreenState extends State<ServicesMapScreen> {
  static const double _initialZoom = 16.9;
  static const double _navigationZoom = 13.5;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  bool _isLoadingGPS = false;
  bool _hasStartedNavigation = false;
  LatLng? _currentUserLocation;
  bool _showUserLocation = false;
  LatLngBounds? _fitBounds;

  final loc.Location _location = loc.Location();
  String? _welayatName;
  String? _etrapName;

  @override
  void initState() {
    super.initState();
    _welayatName = widget.welayat;
    _etrapName = widget.etrap;

    if ((_welayatName == null || _etrapName == null) &&
        (widget.welayatId != null || widget.etrapId != null)) {
      _resolveLocationNames();
    }
  }

  Future<void> _resolveLocationNames() async {
    try {
      final List<mm.LocationModel> allLocations = [];

      // 1. Try to get from AllController if available
      try {
        if (Get.isRegistered<AllController>()) {
          allLocations.assignAll(Get.find<AllController>().allLocations);
        }
      } catch (_) {}

      // 2. If empty, fetch from API
      if (allLocations.isEmpty) {
        final MyJobsService service = MyJobsService();
        final fetched = await service.getLocations();
        allLocations.assignAll(fetched);
      }

      if (allLocations.isNotEmpty) {
        if (widget.welayatId != null) {
          final w =
              allLocations.firstWhereOrNull((l) => l.id == widget.welayatId);
          if (w != null) _welayatName = w.name;
        }
        if (widget.etrapId != null) {
          // Etraps are nested in welayats
          for (var w in allLocations) {
            final e = w.etraps.firstWhereOrNull((c) => c.id == widget.etrapId);
            if (e != null) {
              _etrapName = e.name;
              break;
            }
          }
        }
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Error resolving location names: $e');
    }
  }

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

            if (_routePoints.isNotEmpty) {
              _fitBounds = LatLngBounds.fromPoints(_routePoints);
            }
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
      markerIcons.add(Icons.circle);
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
            if (_welayatName != null || _etrapName != null)
              Text(
                _welayatName == _etrapName
                    ? (_welayatName ?? '')
                    : "${_welayatName ?? ''}${(_welayatName != null && _etrapName != null && _etrapName!.isNotEmpty) ? ', ' : ''}${_etrapName ?? ''}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
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
              if (!_hasStartedNavigation) {
                setState(() {
                  _hasStartedNavigation = true;
                });
              }

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
            zoom: _hasStartedNavigation ? _navigationZoom : _initialZoom,
            locations: locations,
            markerIcons: markerIcons,
            markerColors: markerColors,
            polylines: _routePoints.isNotEmpty ? _routePoints : null,
            polylineColor: const Color(0xFF2563EB),
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
            fitBounds: _fitBounds,
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
