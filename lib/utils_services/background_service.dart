import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terpiez/models/models.dart';

import 'package:terpiez/utils/const.dart';
import 'package:terpiez/utils/utils.dart';
import 'package:terpiez/utils_services/local_notifications.dart';

Future<void> initBackgroundService() async {
  // request notification permission
  await Permission.notification.isDenied.then((value) {
    if (value) Permission.notification.request();
  });

  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized();
  DateTime? lastNotificationTime;
  bool playSound = true;
  bool isMapService = false;

  final redis = RedisClient.instance;
  await redis.connect();
  List<dynamic> locationJson =
      jsonDecode(await RedisClient.instance.get('locations', '.'));
  await redis.closeConnection();

  // listening to the background state
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // listen for sound
  service.on('update_sound').listen((event) {
    logger.d('changed sound to: ${event?['play_sound']}');
    playSound = event?['play_sound'];
  });

  // listen for is_map_service
  service.on('update_is_map_service').listen((event) {
    logger.d('changed is_map_service to: ${event?['is_map_service']}');
    isMapService = event?['is_map_service'];
  });

  // GEOLOCATOR SERVICE
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true,
            timeLimit: const Duration(seconds: 5))
        .then((Position position) {
      double minDistance = double.infinity;

      // convert user position to LatLng
      LatLng currentUserLocation =
          LatLng(position.latitude, position.longitude);

      // convert json to List<TerpLocation>
      List<TerpLocation> terpiezCoordinates =
          TerpLocation.fromJsonList(locationJson);

      for (TerpLocation currTerpLoc in terpiezCoordinates) {
        double distance = calcDistanceBetweenInMeters(
            currentUserLocation, currTerpLoc.latLng);
        minDistance = min(minDistance, distance);
      }

      // notification.show
      if (minDistance > 0.0 && minDistance <= 20.0 && !isMapService) {
        logger.d("from geolocator: $minDistance");
        String body =
            "It's ${minDistance ?? 'unknown'}m away! Catch it before it escapes!";
        LocalNotifications.showNotification(body, playSound);
      }
    }).catchError((e) {
      logger.d("ERROR: ${e.toString()}");
    });
  });

  // MAP SERVICE
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance && isMapService) {
      if (await service.isForegroundService()) {
        service.on('update').listen((event) {
          playSound = event?['play_sound'];

          if (event?['closest_terpiez'] > 0.0 &&
              event?['closest_terpiez'] <= 20.0) {
            if (lastNotificationTime == null ||
                DateTime.now().difference(lastNotificationTime!) >=
                    const Duration(seconds: 15)) {
              logger.d("from service: ${event?['closest_terpiez']}");
              locationJson = event?['uncaught_terpiez'];

              String body =
                  "It's ${event?['closest_terpiez'] ?? 'unknown'}m away! Catch it before it escapes!";
              lastNotificationTime = DateTime.now();
              LocalNotifications.showNotification(
                  body, event?['play_sound'] ?? true);
            }
          }
        });
      }
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// A class that listens to the lifecycle state of the app
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check if the app is in the background/foreground
    // if (state == AppLifecycleState.detached) {
    //   FlutterBackgroundService().invoke('setAsBackground');
    //   FlutterBackgroundService().invoke('setAsForeground');
    // }
    if (state == AppLifecycleState.resumed) {
      FlutterBackgroundService().invoke('setAsForeground');
    }
  }
}
