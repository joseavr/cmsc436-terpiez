import 'package:google_maps_flutter/google_maps_flutter.dart';

// set
class TerpLocation {
  final String terpiezId;
  final LatLng latLng;

  TerpLocation({required this.terpiezId, required this.latLng});

  factory TerpLocation.fromJson(Map<String, dynamic> json) {
    return TerpLocation(
      terpiezId: json['id'],
      latLng: LatLng(json['lat'], json['lon']),
    );
  }

  static Map<String, dynamic> toJson(TerpLocation location) {
    return {
      'id': location.terpiezId,
      'lat': location.latLng.latitude,
      'lon': location.latLng.longitude
    };
  }

  static List<TerpLocation> fromJsonList(List<dynamic> json) {
    List<TerpLocation> terpiezLocations = [];

    for (final entry in json) {
      terpiezLocations
          .add(TerpLocation.fromJson(entry as Map<String, dynamic>));
    }
    return terpiezLocations;
  }

  static List<Map<String, dynamic>> toJsonList(List<TerpLocation> locations) {
    List<Map<String, dynamic>> terpiezLocations = [];

    for (final location in locations) {
      terpiezLocations.add(TerpLocation.toJson(location));
    }
    return terpiezLocations;
  }

  bool compareLatLng(LatLng other) {
    return (latLng.latitude == other.latitude &&
        latLng.longitude == other.longitude);
  }
}
