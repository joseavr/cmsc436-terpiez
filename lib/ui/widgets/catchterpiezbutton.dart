import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:terpiez/utils/const.dart';
import 'package:terpiez/hooks/hooks.dart';
import 'package:terpiez/models/terp_location.dart';
import 'package:terpiez/models/terpiez.dart';
import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/ui/widgets/CatchedTerpiezDialog.widget.dart';
import 'package:terpiez/utils/utils.dart';

class CatchTerpiezButton extends StatefulWidget {
  final void Function()? playConfetti;
  const CatchTerpiezButton({super.key, this.playConfetti});

  @override
  State<CatchTerpiezButton> createState() => _CatchTerpiezButtonState();
}

class _CatchTerpiezButtonState extends State<CatchTerpiezButton> {
  late UserProvider user;
  late StreamSubscription<dynamic> _accelerometerListener;

  // audio variables
  final double _volume = 1.0;
  AudioPlayer _player = AudioPlayer();
  final AssetSource _sound = AssetSource('caught_notification.mp3');

  @override
  void initState() {
    super.initState();
    getShakingUpdates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = useProvider<UserProvider>(context);
  }

  void getShakingUpdates() {
    _accelerometerListener =
        userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      if (!(user.isTerpDialogOpen) &&
          user.isConnectedToInternet &&
          (user.closestTerpiezInMeters <= 10 && !(user.isCatchingTerpiez)) &&
          (event.x.abs() > 10 || event.y.abs() > 10 || event.z.abs() > 10)) {
        user.isCatchingTerpiez = true;
        handleCatchTerp();
      }
    });
  }

  @override
  void dispose() {
    _accelerometerListener.cancel();
    super.dispose();
  }

  void handleCatchTerp() async {
    user.isCatchingTerpiez = true;

    // play sound
    if (user.isPlaySoundOn) {
      _player.setVolume(_volume);
      _player.play(_sound);
    }

    // store the amount of terpiez caught: provider + localstorage
    user.terpiezCaughtCount = user.terpiezCaughtCount + 1;
    LocalStorage.setInt('terpiez_caught_count', user.terpiezCaughtCount);

    if (widget.playConfetti != null) widget.playConfetti!();

    // reference to terp caught id
    final closestTerp = user.closestTerpiezLocation;

    // reset closest terp from provider
    user.closestTerpiezLocation =
        TerpLocation(terpiezId: '', latLng: const LatLng(0, 0));

    // get 'terp info' from redis.terpiez by id
    await RedisClient.instance.connect();
    final data =
        await RedisClient.instance.get('terpiez', '.${closestTerp.terpiezId}');
    final Map<String, dynamic> jsonFromRedis = jsonDecode(data);

    // get all caught_terpiez from localstorage
    final localCaughtTerpiez = LocalStorage.getString('caught_terpiez');
    final Map<String, dynamic> localCaughtTerpiezJson =
        jsonDecode(localCaughtTerpiez);

    // terp by id doesn't exist, then initialize it
    if (localCaughtTerpiezJson[closestTerp.terpiezId] == null) {
      // get the base64 image and thumbnail from redis
      final imageBase64String = await RedisClient.instance
          .get('images', '.${jsonFromRedis['image']} ');

      final thumbnailBase64String = await RedisClient.instance
          .get('images', '.${jsonFromRedis['thumbnail']}');

      final [imagePath, thumbnailPath] = await Future.wait([
        saveImageToLocalFile(imageBase64String, 'image', closestTerp.terpiezId),
        saveImageToLocalFile(
            thumbnailBase64String, 'thumbnail', closestTerp.terpiezId)
      ]);

      localCaughtTerpiezJson[closestTerp.terpiezId] = {
        'id': closestTerp.terpiezId,
        'name': jsonFromRedis['name'],
        'description': jsonFromRedis['description'],
        'stats': jsonFromRedis['stats'],
        'thumbnail': thumbnailPath,
        'image': imagePath,
        'caught_locations': [
          {
            "id": closestTerp.terpiezId,
            "lat": closestTerp.latLng.latitude,
            "lon": closestTerp.latLng.longitude,
          }
        ]
      };
    } else {
      // terp exists then just add new location into caught_locations
      (localCaughtTerpiezJson[closestTerp.terpiezId]["caught_locations"]
              as List)
          .add({
        "id": closestTerp.terpiezId,
        "lat": closestTerp.latLng.latitude,
        "lon": closestTerp.latLng.longitude,
      });
    }

    // Show catched terpiez dialog
    CaughtTerpiez caughtTerpiezData =
        CaughtTerpiez.fromJson(localCaughtTerpiezJson[closestTerp.terpiezId]);
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            CatchedTerpiezDialog(terp: caughtTerpiezData));

    // save new caught list to user provider
    List<CaughtTerpiez> newCaughtTerpiezList = [];
    for (final terp in localCaughtTerpiezJson.entries) {
      newCaughtTerpiezList.add(CaughtTerpiez.fromJson(terp.value));
    }
    user.caughtTerpiez = newCaughtTerpiezList;

    // save terp_info to local storage
    LocalStorage.setString(
        'caught_terpiez', jsonEncode(localCaughtTerpiezJson));

    // update un-caught terpiez locations
    // user.allTerpLocations =
    //     updateTerpiezLocations(newCaughtTerpiezList, user.allTerpLocations);
    user.allTerpLocations.removeWhere((TerpLocation currentLoc) =>
        currentLoc.compareLatLng(closestTerp.latLng));

    // close connection
    await redis.closeConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      user.closestTerpiezInMeters > 10.0 ||
              user.isCatchingTerpiez ||
              !(user.isConnectedToInternet)
          ? ''
          : 'Shake it',
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: user.closestTerpiezInMeters > 10.0 ||
                user.isCatchingTerpiez ||
                !(user.isConnectedToInternet)
            ? Colors.white
            : Colors.green,
      ),
    );
  }
}
