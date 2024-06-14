import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terpiez/models/models.dart';

class UserProvider with ChangeNotifier {
  String _id;
  DateTime _firstDayActive;
  List<TerpLocation> _allTerpLocations; // render all terps in the map
  double _closestTerpiezInMeters = double.infinity;
  late TerpLocation _closestTerpiezLocation = TerpLocation(
    terpiezId: '',
    latLng: const LatLng(0, 0),
  );
  List<CaughtTerpiez> _caughtTerpiez;
  bool _hasValidCredentials;
  int _terpiezCaughtCount;
  bool isCatchingTerpiez = false;
  bool _isConnectedToInternet;
  bool _isTerpDialogOpen = false;
  bool _isPlaySoundOn;

  UserProvider(
      {required List<TerpLocation> newLocations,
      required List<CaughtTerpiez> caughtTerpiez,
      required String userId,
      required bool hasValidCredentials,
      required DateTime firstDayActive,
      required int terpiezCaughtCount,
      required bool isConnectedToInternet,
      required bool isPlaySoundOn})
      : _id = userId,
        _allTerpLocations = newLocations,
        _caughtTerpiez = caughtTerpiez,
        _hasValidCredentials = hasValidCredentials,
        _firstDayActive = firstDayActive,
        _terpiezCaughtCount = terpiezCaughtCount,
        _isConnectedToInternet = isConnectedToInternet,
        _isPlaySoundOn = isPlaySoundOn;

  // getters
  DateTime get firstDayActive => _firstDayActive;
  String get userId => _id;
  double get closestTerpiezInMeters => _closestTerpiezInMeters;
  List<TerpLocation> get allTerpLocations => _allTerpLocations;
  TerpLocation get closestTerpiezLocation => _closestTerpiezLocation;
  List<CaughtTerpiez> get caughtTerpiez => _caughtTerpiez;
  bool get hasValidCredentials => _hasValidCredentials;
  int get terpiezCaughtCount => _terpiezCaughtCount;
  bool get isConnectedToInternet => _isConnectedToInternet;
  bool get isTerpDialogOpen => _isTerpDialogOpen;
  bool get isPlaySoundOn => _isPlaySoundOn;

  // setters
  set userId(String id) {
    _id = id;
    notifyListeners();
  }

  set firstDayActive(DateTime days) {
    _firstDayActive = days;
    notifyListeners();
  }

  set closestTerpiezInMeters(double meters) {
    _closestTerpiezInMeters = meters;
    notifyListeners();
  }

  set allTerpLocations(List<TerpLocation> newLocations) {
    _allTerpLocations = newLocations;
    notifyListeners();
  }

  set closestTerpiezLocation(TerpLocation object) {
    _closestTerpiezLocation = object;
    notifyListeners();
  }

  set caughtTerpiez(List<CaughtTerpiez> newCaughtTerpiez) {
    _caughtTerpiez = newCaughtTerpiez;
    notifyListeners();
  }

  void addToCaughtTerpiez(CaughtTerpiez caughtTerpiez) {
    _caughtTerpiez.add(caughtTerpiez);
    notifyListeners();
  }

  set hasValidCredentials(bool value) {
    _hasValidCredentials = value;
    notifyListeners();
  }

  set terpiezCaughtCount(int value) {
    _terpiezCaughtCount = value;
    notifyListeners();
  }

  set isConnectedToInternet(bool value) {
    _isConnectedToInternet = value;
    notifyListeners();
  }

  set isTerpDialogOpen(bool value) {
    _isTerpDialogOpen = value;
    // notifyListeners();
  }

  set isPlaySoundOn(bool value) {
    _isPlaySoundOn = value;
    notifyListeners();
  }

  // methods
  void reset(String newId, DateTime newFirstDayActive,
      List<TerpLocation> terpiezCoordinates) {
    _id = newId;
    _firstDayActive = newFirstDayActive;
    _allTerpLocations = [];
    _caughtTerpiez = [];
    _terpiezCaughtCount = 0;
    _isPlaySoundOn = true;
    _closestTerpiezLocation = TerpLocation(
      terpiezId: '',
      latLng: const LatLng(0, 0),
    );
    _closestTerpiezInMeters = double.infinity;
    notifyListeners();
  }
}
