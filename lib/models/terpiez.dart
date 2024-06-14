import 'package:terpiez/models/models.dart';

class CaughtTerpiez {
  final String id;
  final String name;
  final String description;
  final String thumbnail;
  final String image;
  final Map<String, int> stats;
  final List<TerpLocation> caughtLocations;

  CaughtTerpiez(
      {required this.id,
      required this.name,
      required this.description,
      required this.thumbnail,
      required this.image,
      required this.stats,
      required this.caughtLocations});

  factory CaughtTerpiez.fromJson(Map<String, dynamic> json) {
    // cast stats
    Map<String, int>? stats =
        json['stats'] != null ? Map<String, int>.from(json['stats']) : null;

    return CaughtTerpiez(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      image: json['image'] ?? '',
      stats: stats ?? {},
      caughtLocations: TerpLocation.fromJsonList(json['caught_locations']),
    );
  }
}
