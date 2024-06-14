import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:terpiez/utils_services/background_service.dart';

import 'package:terpiez/hooks/useSelector.hook.dart';
import 'package:terpiez/utils_services/local_notifications.dart';
import 'package:terpiez/models/models.dart';
import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/ui/pages/pages.dart';
import 'package:terpiez/utils/utils.dart';
import 'package:terpiez/utils/const.dart';

void main() async {
  // Ensures widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  // init background service
  initBackgroundService();

  // Create an instance of WidgetsBindingObserver
  // final observer = AppLifecycleObserver();
  // Attach the observer to the root widget
  // WidgetsBinding.instance.addObserver(observer);

  // init local notifications
  await LocalNotifications.init();

  // init variables
  const secureStorage = FlutterSecureStorage();
  List<TerpLocation> newTerpiezLocations = [];
  final List<TerpLocation> terpiezLocations = [];
  List<CaughtTerpiez> userCaughtTerpiez = [];
  bool hasValidCredentials = false;
  final DateTime firstDayActive;
  bool isConnected = false;

  // get credentials
  String userId = LocalStorage.getString('user_id');
  bool isSoundOn = LocalStorage.getBool('is_sound_on');
  int terpiezCaughtCount = LocalStorage.getInt('terpiez_caught_count');
  String username = await secureStorage.read(key: 'auth_redis_username') ?? '';
  String password = await secureStorage.read(key: 'auth_redis_password') ?? '';

  // if user exists
  if (userId.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
    hasValidCredentials = true;

    isConnected = await redis.connect(user: username, pass: password);

    if (isConnected) {
      // get terpiez locations
      final locationData = await RedisClient.instance.get('locations', '.');
      final List<dynamic> locationJson = jsonDecode(locationData);
      // serialize terpiez location
      for (final element in locationJson) {
        terpiezLocations.add(TerpLocation.fromJson(element));
      }

      await redis.closeConnection();
    }

    // get first day active
    firstDayActive = DateTime.parse(LocalStorage.getString('first_day_active'));

    // get user's caught terpiez from local storage
    final terpiezData = LocalStorage.getString('caught_terpiez');
    final Map<String, dynamic> json = jsonDecode(terpiezData);
    // serialize caught terpiez
    for (final entry in json.entries) {
      userCaughtTerpiez.add(CaughtTerpiez.fromJson(entry.value));
    }

    newTerpiezLocations =
        updateTerpiezLocations(userCaughtTerpiez, terpiezLocations);
  } else {
    firstDayActive = DateTime.now();
  }

  runApp(TerpiezApp(
    userId: userId,
    terpiezLocations: newTerpiezLocations,
    caughtTerpiez: userCaughtTerpiez,
    hasValidCredentials: hasValidCredentials,
    firstDayActive: firstDayActive,
    terpiezCaughtCount: terpiezCaughtCount,
    isConnectedToInternet: isConnected,
    isSoundOn: isSoundOn,
  ));
}

// The starting point of the app
class TerpiezApp extends StatelessWidget {
  const TerpiezApp(
      {super.key,
      required this.userId,
      required this.terpiezLocations,
      required this.caughtTerpiez,
      required this.hasValidCredentials,
      required this.firstDayActive,
      required this.terpiezCaughtCount,
      required this.isConnectedToInternet,
      required this.isSoundOn});

  final String userId;
  final List<TerpLocation> terpiezLocations;
  final List<CaughtTerpiez> caughtTerpiez;
  final bool hasValidCredentials;
  final DateTime firstDayActive;
  final int terpiezCaughtCount;
  final bool isConnectedToInternet;
  final bool isSoundOn;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserProvider(
                  userId: userId,
                  newLocations: terpiezLocations,
                  caughtTerpiez: caughtTerpiez,
                  hasValidCredentials: hasValidCredentials,
                  firstDayActive: firstDayActive,
                  terpiezCaughtCount: terpiezCaughtCount,
                  isConnectedToInternet: isConnectedToInternet,
                  isPlaySoundOn: isSoundOn,
                )),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Terpiez',
        theme: ThemeData(
          useMaterial3: false,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 251, 0, 0),
          ),
        ),
        home: const TerpiezHomePage(),
      ),
    );
  }
}

class TerpiezHomePage extends StatelessWidget {
  const TerpiezHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    UserProvider user = useProvider(context, true);

    return user.hasValidCredentials
        ? const HomePageTabs()
        : const Scaffold(body: CredentialPage());
  }
}
