import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'package:terpiez/hooks/useSelector.hook.dart';
import 'package:terpiez/models/models.dart';
import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/utils/utils.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  late UserProvider user;
  LatLng? _currentUserLocation;
  List<TerpLocation> _terpiezCoordinates = [];
  final Location _locationController = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    initializeTerpiezCoordinates();
    getLocationUpdates();
  }

  @override
  void dispose() {
    super.dispose();
    _locationSubscription?.cancel();
  }

  void initializeTerpiezCoordinates() {
    setState(() {
      user = context.read<UserProvider>();
      _terpiezCoordinates = user.allTerpLocations;
    });
  }

  Future<void> _focusCamera(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: position,
      zoom: await controller.getZoomLevel(),
    );

    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    double minDistance = double.infinity;
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _locationController.onLocationChanged.listen(
      (LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          setState(
            () {
              user.isCatchingTerpiez = false;

              _currentUserLocation = LatLng(
                currentLocation.latitude!,
                currentLocation.longitude!,
              );

              _focusCamera(_currentUserLocation!);

              // Calculate the distance between the user and each terpiez
              for (var currTerpLocation in _terpiezCoordinates) {
                LatLng terpiezLocation = currTerpLocation.latLng;

                double distance = calcDistanceBetweenInMeters(
                  _currentUserLocation!,
                  terpiezLocation,
                );

                minDistance = min(minDistance, distance);

                // update the closest terpiez in the provider
                if (minDistance == distance) {
                  user.closestTerpiezLocation = currTerpLocation;
                }
              }

              user.closestTerpiezInMeters = minDistance;

              // prepare updated location to send it to isolate
              final uncaughtTerpiez = user.allTerpLocations;
              final jsonLocation = TerpLocation.toJsonList(uncaughtTerpiez);

              // background service
              FlutterBackgroundService().invoke('update', {
                'closest_terpiez': minDistance,
                'play_sound': user.isPlaySoundOn,
                'uncaught_terpiez': jsonLocation
              });

              minDistance =
                  double.infinity; // reset for the next new current user loc.
            },
          );
        }
      },
    );

    // _locationController.enableBackgroundMode(enable: true);

    // _locationController.changeNotificationOptions(
    //   title: 'Geolocation',
    //   subtitle: 'Geolocation detection',
    // );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = useProvider<UserProvider>(context);

    return _currentUserLocation == null
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          )
        : GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _currentUserLocation!,
              zoom: 16.0,
            ),
            myLocationEnabled: true,
            markers: userProvider.isConnectedToInternet &&
                    userProvider.closestTerpiezLocation.terpiezId.isNotEmpty
                ? {
                    Marker(
                      markerId: MarkerId(
                          '${user.closestTerpiezLocation.latLng.latitude}-${user.closestTerpiezLocation.latLng.longitude}'),
                      icon: BitmapDescriptor.defaultMarker,
                      position: user.closestTerpiezLocation.latLng,
                    )
                  }
                : {});
  }
}
