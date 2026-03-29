import 'package:latlong2/latlong.dart';

class Location {
  final double? latitude;
  final double? longitude;

  Location({this.latitude, this.longitude});

  LatLng? get latLng {
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude!, longitude!);
  }

  factory Location.fromLatLng(LatLng latlng) {
    return Location(
      latitude: latlng.latitude,
      longitude: latlng.longitude,
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['lat'] ?? json['latitude'])?.toDouble(),
      longitude: (json['lng'] ?? json['longitude'])?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
      };
}
