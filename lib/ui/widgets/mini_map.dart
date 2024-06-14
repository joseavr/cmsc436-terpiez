import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:terpiez/models/models.dart';

class MiniGoogleMapWidget extends StatefulWidget {
  final List<TerpLocation> caughtLocations;
  const MiniGoogleMapWidget({Key? key, required this.caughtLocations})
      : super(key: key);

  @override
  State<MiniGoogleMapWidget> createState() => _MiniGoogleMapWidgetState();
}

class _MiniGoogleMapWidgetState extends State<MiniGoogleMapWidget> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
        _adjustCameraPosition();
      },
      initialCameraPosition: CameraPosition(
        target: widget.caughtLocations[0].latLng,
        zoom: 16.0,
      ),
      markers: {
        ...widget.caughtLocations.map((terpLocation) {
          return Marker(
            markerId: MarkerId(
                '${terpLocation.latLng.latitude}-${terpLocation.latLng.longitude}'),
            icon: BitmapDescriptor.defaultMarker,
            position: terpLocation.latLng,
          );
        }).toList()
      },
    );
  }

  void _adjustCameraPosition() {
    if (widget.caughtLocations.isEmpty) return;

    LatLngBounds? bounds = _calculateBounds(widget.caughtLocations);
    if (bounds == null) {
      LatLng defaultLocation = widget.caughtLocations.isNotEmpty
          ? widget.caughtLocations.first.latLng
          : const LatLng(0.0, 0.0);
      bounds = LatLngBounds(
        southwest: defaultLocation,
        northeast: defaultLocation,
      );
    }

    _mapController.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds!, 50));
    });
  }

  LatLngBounds? _calculateBounds(List<TerpLocation> locations) {
    if (locations.isEmpty) return null;

    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = -double.infinity;
    double maxLng = -double.infinity;

    for (TerpLocation location in locations) {
      double lat = location.latLng.latitude;
      double lng = location.latLng.longitude;
      if (lat < minLat) minLat = lat;
      if (lng < minLng) minLng = lng;
      if (lat > maxLat) maxLat = lat;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
