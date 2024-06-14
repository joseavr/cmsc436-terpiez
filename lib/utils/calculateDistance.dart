import 'dart:math' as Math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

double calcDistanceBetweenInMeters(LatLng currentUserLocation, LatLng terpiez) {
  const R = 6371;

  // Convert degrees to radians
  var lat1 = currentUserLocation.latitude * Math.pi / 180;
  var lon1 = currentUserLocation.longitude * Math.pi / 180;
  var lat2 = terpiez.latitude * Math.pi / 180;
  var lon2 = terpiez.longitude * Math.pi / 180;

  var dlon = lon2 - lon1;
  var dlat = lat2 - lat1;

  var a = Math.pow(Math.sin(dlat / 2), 2) +
      Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dlon / 2), 2);
  var c = 2 * Math.asin(Math.sqrt(a));

  var distance = R * c;

  return (distance * 1000).floor().toDouble();
}
