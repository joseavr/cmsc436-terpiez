import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import 'package:terpiez/hooks/useSelector.hook.dart';

import 'package:terpiez/utils/const.dart';
import 'package:terpiez/utils_services/local_notifications.dart';
import 'package:terpiez/models/models.dart';
import 'package:terpiez/providers/providers.dart';
import 'package:terpiez/ui/pages/pages.dart';
import 'package:terpiez/ui/widgets/ConfigDrawer.widget.dart';
import 'package:terpiez/utils/redis_client.dart';
import 'package:terpiez/utils/update_locations.util.dart';

class HomePageTabs extends StatefulWidget {
  const HomePageTabs({super.key});

  @override
  State<HomePageTabs> createState() => _HomePageTabsState();
}

class _HomePageTabsState extends State<HomePageTabs> {
  late Timer _timer;
  late bool _isConnected;

  @override
  void initState() {
    super.initState();

    // send store sound settings to the isolate
    FlutterBackgroundService().invoke('update_sound', {
      'play_sound': context.read<UserProvider>().isPlaySoundOn,
    });

    _isConnected = context.read<UserProvider>().isConnectedToInternet; //

    _checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkConnection() async {
    bool isConnectedNow = await RedisClient.instance.connect();

    if (!mounted) return;
    UserProvider user = context.read<UserProvider>();

    // Check if connection status has changed
    if (_isConnected != isConnectedNow) {
      // Update connection status
      setState(() {
        _isConnected = isConnectedNow;
      });
      // Update connection in user provider
      user.isConnectedToInternet = isConnectedNow;

      // restablished connection
      if (isConnectedNow) {
        final List<TerpLocation> terpiezLocations = [];
        // fetch terpiez locations from redis
        final locationData = await RedisClient.instance.get('locations', '.');
        final List<dynamic> locationJson = jsonDecode(locationData);
        // serialize terpiez location
        for (final element in locationJson) {
          terpiezLocations.add(TerpLocation.fromJson(element));
        }

        user.allTerpLocations =
            updateTerpiezLocations(user.caughtTerpiez, terpiezLocations);

        await redis.closeConnection();
      }

      // Show snackbar notification based on connection status change
      _showSnackbar(isConnectedNow
          ? ConnectionStatus.connected
          : ConnectionStatus.disconnected);
    }
  }

  void _showSnackbar(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: type == ConnectionStatus.connected
            ? const Text('Connection restored')
            : const Text('Connection lost'),
        duration: const Duration(seconds: 5),
        backgroundColor:
            type == ConnectionStatus.connected ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          // drawer
          drawer: const ConfigDrawer(),

          appBar: AppBar(
            title: const Text(
              'Terpiez',
              style: TextStyle(color: Colors.white),
            ),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  icon: Icon(Icons.insert_chart_outlined, color: Colors.white),
                  child: Text('Stats', style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  icon: Icon(Icons.search, color: Colors.white),
                  child: Text('Finder', style: TextStyle(color: Colors.white)),
                ),
                Tab(
                  icon: Icon(Icons.list, color: Colors.white),
                  child: Text('List', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          body: StreamBuilder(
              stream: LocalNotifications.onClickNotification.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == 'finder_screen') {
                    Future.delayed(Duration.zero, () {
                      int finderTabIndex = 1;
                      DefaultTabController.of(context)
                          .animateTo(finderTabIndex);
                    });
                  }
                }
                return const TabBarView(
                  children: [StatsScreen(), FinderScreen(), ListScreen()],
                );
              }),
        ));
  }
}
